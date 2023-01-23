# Teddy corpus

Bootstrap parallel corpus from TED, following the model of TED2020.

This is necessary because the original TED2020 data has been taken offline, and the OPUS edition (https://opus.nlpl.eu/TED2020.php) is incomplete (contains aligned sentences, only).

Original TED data is released as CC BY–NC–ND 4.0 (https://www.ted.com/about/our-organization/our-policies-terms/ted-talks-usage-policy), which limits the distribution of derived works (`ND`). Thus, we merely create a mirror of TED transcripts (subtitles) and provide scripts to extract relevant information on the fly.  Teddy users can thus replicate the corpus locally and produce any desired format. In comparison to conventional social media corpora that follow a similarly (but more restrictive) distribution policy, we are allowed, however, to provide the source data along with the build script, so that we can guarantee that the resulting corpora are identical.

The original subtitles (without alternations) can be found under `vtt/`. 

We distribute this data in accordance with the original license in unmodified form and under the same conditions.
As for attribution, for each directory `$DIR` under `vtt/`, the original URI for the respective file `vtt/$DIR/$file` is `https://hls.ted.com/project_masters/$DIR/subtitles/$file`.

Note that at the moment, the `vtt/` directory contains a small excerpt of the full corpus.

See [LICENSE.md](LICENSE.md) for license and attribution.

## Setup and structure

The current release is incomplete with respect to TED subtitles. To retrieve and build the full corpus, run

	$> make

This was tested under Ubuntu 20.04L.

The build script creates the following directory structure:

- `vtt/` original subtitle files 
- `txt/` text files extracted from these (can be individually build from `vtt/` with `make txt`)

Notes:
- `vtt/` is bundled with the repository. For updating it with novel TED talks, run `make update_sources`. For updating it with inclusion novel transcripts for existing TED talks, run `make rebuild`.
- `txt/` is built from your current `vtt/`. If `vtt/` is manually updated, run `rm -rf txt/; make txt`.

Note that the [license](LICENSE.md) restricts any distribution of the files in `txt/` or subsequent annotations performed over that. However, unter German copyright law, we are allowed to share that data with interested parties for academic purposes if certain legal conditions are met. Please get in touch if you're unable to run these scripts yourself but interested in the data.

## Known Issues

In a number of cases, the subtitle file covers only the beginning of the transcript (cf. `1000.vtt` vs. [original](https://www.ted.com/talks/arianna_huffington_how_to_succeed_get_more_sleep/transcript?language=en)). Needs to be confirmed. Possibly, extraction needs to be re-done.

## Distribution and Acknowledgements

The corpus is distributed under the TED Personal (Non-Commercial) license (CC BY–NC–ND 4.0, see https://www.ted.com/about/our-organization/our-policies-terms/ted-talks-usage-policy). For scientific papers, we request additional attribution to the following publication:

	Christian Chiarcos (2023), The Teddy Corpus, unpublished ms., University of Augsburg, 2023

(Please check for updates.)

For other situations, please attribute to The AColi Corpora collection, https://github.com/acoli-repo/acoli-corpora.