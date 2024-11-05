# Build scripts for Bible corpus

For Bibles that we cannot redistribute, we provide build scripts. These are not maintained, however, and many are several years old and may require revision.
Note that these do not necessarily produce valid CES/XML, if the source data deviates from the standard pattern.

every sub-directory should provide a language-table.xml file to keep track of convertable languages

- `christos-c/`: the 100 Bibles corpus (CC0)
	- **license**: CC0
	- **build scripts**: For retrieval, only. Note that these bibles are not built, but just mirrorred (with full attribution, and used only if not provided independently), as they also use an XML version of Resnik's original DTD.
- `bible.com`: YouVersion Bibles
	- **license**: https://www.bible.com/terms, relevant conditions:
		- personal / non-commercial use: "personal and non-commercial use or for the internal use of your non-profit religious organization"
		- no crawling: "you are not permitted ... [to] use any robot, spider, or other automatic device, process, or means to access YouVersion for any purpose, including monitoring or copying any of the material on YouVersion"
	- **build scripts**: for retrieval and CES/XML conversion
- see https://find.bible/en/bibles/PDCWBT/ for further bibles

## Abandoned Bible portals

- `bibles.org`: The Global Bible Project
	- **license**: https://bibles.org/terms, relevant conditions:
		- non-commercial download permitted: "You may print and download from the Site solely for non-commercial use, provided you comply with the applicable copyright policy and any other applicable Terms and Conditions. If you download any content from this site, you may not remove any copyright or trademark notices or other notices that go with it."
		- no distribution: "you may not (a) modify, copy, distribute, decompile, disassemble, reverse engineer, create derivative works, or otherwise use or manipulate the Site or any of its content without our prior written consent"
		- no extraction *into a DB*: "you will not use the Site for ... systematically extracting data contained in the Site or any linked Web Site to populate databases for internal or external use of any fashion" (we do not violate this, as we retrieve individual files)
	- **build scripts**: for retrieval and CES/XML conversion 
- `unbound.biola.edu/`: Unbound bibles
	- **license**: tbc.
	- **build scripts**: no longer operational (data provider abandoned the service)
