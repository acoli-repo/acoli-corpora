# Early Modern High German

- Luther 1545, usage conditions roughly equivalent to CC BY-NC, see LICENSE

Build using 

	make

## Known issues

- extraction failed for all books and chapters with umlaut in the path:
	- b.DEU (!)
	- b.1KI
	- b.2KI
	- b.PRO (!)
	- b.LAM (!)
	- b.MAT (!!!)
	- b.ROM (!)
	- b.HEB (!)
	- a.1MC
	- a.2MC
	- a.EST
	- a.SUS
	- a.BEL
	- a.AZA
	- a.SON
	- a.MAN
- design decisions as requested by philologists
	- cross-references: Normally, these are removed from the text. Here, they are maintained for future processing. Remove before doing alignment!
	- additional markup: The XML file preserves footnotes as `<a name="...">` and footnote references with `<a href="..."/>`. Other markup has been removed. Remove before doing alignment!
	- additional content: Free text is preserved that is not verse aligned, but chapter-aligned only. Remove before doing alignment! Texts external to chapters is omitted. The underlying TSV file preserves full text and its original order.