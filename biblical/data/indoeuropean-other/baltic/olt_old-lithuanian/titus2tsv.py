import traceback
import sys,re,os
from bs4 import BeautifulSoup
from lxml import etree
import requests
# import xml.etree.ElementTree as ET

id2src2txts={}
id2src2types={}

for file in sys.argv[1:]:
	with open(file,"rt",errors="ignore") as input:
		parse=BeautifulSoup(input,"html.parser")
		dom = etree.HTML(str(parse))
		id=None
		for span in dom.xpath(".//span"):
			if(span.attrib["id"] in ["h5"] and "".join(span.xpath(".//text()")).strip().startswith("Reference:")):
				id="".join(span.xpath(".//text()")).strip()
				id=id[id.index(":")+1:].strip()
				if not id in id2src2txts: id2src2txts[id]={}
				if not file in id2src2txts[id]: id2src2txts[id][file]=[]
				id2src2txts[id][file].append("")

				if not id in id2src2types: id2src2types[id]={}
				if not file in id2src2types[id]: id2src2types[id][file]=[]
				id2src2types[id][file].append(None)

			elif id!=None:
				if "id" in span.attrib:
					if span.attrib["id"] in ["bpal16"]:
						## we checked these with Mortimer, these are cross-references ("cf") to bible passages without any textual overlap,
						## can be safely skipped
						id=None

					elif (span.attrib["id"].startswith("bpal") or span.attrib["id"] in ["nc16"]) and (id2src2types[id][file][-1] in [None, span.attrib["id"]]):
						id2src2txts[id][file][-1]+=("".join(span.xpath(".//text()"))+" ")
						id2src2types[id][file][-1]=span.attrib["id"]

	for id in id2src2txts:
		if file in id2src2txts[id] and file in id2src2types[id]:
			for txt,typ in zip(id2src2txts[id][file], id2src2types[id][file]):
				txt=" ".join(txt.split()).strip()
				if len(txt)>0:
					print(f"{file}\t{typ}\t{id}\t{txt}")

