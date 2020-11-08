# Quoth the Enterprise

A program to serve random Star-Trek quotes.

You'll need a script database, you can download it with something like this:

```sh
wget --recursive --no-parent \
  http://www.chakoteya.net/StarTrek/episodes.htm \
  http://www.chakoteya.net/NextGen/episodes.htm \
  http://www.chakoteya.net/DS9/episodes.htm \
  http://www.chakoteya.net/Voyager/episode_listing.htm \
  http://www.chakoteya.net/Enterprise/episodes.htm
```

The program and serves quotes as plain text under `quote/character-name` on port `4747`.

For example:

```
$ curl http://localhost:4747/quote/barclay
Blurred vision, dizziness, palpitations, a stinging sensation in the lower spine. It's Terrelian Death Syndrome, isn't it.
```
