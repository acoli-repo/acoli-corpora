# Teddy corpus (experimental)

Bootstrap parallel corpus from TED, following the model of TED2020.

This is necessary because the original TED2020 data has been taken offline, and the OPUS edition (https://opus.nlpl.eu/TED2020.php) is incomplete (contains aligned sentences, only).

Original TED data is released as CC BY–NC–ND 4.0 (https://www.ted.com/about/our-organization/our-policies-terms/ted-talks-usage-policy), which limits the distribution of derived works (`ND`). Thus, we merely create a mirror of TED transcripts (subtitles) and provide scripts to extract relevant information on the fly.  Teddy users can thus replicate the corpus locally and produce any desired format. In comparison to conventional social media corpora that follow a similarly (but more restrictive) distribution policy, we are allowed, however, to provide the source data along with the build script, so that we can guarantee that the resulting corpora are identical.

The original subtitles (without alternations) can be found under `vtt/`. 

We distribute this data in accordance with the original license in unmodified form and under the same conditions.
As for attribution, for each directory `$DIR` under `vtt/`, the original URI for the respective file `vtt/$DIR/$file` is `https://hls.ted.com/project_masters/$DIR/subtitles/$file`.

Build with

	$> make

Note that at the moment, the `vtt/` directory contains a small excerpt of the full corpus.

See [LICENSE.md](LICENSE.md) for license and attribution.