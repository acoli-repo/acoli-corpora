import traceback
import sys,re,os
from bs4 import BeautifulSoup
from lxml import etree
import requests
# import xml.etree.ElementTree as ET

id2src2txt={}
id2src2type={}

for file in sys.argv[1:]:
	with open(file,"rt",errors="ignore") as input:
		parse=BeautifulSoup(input,"html.parser")
		dom = etree.HTML(str(parse))
		id=None
		for span in dom.xpath(".//span"):
			if(span.attrib["id"] in ["h5"] and "".join(span.xpath(".//text()")).strip().startswith("Reference:")):
				id="".join(span.xpath(".//text()")).strip()
				id=id[id.index(":")+1:].strip()
				if not id in id2src2txt: id2src2txt[id]={}
				if not file in id2src2txt[id]:
					id2src2txt[id][file]=""
				elif len(id2src2txt[id][file].strip())>0:
					id2src2txt[id][file]+=" (...) "

				if not id in id2src2type: id2src2type[id]={}
			elif id!=None:
				if "id" in span.attrib:
					if span.attrib["id"] in ["bpal16"]:
						# try:
						# 	print(f"{file}\t{id2src2type[id][file]}\t{id}\t{id2src2txt[id][file]}")
						# except Exception:
							# traceback.print_exc()
							# sys.stderr.write(f"while processing {id} for {file}\n")
							## we checked these with Mortimer, these are cross-references ("cf") to bible passages without any textual overlap,
							## can be safely skipped
							# pass
						id=None

					elif (span.attrib["id"].startswith("bpal") or span.attrib["id"] in ["nc16"]) and (not file in id2src2type[id] or id2src2type[id][file]==span.attrib["id"]):
						id2src2txt[id][file]=(id2src2txt[id][file]+"".join(span.xpath(".//text()"))).strip()
						id2src2type[id][file]=span.attrib["id"]
		
		# if id!=None:
		# 	print(f"{file}\t{id2src2type[id][file]}\t{id}\t{id2src2txt[id][file]}")

	for id in id2src2txt:
		if file in id2src2txt[id] and file in id2src2type[id]:
			print(f"{file}\t{id2src2type[id][file]}\t{id}\t"+" ".join(id2src2txt[id][file].split()))

