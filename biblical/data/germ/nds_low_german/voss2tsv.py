""" reads PDF-XML from arguments, developed for Voss 1929, needs to be adjusted for other sources """

headline_fonts=["0"]
body_fonts=["3","5","4","8","17"]
verse_nr_fonts=["1","3"]

merge_body_and_verse_nr=True
chapter_break_symbol="KAPITEL"

import xml.etree.ElementTree as ET
import sys,re,os

headline2book={
	# Voss-1929 book titles as currently extracted
	"Dat Evangelium von Matthäus": "b.MAT",
	"Dat Evangelium von Markus": "b.MAR",
	"Dat Evangelium von Lukas": "b.LUK",
	"Dat Evangelium von Johannes": "b.JOH",
	"Dei Apostelgeschicht": "b.ACT",
	"Dei Breiw dei Römer": "b.ROM",
	"Dei irst Breiw an dei Korinther": "b.1CO",
	"Dei tweit Breiw an dei Korinther": "b.2CO",
	"Dei Breiw an dei Galater": "b.GAL",
	"Dei Breiw dei Epheser": "b.EPH",
	"Dei Breiw dei Philipper": "b.PHI",
	"Dei Breiw dei Kolosser": "b.COL",
	"Dei irst Breiw an dei Thessalonicher": "b.1TH",
	"Dei tweit Breiw an dei Thessalonicher": "b.2TH",
	"irst Breiw Timotheus": "b.1TI",
	"Dei tweit Breiw Timotheus": "b.2TI",
	"Dei Breiw Titus": "b.TIT",
	"Dei Breiw an Philemon": "b.PHM",
	"Petrus sin irst Breiw": "b.1PE",
	"Petrus sin tweit Breiw": "b.2PE",
	"Johannes sin irst Breiw": "b.1JO",
	"Johannes sin tweit Breiw": "b.2JO",
	"Johannes sin drüdd Breiw": "b.3JO",
	"Dei Breiw dei Hebräer": "b.HEB",
	"J akobus sin Breiw": "b.JAM",
	"Judas sin Breiw": "b.JUD",
	"Dei Apenborung von St. Johannes": "b.REV",
}

doc=ET.parse(sys.argv[1])
book=None
chap=None
verse=None

id2text={}
last_id=None

for page in doc.findall(".//page"):
	headline=""

	for text in page.findall(".//text"):
		if text.attrib["font"] in headline_fonts:
			headline+=" "+text.text
	headline=" ".join(headline.split()).strip()
	if len(headline)>0:
		if not headline in headline2book:
			raise Exception("unknown book (headline) \""+headline+"\"")
		book=headline2book[headline]
		last_id=None
		verse=None
		chap=0

	if not merge_body_and_verse_nr:
		# use this if you have distinct and unambiguous fonts for body and verse numbers
		for text in page.findall(".//text"):
			if text.attrib["font"] in verse_nr_fonts:
				if isinstance(chap,int):
					if re.match(r"^[^A-Za-z]*[0-9][^A-Za-z]*$",text.text):
						if re.sub(r"^[^0-9]*([0-9]+)([^0-9].*)?$",r"\1",text.text)=="1":
							chap=chap+1
						id=book+"."+str(chap)+"."+re.sub(r"\s+","",text.text)
						while(id) in id2text:
							id=id+"_"
							# invalid ids will still lead to unique lines
						id2text[id]=""
						last_id=id
			if last_id!=None:
				if text.attrib["font"] in body_fonts:
				 	id2text[last_id]+=re.sub(r"\s+"," ",re.sub(r"[0-9]+"," ",text.text)).strip()+" "

	if merge_body_and_verse_nr:
		# verse info interspersed in body
		# often in OCRed text, and there, numbers may be broken, too
		if isinstance(chap,int):
			content=""
			for text in page.findall(".//text"):
				if int(text.attrib["top"])>50:
					if text.attrib["font"] in verse_nr_fonts+body_fonts:
						content+=text.text+" "
				
			for token in content.split():
				if chapter_break_symbol in token:
					chap+=1
					# print(token,"=>","chap ",chap, chapter_break_symbol)
					verse="_"
				elif re.match(r".*[0-9]",token):
					verse=token.strip()
					id=book+"."+str(chap)+"."+token
					while(id) in id2text:
						id=id+"_"
					id2text[id]=""
					last_id=id
				elif len(token.strip())>0 and last_id!=None:
					id2text[last_id]+=token.strip()+" "

for id,text in id2text.items():
		if len(text.strip())>0:
			print(id+"\t"+text.strip())




	