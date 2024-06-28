import os,re,sys

""" given two directories of files, return the most likely mappings, based on n-gram overlap
	we produce an 1:1 alignment, if a text is broken into pieces in one side, we align with the larger fragment (which will have a low score, though)
"""

DEBUG=False
for i in range(1,len(sys.argv)):
	if "-debug" in sys.argv[i].lower():
		DEBUG=True
		sys.argv=sys.argv[0:i]+sys.argv[i+1:]
		break

dir1=sys.argv[1]
dir2=sys.argv[2]
n=5 # for Alm's (2008) Grimm and the 1884 Grimm, we have good performance with n=4, already
if len(sys.argv)>3:
	n=int(sys.argv[3])

src2ngram2freq={}
for file in os.listdir(dir1):
	file=os.path.join(dir1,file)
	src2ngram2freq[file]={}
	with open(file,"rt", errors="ignore") as input:
		sys.stderr.write(f"indexing {file}\n")
		sys.stderr.flush()
		text=" ".join(re.sub(r"[^a-zA-Z]+"," ",input.read()).split()).strip()
		text=" "*(n-1)+text+" "*(n-1) # padding
		for i in range(0,len(text)-n):
			ng=text[i:i+n]
			if not ng in src2ngram2freq[file]: 
				src2ngram2freq[file][ng]=1
			else:
				src2ngram2freq[file][ng]+=1

tgt2ngram2freq={}
for file in os.listdir(dir2):
	file=os.path.join(dir2,file)
	tgt2ngram2freq[file]={}
	with open(file,"rt", errors="ignore") as input:
		sys.stderr.write(f"indexing {file}\n")
		sys.stderr.flush()
		text=" ".join(re.sub(r"[^a-zA-Z]+"," ",input.read()).split()).strip()
		text=" "*(n-1)+text+" "*(n-1) # padding
		for i in range(0,len(text)-n):
			ng=text[i:i+n]
			if not ng in tgt2ngram2freq[file]: 
				tgt2ngram2freq[file][ng]=1
			else:
				tgt2ngram2freq[file][ng]+=1

sim_src_tgt=[]
for src in src2ngram2freq:
	for tgt in tgt2ngram2freq:
		tp=0
		for ng,f in tgt2ngram2freq[tgt].items():
			if ng in src2ngram2freq[src]:
				tp+=min(f,src2ngram2freq[src][ng])
		acc=2*tp/(sum(src2ngram2freq[src].values())+sum(tgt2ngram2freq[tgt].values()))
		sim_src_tgt.append((acc,src,tgt))

src2tgt2sim={}
sim_src_tgt.sort()
tgts=[]
for sim,src,tgt in reversed(sim_src_tgt):
	if not src in src2tgt2sim:
		if tgt in tgts:
			src2tgt2sim[src]={}
			if DEBUG: print(src,"_","_")
			continue
		src2tgt2sim[src]={tgt:sim}
		tgts.append(tgt)
		print(src,tgt,sim)

if DEBUG:
	for tgt in sorted(tgt2ngram2freq):
		if not tgt in tgts:
			print("_",tgt,"_")

