""" return verse alignment for two XML/CES Bibles, using @id attribute, *not* @altid
	output is a TSV format with column structure as defined in the arguments
 """

import sys,os,io,re,traceback,argparse
from bs4 import BeautifulSoup
from lxml import etree

cols=["{BASE}:@id", "{BASE}:text()", "{CF}:text()"]

def get_pfx(id:str):
	result=re.sub(r"[.0-9\-]*$","",id)
	# print("get_pfx",id,"=",result)
	return result

def expand_ids(id:str):
	origid=id
	base=get_pfx(id)
	id=id[len(base):]
	if not "-" in id:
		return [base+id]
	
	try:
	
		if "-" in id:
			start=id.split("-")[0].split(".")
			end=id.split("-")[-1].split(".")
			while(len(end)<len(start)):
				end=[start[-len(end)-1]]+end
			start=".".join(start)
			end=".".join(end)

		if ".".join(start.split(".")[0:-1]) != ".".join(end.split(".")[0:-1]):
			sys.stderr.write(f"warning: cannot expand {origid}, return [{base}{start}, {base}{end}] only\n")
			return [base+start,base+end]

		start=int(id.split("-")[0].split(".")[-1])
		base=base+".".join(id.split("-")[0].split(".")[0:-1])
		end=int(id.split("-")[-1].split(".")[-1])
		if end<start:
			raise Exception(f"cannot expand {origid}")
		return [ f"{base}.{nr}" for nr in range(start,end+1) ]
	except Exception:
		raise Exception(f"cannot expand {origid}")

def ids_overlap(id1: str, id2: str):
	base=get_pfx(id1)
	if not id2.startswith(base):
		return False
	x1=expand_ids(id1)
	x2=expand_ids(id2)
	result= x1[0] in x2 or x1[-1] in x2 or x2[0] in x1 or x2[-1] in x1
	# print(id1,id2,"overlap?",result,x1,x2)
	return result

args=argparse.ArgumentParser(description="align two CES/XML bibles via their @id attribute, note that we do not compile out all combinations, but just list all variants one below each other. This may be surprising to technical users, but was specifically requested by philologists.")
args.add_argument("BASE", type=str, help="reference document, CES/XML format. Note that we use its ordering of books, etc.")
args.add_argument("FILTER", type=str, help="another CES/XML document to be compared with BASE, we return all BASE <segs> that have at least one counterpart in FILTER; note that we don't reorder")
atts=["id"]
args.add_argument("-c","--cols", type=str, nargs="*", help=f"column/attributes (to specify order, we extract all attributes of seg elements), defaults to {atts}",default=atts)
args=args.parse_args()
atts=args.cols

pfx2filterids={}
for cf in [ args.FILTER ]:
	with open(cf,"rt",errors="ignore") as input:
		parse=BeautifulSoup(input,features="lxml")
		dom = etree.XML(str(parse).encode())
		for id in dom.xpath(f".//seg/@id"):
			pfx=get_pfx(id)
			if not pfx in pfx2filterids: pfx2filterids[pfx]=[id]
			elif not id in pfx2filterids[pfx]: pfx2filterids[pfx].append(id)

pfx2id2line_atts={}
with open(args.BASE,"rt",errors="ignore") as input:
	parse=BeautifulSoup(input,features="lxml")
	dom = etree.XML(str(parse).encode())
	for span in dom.xpath(".//seg"):
		if "id" in span.attrib:
			id=span.attrib["id"]
			pfx=get_pfx(id)
			if pfx in pfx2filterids:
				skip=True
				for f in pfx2filterids[pfx]:
					# print(pfx,f,id,"check")
					if ids_overlap(id,f):
						skip=False
						break
				if not skip:
					myatts=span.attrib
					for key in myatts:
						if not key in atts:
							atts.append(key)
					line=" ".join(span.xpath(".//text()"))
					line=" ".join(line.split()).strip()
					if not pfx in pfx2id2line_atts: 
						pfx2id2line_atts[pfx]={id : [(line,myatts)]}
					elif not id in pfx2id2line_atts[pfx]: 
						pfx2id2line_atts[pfx][id]=[(line,myatts)]
					else:
						pfx2id2line_atts[pfx][id].append((line,myatts))

print("# @"+"\t@".join(atts)+"\ttext()")

for pfx in pfx2id2line_atts:
	for id in pfx2id2line_atts[pfx]:
		for line,myatts in pfx2id2line_atts[pfx][id]:
			for a in atts:
				if a in myatts:
					print(myatts[a],end="")
				print("\t",end="")
			print(" ".join(line.split()).strip())
