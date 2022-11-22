import traceback
import sys,re,os
from bs4 import BeautifulSoup
from lxml import etree
import requests
# import xml.etree.ElementTree as ET

def normalize_ids(id:str,id2norm:dict):
	result=[]
	print(id)
	if id.startswith("cf."):
		result.append(None)
		id=re.sub(r"^cf\._*","",id)
		# if cf., return the altid, only
	for i,n in id2norm.items():
		if id.startswith(i):
			id=n+"."+id[len(i):]
			break
	for frag in id.split("/"):
		if not frag.startswith("WP_fol"): # no self.references
			frag=re.sub(r"cf\._*","",frag).strip()
			base=""
			for i,n in id2norm.items():
				if frag.startswith(i):
					base=n
					frag=frag[len(i):]
					break
			if base=="":
				while re.match(r".*[a-zA-Z].*",frag):
					base+=frag[0]
					frag=frag[1:]

			frag=re.sub(r"[^0-9()\-]+"," ",frag).strip()
			if base!="":
				frag=base+"."+".".join(frag.split())
			else:
				last=str(result[-1]).split(".")
				frag=frag.split()
				if len(last)>len(frag):
					frag=last[0:-len(frag)]+frag
					frag=".".join(frag)
				else:
					last=re.sub(r"[^a-zA-Z]+$$","",last)
					frag=last+"."+".".join(frag)
			result.append(frag)
			print("\t=>"+frag)
	return result
	# 			break



	# for frag in id.split("/")[1:]:
	# 	print(frag,end="=>")
	# 	if frag.startswith("cf."):
	# 		frag=re.sub(r"^cf\._*","",frag)
	# 	for i,n in id2norm.items():
	# 		if frag.startswith(i):
	# 			frag=n+"."+".".join(re.sub(r"[^0-9()\-]+"," ",frag[len(i):]).strip().split())
	# 			result.append(frag)
	# 			break
	# 	if not frag in result:
	# 		frag=".".join(re.sub(r"[^0-9\-]+"," ",base[len(i):]).strip().split())
	# 		tmp=frag.split("-")[0]
	# 		last=result[-1].split(".")
	# 		tmp=last[0:-len(tmp)]+[frag]
	# 		frag=".".join(tmp)
	# 		result.append(frag)
	# 	print(frag)
	# return result

id2src2txts={}
id2src2types={}

home_dir=os.path.dirname(os.path.realpath(__file__))

id2norm={}

abbrevs=os.path.join(home_dir,"abbrevs.tsv")
with open(abbrevs,"rt") as input:
	for line in input:
		line=line.strip()
		if "\t" in line:
			line=[field.strip() for field in line.split("\t")]
			if len(line[1])>0:
				id2norm[line[0]]=line[1]

page=""
for file in sys.argv[1:]:
	with open(file,"rt",errors="ignore") as input:
		parse=BeautifulSoup(input,"html.parser")
		dom = etree.HTML(str(parse))
		id=None
		altids=None
		for span in dom.xpath(".//span"):
			if(span.attrib["id"] in ["h5"] and "".join(span.xpath(".//text()")).strip().startswith("Reference:")):
				id="".join(span.xpath(".//text()")).strip()
				id=id[id.index(":")+1:].strip()

				ids=normalize_ids(id,id2norm)
				if id==None and len(ids)>1:
					id="_"+ids[1]
				else:
					id=ids[0]
				altids=ids[1:]


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

