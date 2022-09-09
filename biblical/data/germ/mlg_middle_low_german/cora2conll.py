import xml.etree.ElementTree as ET
import sys,re,os

def get_val(node, path, none_val="_"):
	""" path can be a single or alternative paths in an array 
		we support an XPath subset only, in particular, avoid ...//@varname, but write ...//*/@varname, instead
	"""
	# print(node,path)
	if isinstance(path,list):
		if len(path)==0:
			return none_val
		result=get_val(node,path[0],none_val=none_val)
		if result==none_val:
			return get_val(node,path[1:],none_val=none_val)
		return result
	elif path.strip().startswith("@"):
		try:
			return node.attrib[path.strip()[1:]]
		except KeyError:
			pass
	elif "@" in path:
		for child in node.findall(path.split("@")[0][0:-1]):
			result=get_val(child,"@"+path.split("@")[1],none_val=none_val)
			if result!=none_val:
				return result
	else:
		for child in node.findall(path):
			result=child.text
			if(result!=""):
				return result
	return none_val

doc=ET.parse(sys.argv[1])
id=1
book_id="_"
for item in doc.findall(".//token"):
	toks = item.findall(".//anno")
	if len(toks)==0:
		toks = item.findall(".//mod")
	if len(toks)==0:
		toks = [tok]
	for tok in toks:
		anno=[
			str(id),
			get_val(tok,"@id"),
			get_val(tok, ["@utf","@trans"]),
			get_val(tok, ["lemma_wsd/@tag","lemma/@tag"]),
			get_val(tok, ["pos/@tag","pos_gen/@tag"]),
			get_val(tok, "morph/@tag"),
			get_val(tok,".//bound_sent/@tag"),
		]
		id+=1
		print("\t".join(anno))

		if get_val(tok,".//bound_sent/@tag")=="Satz":
			print()
			id=1
