module Main
  ( main
  ) where

import           Control.Arrow
import           Control.DeepSeq
import           Control.Exception              ( evaluate )
import           Control.Monad                  ( guard )
import           Control.Monad.IO.Class         ( MonadIO(liftIO) )
import           Data.Char                      ( isLower )
import qualified Data.Map.Strict               as Map
import qualified Data.Text                     as T
import qualified Data.Text.IO                  as T
import           Data.Vector                    ( Vector )
import qualified Data.Vector                   as V
import           Network.Wai.Handler.Warp
import           Options.Applicative
import           Options.Generic         hiding ( metavar )
import           Say
import           Servant
import           System.Random
import           Text.HTML.TagSoup

main :: IO ()
main = do
  let
  (Options {..}, fs) <- customExecParser (prefs $ multiSuffix "...")
                                         (info optParser mempty)
  sayErr "Loading quotes"
  qs <- evaluate . force =<< loadQuotes fs
  let settings =
        setPort port
          . setBeforeMainLoop (sayErrString ("listening on port " ++ show port))
          $ defaultSettings
  runSettings settings (serve @API Proxy (server qs))
  pure ()

newtype Options w = Options
  { port :: w ::: Int <?> "Port to bind" <!> "4747"
  }
  deriving stock (Generic)

optParser :: Parser (Options Unwrapped, [FilePath])
optParser = (,) <$> (unwrap <$> parseRecord) <*> some
  (strArgument (help "html files containing transcripts" <> metavar "FILE"))

instance ParseRecord (Options Wrapped)
deriving instance Show (Options Unwrapped)

----------------------------------------------------------------
-- Server
----------------------------------------------------------------

type API = "quote" :> Capture "character" Text :> Get '[PlainText] Text

server :: Quotes -> Server API
server qs = getQuote
 where
  getQuote c = liftIO (randomQuote qs (T.toUpper c)) >>= \case
    Nothing -> throwError err404
    Just l  -> pure l

----------------------------------------------------------------
-- Quote handling
----------------------------------------------------------------

type Quotes = Map.Map Text (Vector Text)

loadQuotes :: [FilePath] -> IO Quotes
loadQuotes fs = do
  ts <- traverse T.readFile fs
  pure $ Map.fromListWith
    mappend
    [ (T.toUpper v, V.singleton l)
    | t              <- ts
    , TagText text   <- parseTags t
    , Just    (v, l) <- pure $ fixQuote text
    ]

randomQuote :: Quotes -> Text -> IO (Maybe Text)
randomQuote qs v = do
  case Map.lookup v qs of
    Nothing -> pure Nothing
    Just ls -> Just <$> randomElement ls

fixQuote :: Text -> Maybe (Text, Text)
fixQuote t = do
  let cleaned         = T.replace "\r\n" " " . T.strip $ t
      colon           = ": "
      removePlacement = T.strip . T.takeWhile (/= '[')
      fixVoice        = T.dropWhile (== 'p') . removePlacement
      removeDirection = dropBracket
      fixLine         = removeDirection . T.drop (T.length colon)
      (voice, line)   = fixVoice *** fixLine $ T.breakOn colon cleaned
  guard (not (T.null line))
  guard (not (T.null voice))
  guard (not (T.any isLower voice))
  pure (voice, line)

dropBracket :: Text -> Text
dropBracket t
  | T.null t
  = t
  | T.head t /= '('
  = t
  | otherwise
  = let d = T.dropWhile (/= ')') t in if T.null d then d else T.tail d

----------------------------------------------------------------
-- Utils
----------------------------------------------------------------

randomElement :: Vector a -> IO a
randomElement v = do
  i <- randomRIO (0, V.length v - 1)
  pure $ v V.! i
