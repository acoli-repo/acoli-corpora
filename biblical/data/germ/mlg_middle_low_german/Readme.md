# Middle Low German biblical texts

- Referenzkorpus Mittelniederdeutsch/Niederrheinisch, https://www.fdr.uni-hamburg.de/record/9195#.Yxhdt_uxVhE
- two editions: CorA-ReN-XML_1.1 and CorAXML_1.1; the former contains richer lemmatization information and uses `anno` for annotation, the latter is more compact and uses `mod` for annotation. It is not clear which one is derived from which one, both archives contain the same files and they have the same timestamp. We use the CorA-ReN-XML version.
- Biblical texts:

	CorA-ReN-XML_1.1/ReN_anno_2021-01-06/Halberst._Bibel_1522,_1._Mose_Kap._1_V._1_bis_Römer_Kap._7_V._12.xml
	CorA-ReN-XML_1.1/ReN_trans_2021-01-06/Kölner_Bibel_Ke_1478,79.xml
	CorA-ReN-XML_1.1/ReN_anno_2021-01-06/Kölner_Bibel_Ku_1478,79.xml
	CorA-ReN-XML_1.1/ReN_anno_2021-01-06/Lüb._Bibel_1494.xml
	CorA-ReN-XML_1.1/ReN_anno_2021-01-06/Lüb._Bug._Bibel_1534.xml
	CorA-ReN-XML_1.1/ReN_anno_2021-01-06/Lüb._HistB._L.xml
	CorA-ReN-XML_1.1/ReN_anno_2021-01-06/Verl._Sohn_1527.xml
	CorA-ReN-XML_1.1/ReN_trans_2021-01-06/Südwf._Psalm..xml
	CorA-ReN-XML_1.1/ReN_anno_2021-01-06/Nd._Apok._Tf..xml
	CorA-ReN-XML_1.1/ReN_trans_2021-01-06/Halberst._Bibel_1522,_Römer_Kap._7_V._13_bis_Römer_Kap._12_V._21.xml
	CorA-ReN-XML_1.1/ReN_anno_2021-01-06/Lüb._Psalter_1473.xml
	CorA-ReN-XML_1.1/ReN_anno_2021-01-06/Verl._Sohn_Stockh._Hs..xml

- unfortunately, none of these have *any* alignment even on the level of books, and the Bibles are merely excerpts
- `conll/`: automatically converted
- `conll_seg/`: chapter or book ids, manually added *as comments*

	- aligned (chap/book-level)
		- CorA-ReN-XML_1.1/ReN_anno_2021-01-06/Verl._Sohn_1527.xml
		- CorA-ReN-XML_1.1/ReN_trans_2021-01-06/Südwf._Psalm..xml
		- CorA-ReN-XML_1.1/ReN_anno_2021-01-06/Nd._Apok._Tf..xml
		- CorA-ReN-XML_1.1/ReN_trans_2021-01-06/Halberst._Bibel_1522,_Römer_Kap._7_V._13_bis_Römer_Kap._12_V._21.xml
	- partially processed
		- CorA-ReN-XML_1.1/ReN_anno_2021-01-06/Halberst._Bibel_1522,_1._Mose_Kap._1_V._1_bis_Römer_Kap._7_V._12.xml
	- todo
		- CorA-ReN-XML_1.1/ReN_trans_2021-01-06/Kölner_Bibel_Ke_1478,79.xml
		- CorA-ReN-XML_1.1/ReN_anno_2021-01-06/Kölner_Bibel_Ku_1478,79.xml
		- CorA-ReN-XML_1.1/ReN_anno_2021-01-06/Lüb._Bibel_1494.xml
		- CorA-ReN-XML_1.1/ReN_anno_2021-01-06/Lüb._Bug._Bibel_1534.xml
		- CorA-ReN-XML_1.1/ReN_anno_2021-01-06/Lüb._HistB._L.xml
	
	- excluded
		- CorA-ReN-XML_1.1/ReN_anno_2021-01-06/Lüb._Psalter_1473.xml: this is relatively unstructured and highly commented, unalignable
		- CorA-ReN-XML_1.1/ReN_anno_2021-01-06/Verl._Sohn_Stockh._Hs..xml: this is a free narrative in rhymes, barely alignable

	
	- remarks
	- for Halberst._Bibel_1522,_1._Mose_Kap._1_V._1_bis_Römer_Kap._7_V._12.xml, it is also to be noted that the text is sometimes interrupted by (explanatory?) pages(?). Textually, this is a Vulgate
	