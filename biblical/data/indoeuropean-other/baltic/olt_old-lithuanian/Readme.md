# Old Lithuanian bible and bible quotations

## `WP-1574.xml`: Excerpts from Wolfenbüttel Postil

- https://titus.fkidg1.uni-frankfurt.de/texte/etcs/balt/lit/wp/wp.htm

notes:

- The original can have multiple IDs for the same sentence, we make all but the first an altid
- Ids with `cf.` can be safely ignored
- The original HTML drops surface strings from spans if words span more than one line, in the export, these are replaced by the normalized form rather than in the original spelling (extrapolated from the attached JavaScript code). This is marked with `[...]`
- We only extract spans annotated with references. In the original HTML, discontinuous excerpts are only annotated at the first segment, so only that will be found.

## `BP-1591`: Excepts from Bretke Postil

Provided by the project "The Postil Time Machine: Inner-European Knowledge Transfer as a Graph — the Lithuanian Lutheran Postils of the 16th Century" (funded by DFG, 2021-2024):

- data entry by Mortimer Drach and Jolanta Gelumbeckaite, GU Frankfurt, Germany
- XML edition by Christian Chiarcos, U Cologne, Germany

> Notes: 
> - This is a pre-final version, use with care and check here for updates.
> - This is generated from `bp.tsv` from a [private project repo](https://github.com/acoli-repo/passage-finder/tree/main/samples). To update it, do
>	
>		$> pandoc BP_1591_unicode_bible_tags.docx -o BP_1591_unicode_bible_tags.txt
>		$> python3 extract-refs.py BP_1591_unicode_bible_tags.txt | sort -u > bp.tsv

