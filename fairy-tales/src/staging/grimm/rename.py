import sys,io,re

""" arguments: files with two-column TSV format, first column is source, second is target
	for every line in stdin, replace the first match of the source string by the target string """

src2tgt={}
for file in sys.argv[1:]:
	with open(file,"rt",errors="ignore") as input:
		for line in input:
			line=line.strip()
			fields=line.split("\t")
			if len(fields)==2:
				src=fields[0].strip()
				tgt=fields[1].strip()
				src2tgt[src]=tgt

for line in sys.stdin:
	for src,tgt in src2tgt.items():
		if src in line:
			line=line[:line.index(src)]+tgt+line[line.index(src)+len(src):]
			break
	print(line,end="")
	

