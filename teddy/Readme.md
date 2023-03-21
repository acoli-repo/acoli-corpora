# Teddy corpus

Bootstrap parallel corpus from TED, following the model of TED2020.

This is necessary because the original TED2020 data has been taken offline, and the OPUS edition (https://opus.nlpl.eu/TED2020.php) is incomplete (contains aligned sentences, only).

Original TED data is released as CC BY–NC–ND 4.0 (https://www.ted.com/about/our-organization/our-policies-terms/ted-talks-usage-policy), which limits the distribution of derived works (`ND`). Thus, we merely create a mirror of TED transcripts (subtitles) and provide scripts to extract relevant information on the fly.  Teddy users can thus replicate the corpus locally and produce any desired format. In comparison to conventional social media corpora that follow a similarly (but more restrictive) distribution policy, we are allowed, however, to provide the source data along with the build script, so that we can guarantee that the resulting corpora are identical.

The original subtitles (without alternations) can be found under `vtt/`. 

We distribute this data in accordance with the original license in unmodified form and under the same conditions.
As for attribution, for each directory `$DIR` under `vtt/`, the original URI for the respective file `vtt/$DIR/$file` is `https://hls.ted.com/project_masters/$DIR/subtitles/$file`.

Note that at the moment, the `vtt/` directory contains a small excerpt of the full corpus.

See [LICENSE.md](LICENSE.md) for license and attribution.

## Setup and Structure

The current release is incomplete with respect to TED subtitles. To retrieve and build the full corpus, run

	$> make

This was tested under Ubuntu 20.04L.

The build script creates the following directory structure:

- `vtt/` original subtitle files 
- `txt/` text files extracted from these (can be individually build from `vtt/` with `make txt`)

Notes:
- `vtt/` is bundled with the repository. For updating it with novel TED talks, run `make update_sources`. For updating it *under inclusion of novel transcripts for previously known TED talks*, run `make rebuild`.
- `txt/` is built from your current `vtt/`. If `vtt/` is manually updated, run `rm -rf txt/; make txt`.

Note that the [license](LICENSE.md) restricts any distribution of the files in `txt/` or subsequent annotations performed over that. However, unter German copyright law, we are allowed to share that data with interested parties for academic purposes if certain legal conditions are met. Please get in touch if you are unable to run these scripts yourself but you are interested in the data.

## Addenda

Optionally, a sentence-aligned corpus can be created in the `align/` folder by calling

	$> make align

The resulting files will all provide an alignment with English (as this is the unique source language for all translations).

This uses Hunalign. Unfortunately, we cannot guarantee that the resulting corpus *fully* replicates our local version: if non-deterministic decisions are being made in Hunalign or a different version of the algorithm is used, the outcome may have minor differences. It will nevertheless be equivalent. 

## Known Issues and TODOs

- The extracted segments overlap at the end and the beginning. These overlaps have been removed by filtering out duplicate lines. However, if the same line is repeated *at a different place* in the transcript, this will also be removed.
- `make txt` performs whitespace normalization, that is, the offsets of the same transcript may be different from other retrievers.
- `make txt` performs heuristic sentence splitting. The basic break pattern is `[.!?]\s[A-Z]`. While this will work nicely for English and the majority of other languages, it will overgenerate breaks for languages with upper case spelling for words other than sentence-initial (e.g., German nouns), it will effectively fail for any language with non-Latin orthography (this is by intent, because these might have different punctuation characters), but also for non-ASCII characters (e.g., accented characters -- unless spelled with combining diacritics).

## Distribution and Acknowledgements

The corpus is distributed under the TED Personal (Non-Commercial) license (CC BY–NC–ND 4.0, see https://www.ted.com/about/our-organization/our-policies-terms/ted-talks-usage-policy). For scientific papers, we request additional attribution to the following publication:

	Christian Chiarcos (2023), The Teddy Corpus, unpublished ms., University of Augsburg, 2023

(Please check for updates.)

For other situations, please attribute to The AColi Corpora collection, https://github.com/acoli-repo/acoli-corpora.