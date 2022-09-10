# ACoLi parallel biblical text corpus

Developed as a parallel corpus for historical and dialectal Germanic languages, we began collecting Bibles, Bible excerpts and related texts for Germanic and other languages.
Unfortunately, most of the material drawn from web sources does not come with an explicit license statement, it is therefore restricted, and even where the copyright of the texts has expired for centuries, the rights for the electronic edition may still hold (see below). Therefore, as German law does not support the notion of fair use, we're heavily limited with respect to the data we can redistribute and the point in time we can.

We provide (building/crawling routines for) about 760 texts (incl. duplicates). The migration process, however, is still on-going, so there is more to come. For legal reasons, we can only distribute 125 of these directly, for the others, we provide build scripts to replicate their retrieval and conversion locally. 

Wrt. format, we follow the specifications of Philip Resnik's classical Bible corpus (1996, http://www.umiacs.umd.edu/~resnik/parallel/bible.html), but updated to XML.
Resnik's bibles followed the SGML-based Corpus Encoding Standard (CES). While this has been largely replaced by TEI P5 (http://www.tei-c.org/Guidelines/P5/), we opted for a minimally invasive update of the format and use an XML version of CES. TEI conversion along the lines of https://github.com/morethanbooks/XML-TEI-Bible may be a topic for future activities.

## Updates

- **Planned release**: In Germany, the rights of an editor expire 25 years after publication. For web resources, the date of publication may be unknown, though, so we have to rely on the date of download. For most our data, this was 2012-12-31, so for texts whose copyright expires (75 years after death of author), we plan to redistribute them as of Jan 1st, 2037.

- **2018 Copyright Law**: In 2018, German copyright law has been revised. It is allowed now to use 75% of a copyrighted and published work to be used for academic purposes, and to publicly publish 15% of the work. (Comments and discussion under https://www.urheberrecht.de/urheberrechtsreform/#Urheberrechtsreform-kurz-und-kompakt.) As the choice of the sampling procedure depends on the specific use case, and also, some sampling strategies may be considered more legally harmful than others (e.g., random sampling vs. running text, sampling over the entire bible or within individual books), we do not provide this a priori. Instead, please get in contact with us if you are interested in any specific sample.

- **Related research**: The mass conversion of parallel text is a laborsome, but scientifically fruitful enterprise (for NLP purposes, at least), and Resnik's CES schema introduced a reference that later research could easily follow. Except for minor differences in the SGML-to-XML transition, there is a compatible, but slightly later Bible corpus under https://github.com/christos-c/bible-corpus. Although much smaller in size than our sample, the authors put their corpus under CC0. We assume that they achieved legal clearance, and for languages not covered in our distributable sample, we integrate their data. Note that our data cannot be integrated into their corpus because in most cases, we cannot change the license to CC0.

- **Building in 2022**: Several build scripts now fail because portals are down or changed formats. We are considering to publish *all* data via Zenodo directly, with custom embargo periods depending on reserved rights (copyright, edition right).

## History

- **2012-05-01** (unpublished) initial compilation efforts, creating an XML version of Resnik's parallel bibles (http://www.umiacs.umd.edu/~resnik/parallel/bible.html) [CC]
- **2012-12-31** (internal) converted approx. 1,200 Bibles and biblical texts (Germanic and non-Germanic) from various portals, licenses unclear, hence not distributable
- **2014-04-26** public announcement of the Germanic Bible corpus in Chiarcos et al. (2014, LaTeCH@EACL-2014, http://aclanthology.info/papers/new-technologies-for-old-germanic-resources-and-research-on-parallel-bibles-in-older-continental-western-germanic)
- **2014-2017** maintenance and consolidation [BK]
- **2017-04-15** begin migration to Github [CC]
- **2017-04-18** added Bibles from unbound.biola.edu (converted 2012) [CC]
- **2021-09-25** updated copyright information, added CC0 data from https://github.com/christos-c/bible-corpus [CC]
- **2021-09-29** added Catalan and Bavarian (build scripts only) [CC]
- **2022-09-09** added Low German and Middle Low German [CC]

## Current status and TODOs

- Status 2017: language-table.xhtml
- TODO: Update langage-table.xhtml

## Contributors

- CC - Christian Chiarcos, christian.chiarcos@web.de
- BK - Bastian Kaiser