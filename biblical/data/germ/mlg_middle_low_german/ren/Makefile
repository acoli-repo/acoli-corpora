all: conll

conll: CorA-ReN-XML_1.1
	if [ ! -e conll ]; then mkdir conll; fi
	for file in \
		CorA-ReN-XML_1.1/ReN_trans_2021-01-06/Halberst._Bibel_1522,_Römer_Kap._7_V._13_bis_Römer_Kap._12_V._21.xml \
		CorA-ReN-XML_1.1/ReN_trans_2021-01-06/Kölner_Bibel_Ke_1478,79.xml \
		CorA-ReN-XML_1.1/ReN_anno_2021-01-06/Kölner_Bibel_Ku_1478,79.xml \
		CorA-ReN-XML_1.1/ReN_anno_2021-01-06/Lüb._Bibel_1494.xml \
		CorA-ReN-XML_1.1/ReN_anno_2021-01-06/Lüb._Bug._Bibel_1534.xml \
		CorA-ReN-XML_1.1/ReN_anno_2021-01-06/Halberst._Bibel_1522,_1._Mose_Kap._1_V._1_bis_Römer_Kap._7_V._12.xml \
		CorA-ReN-XML_1.1/ReN_anno_2021-01-06/Lüb._HistB._L.xml \
		CorA-ReN-XML_1.1/ReN_anno_2021-01-06/Verl._Sohn_Stockh._Hs..xml \
		CorA-ReN-XML_1.1/ReN_anno_2021-01-06/Verl._Sohn_1527.xml \
		CorA-ReN-XML_1.1/ReN_anno_2021-01-06/Nd._Apok._Tf..xml \
		CorA-ReN-XML_1.1/ReN_trans_2021-01-06/Südwf._Psalm..xml \
		CorA-ReN-XML_1.1/ReN_anno_2021-01-06/Lüb._Psalter_1473.xml \
		CorA-ReN-XML_1.1/ReN_anno_2021-01-06/Lüb._Psalter_1473.xml; do \
		echo $$file 1>&2; \
		python3 cora2conll.py $$file > conll/`basename $$file | sed s/'\.xml$$'//`.conll; \
	done

CorA-ReN-XML_1.1:
	wget -nc https://www.fdr.uni-hamburg.de/record/9195/files/CorA-ReN-XML_1.1.zip
	# wget -nc https://www.fdr.uni-hamburg.de/record/9195/files/CorAXML_1.1.zip
	for file in *.zip; do unzip $$file; done
