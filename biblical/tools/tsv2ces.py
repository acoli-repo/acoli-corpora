import sys,os,re,argparse,traceback,datetime


if __name__ == '__main__':

    args=argparse.ArgumentParser(description="given a TSV/UTF8 files for content and metadata, produce a CES/XML bible, write it to stdout")
    args.add_argument("content", type=str, help="two column TSV file, column structure: VERSE_ID<TAB>VERSE")
    args.add_argument("metadata", nargs="?",type=str, default=None, help="three column TSV file, column structure: TEI_PATH<TAB>DC_ELEMENT<TAB>VALUE")

    args=args.parse_args()

    # we consider TEI/CES medata only, here
    meta2vals={}
    comments=[]
    if(args.metadata!=None):
        with open(args.metadata) as input:
            for line in input:
                line=line.strip()
                if line.startswith("#"):
                    line=re.sub(r"^#","",line).strip()
                    comments.add(line)
                else:
                    fields=line.split("\t")
                    if len(fields)>2:
                        tei=fields[0]
                        # dc=fields[1]
                        val=fields[2]
                        if tei in meta2vals:
                            if not val in meta2vals[tei]:
                                meta2vals[tei].append(val)
                        else:
                            meta2vals[tei]=[val]

    if not "date" in meta2vals:
        meta2vals["date"]=[datetime.date.today().strftime("%Y-%m-%d")]

    meta=["lang","fileDesc/titleStmt", "fileDesc/notesStmt","fileDesc/sourceDesc","lang","date"]
    for m in meta:
        if not m in meta2vals:
            meta2vals[m]=[]

    meta2vals= { meta : "\n".join(vals) for meta,vals in meta2vals.items() }

    # write prolog
    print('<?xml version="1.0" encoding="utf-8"?>\n'+
    '<!DOCTYPE cesDoc SYSTEM "cesDoc.dtd">\n'+
    '<cesDoc version="4.3" type="bible" TEIform="modif-TEI.corpus" lang=\"'
    +meta2vals["lang"]+"\">")

    # write header

    print('<cesHeader version="4.1" type="text" creator="tsv2ces.py" status="new" date.created="'+meta2vals["date"]+'\" TEIform="modif-TEI.corpus 2" lang="eng">')

    print('<fileDesc>\n'+
    '<titleStmt>\n'+
    '<h.title>'+meta2vals["fileDesc/titleStmt"]+'</h.title>\n'+
    '<respStmt>\n'+
    '<respName>tsv2ces.py</respName>\n'+
    '<respType>converted from tab format to CES-style XML</respType>\n'+
    '</respStmt>\n'+
    '</titleStmt>\n'+
    '<editionStmt version="1.0">initial release</editionStmt>\n'+
    '<publicationStmt>\n'+
    '<distributor>Christian Chiarcos</distributor>\n'+
    '<pubAddress>ACoLi, GU Frankfurt, Germany</pubAddress>\n'+
    '<availability status="free">\n'+
    '</availability>\n'+
    '<pubDate value="'+meta2vals["date"]+'">'+meta2vals["date"]+'</pubDate>\n'+
    '</publicationStmt>\n'+
    '<sourceDesc>\n'+
    '<biblStruct>\n'+
    '<monogr>\n'+
    '<h.title>'+meta2vals["fileDesc/titleStmt"]+'</h.title>\n'+
    '<imprint>\n'+
    '<pubDate>Unknown</pubDate>\n'+
    '<publisher>'+meta2vals["fileDesc/sourceDesc"]+"</publisher>\n"+
    '</imprint>\n'+
    '</monogr>\n'+
    '</biblStruct>\n'+
    '</sourceDesc>\n'+
    '</fileDesc>\n'+
    '<encodingDesc>\n'+
    '<projectDesc>'+meta2vals["fileDesc/notesStmt"]+"\n\n"+
    "This version is encoded in XML, conformant to the SGML specifications of Philipp Resnik's parallel bibles (http://www.umiacs.umd.edu/~resnik/parallel/bible.html), an adaption of the level 1 specifications of the Corpus Encoding Standard, for non-commercial research use. (XML conversion required minor adjustments of the DTD.)\n"+
    "NOTE: CES is superseded by the TEI, the encoding was chosen for compatibility with Resnik's bibles.</projectDesc>\n"+
    '<editorialDecl>\n'+
    '<conformance level="1">Corpus Encoding Standard, Version 2.0</conformance>\n'+
    '<correction status="unknown" method="silent"/>\n'+
    '<segmentation>Marked up to the level of chapter and verse.</segmentation>\n'+
    '</editorialDecl>\n'+
    '</encodingDesc>\n'+
    '<profileDesc>\n'+
    '<langUsage>\n'+
    '<language id="'+meta2vals["lang"]+'" iso639="'+meta2vals["lang"]+'">'+meta2vals["lang"]+'</language>\n'+
    '</langUsage>\n'+
    '<wsdUsage>\n'+
    '<writingSystem id="utf-8">Unicode</writingSystem>\n'+
    '</wsdUsage>\n'+
    '</profileDesc>\n'+
    '</cesHeader>')

    # write body
    print('<text>\n<body lang="'+meta2vals["lang"]+'" id="'+re.sub(r"[^a-zA-Z0-9]+","_",meta2vals["fileDesc/titleStmt"])+'">')

    with open(args.content,"r") as input:
        book=None
        chap=None
        seg=None

        book2comments={}
        book2chap2text={}

        for line in input:
            line=line.strip()
            if line.startswith("#"):
                comment="<!-- "+line[1:].strip()+" -->\n"
                if book==None:
                    print(comment)
                elif chap==None:
                    if not book in book2comments:
                        book2comments[book]=comment
                    else:
                        book2comments[book]+=comment
                else:
                    comment="  "+comment
                    if not book in book2chap2text:
                        book2chap2text[book] = { chap : comment }
                    elif not chap in book2chap2text[book]:
                        book2chap2text[book][chap] = comment
                    else:
                        book2chap2text[book][chap]+= comment
            else:
                fields=line.split("\t")
                if len(fields)>1:
                    id=fields[0].strip()
                    text="\t".join(fields[1:])
                    seg="    <seg id=\""+id+"\" type=\"verse\">"+text+"</seg>\n"
                    book=id[0:len("b.XYZ")]
                    chap=int(id.split(".")[2])
                    if not book in book2chap2text:
                        book2chap2text[book] = { chap : seg }
                    elif not chap in book2chap2text[book]:
                        book2chap2text[book][chap] = seg
                    else:
                        book2chap2text[book][chap] += seg

        for book in book2chap2text:
            print("<div id=\""+book +"\" type=\"book\">")
            if book in book2comments:
                print(book2comments[book])
            for chap in sorted(book2chap2text[book].keys()):
                    print("  <div id=\""+book+"."+str(chap)+"\" type=\"chapter\">")
                    print(book2chap2text[book][chap])
                    print("  </div>")
            print("</div>")




        # for line in input:
        #     line=line.strip()
        #     if line.startswith("#"):
        #         print("<!-- "+line[1:].strip()+" -->")
        #     else:
        #         fields=line.split("\t")
        #         if len(fields)>1:
        #             id=fields[0]
        #             verse="\t".join(fields[1:])
        #             mybook=id[0:len("b.XYZ")]
        #             mychap=id.split(".")[2]
        #             if book!=mybook:
        #                 if book!=None:
        #                     if chap!=None:
        #                         print("</div>")
        #                     print("</div>")
        #                 book=mybook
        #                 chap=None
        #                 print("<div id=\""+book +"\" type=\"book\">")
        #             if mychap!=chap:
        #                 if chap!=None:
        #                     print("</div>")
        #                 chap=mychap
        #                 print("<div id=\""+book+"."+chap+"\" type=\"chapter\">")
        #             print("<seg id=\""+id+"\">"+verse+"</seg>")
        # if chap!=None:
        #     print("</div>")
        # if book!=None:
        #     print("</div>")

    print('</body>\n</text>')

    # footer
    print('</cesDoc>')
