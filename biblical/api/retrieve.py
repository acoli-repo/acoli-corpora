import sys,re,os,io,traceback,argparse
import requests,zipfile,json
from pprint import pprint
import urllib.parse
from os.path import expanduser

""" creates a local mirror of CES/XML files with explicit segment ids (<seg id="...">) from
    one or several online collections
    also normalizes language identifiers to BCP47 specifications, although we don't validate against the IANA registry
    So, regardless of whether you ask for "eng" or "en" and whether the Bible specifies its language as "eng" or "en",
    you can retrieve an English Bible with either valid code

    usage:

        $> r=Retriever()
        # initialize with default configuration, this may take a while for the first run as it initializes the local cache

        $> r.get("eng",1)
        # get one English bible
        # return object is a dict with ID -> VERSE -> text
        # ID: collection id "/" BCP47 language ID "/" file name
        # VERSE: "b" "."  BOOK "." CHAP_NR "." VERSE_NR
        #        with BOOK a 3-letter code

        $> r.configure(keep_comments=False)
        # configure output normalization and print configuration: remove content in parentheses

        $> r.get("eng",1)
        # compare the output ;)

        $> r.configure(drop_punctuation=False)
        $> r.get("eng",1)
        # use this as an alternative to tokenization, strips off punctuation symbols and replaces them by whitespaces

        # for gazeteer-based annotation:
        # get the same normalization with
        $> r.preprocess("this is another (small, ...) Fragment to be compared with")

    """

def get_closest_strings(goal,cands):
    """ unigram similarity """
    if goal in cands:
        return [goal]

    result=[]
    sim=0
    for cand in cands:
        mysim=0
        for x in goal:
            if x in cand:
                mysim+=1
        if mysim>sim:
            result=[]
            sim=mysim
        if mysim==sim:
            result.append(cand)

    return result

class Retriever:

    formats=["dict","text","conll","json"]

    src2conf={
        # full acoli data
        "acoli" : { "url" : "https://github.com/acoli-repo/acoli-corpora/raw/master/biblical/data/", "file_filter" : r".*xml$", "skip_dir_pattern": r".*/zips.*" },

        # subsets, examplary (use url(s), file_filter and skip_dir pattern to define your own subcorpora!)
        "acoli-en" : { "url" : "https://github.com/acoli-repo/acoli-corpora/raw/master/biblical/data/germ/en_modern-english/","file_filter" : r".*xml$", "skip_dir_pattern": r".*/zips.*"},
        "acoli-germ" : { "url" : "https://github.com/acoli-repo/acoli-corpora/raw/master/biblical/data/germ/","file_filter" : r".*xml$", "skip_dir_pattern": r".*/zips.*"},
        "acoli-ide" : { "urls" : [ "https://github.com/acoli-repo/acoli-corpora/raw/master/biblical/data/germ/", "https://github.com/acoli-repo/acoli-corpora/raw/master/biblical/data/indoeuropean-other/"], "file_filter" : r".*xml$", "skip_dir_pattern": r".*/zips.*"},

        # other collections

        # 100bib: these are mirrorred in acoli, use the original if you prefer, as these may be more recent.
        # notes: included in acoli (and subcollections), but these may be more recent
        "100bib" : { "url" : "https://github.com/christos-c/bible-corpus/tree/master/bibles", "file_filter" : r".*xml$" },

        # resnik: the prototype for these Bible corpora, most of these Bibles have no copyright clearance
        # issues: - this is not XML, but SGML
        #         - language identifiers for Cebuano, Danish, Greek and French are broken, Swahili bible doesn't resolve anymore
        #         - encoding for Greek is broken (Greek-Latin mixture)
        #         - non-Unicode data, but converter expects Unicode
        #         - untested and unlikely to perform well (at least not for every language)
        "resnik" : { "url" : "http://users.umiacs.umd.edu/~resnik/parallel/bible.html" , "file_filter" : None }
    }

    lang2src2bibles={}

    touched_uris=[]

    def crawl(self, uriOrConf, tgt_dir=None, pfxes=[], langs=None, depth=-1):
        """ call crawl with some prefigurations, neg depth is infinite """

        uri=None
        conf={}

        if type(uriOrConf)==str:
            uri=uriOrConf
        else:
            conf=uriOrConf
            if "url" in conf:
                uri=conf["url"]
            else:
                if "urls" in conf:
                    for url in conf["urls"]:
                        conf["url"]= url
                        self.crawl(conf,tgt_dir,pfxes, langs)
                    if len(conf["urls"])>0:
                        return
                else:
                    raise Exception("configuration needs one of the keys \"url\" (string, single url) or \"urls\" (list of urls)\n")

        if tgt_dir==None:
            tgt_dir=self.cache_dir

        if "github.com" in uri:
            template=uri
            modes=["/raw/", "/tree/", "/blob/"]
            for mode in modes:
                if mode in uri:
                    template=uri.split(mode)
                    template="/".join([template[0],"MODE",mode.join(template[1:])])
                    break
            if "/MODE/" in template:
                template="/".join(template.split("/")[0:-1])+"/"
                for mode in modes:
                    pfxes.append(re.sub("/MODE/",mode,template))
                pfxes.append(re.sub("github.com","raw.githubusercontent.com", template.split("/MODE/")[0]))
            else:
                pfxes.append(re.sub("github.com","raw.githubusercontent.com", template))

        self._crawl(uri,tgt_dir, pfxes,langs,conf,depth)

    def _crawl(self,uri,tgt_dir, pfxes=[],langs=None,conf=None, depth=-1):
        """ crawl uri recursively, use CES/XML metadata to determine language, if names collide print a warning
            using pfxes, you can define which directories to follow;
            note that for githup, you need to provide all several pairs of URIs:
            - data (.../blob/master/...),
            - crawling (.../tree/master/...),
            - small file download URI (https://github.com/.../.../raw/master/...),
            - large file download URI (https://raw.githubusercontent.com/.../.../master/)

            file filter is a restriction on names of files names to be retrieved

            negative depth is infinite """

        if uri in self.touched_uris or uri.strip()=="":
            return None

        self.touched_uris.append(uri)
        display_uri=uri
        if len(display_uri)>100:
            display_uri=display_uri[0:97]+"..."
        while len(display_uri)<100:
            display_uri+=" "
        sys.stderr.write(display_uri+"\r")
        sys.stderr.flush()

        r=None
        try:
            r=requests.get(uri,headers={"Range": "bytes=0-250" , 'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36' } )
        except:
            traceback.print_exc()
            sys.stderr.write("while opening "+uri+"\n")
            sys.stderr.flush()

        # HTML => recursion
        if r!=None and not r:
            sys.stderr.write(uri+": error when trying to access: "+str(r)+"         \n")
            sys.stderr.flush()
        if r:
            if "<html" in r.text.lower():
                if pfxes==None:
                    pfxes=[]
                pfx="/".join(uri.split("/")[0:-1])+"/"
                if not pfx in pfxes:
                    pfxes.append(pfx)

                sys.stderr.flush()

                r=requests.get(uri,headers={'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36' })
                uris=[]
                for string in r.text.split():
                    if string.lower().startswith("href="):
                        string='"'.join(string.split("'"))
                        href=string.split('"')[1].strip()
                        for symbol in ["#","?"]:
                            if symbol in href:
                                if href.startswith(symbol):
                                    href=""
                                else:
                                    href=href[0:href.index(symbol)]
                        href=href.strip()
                        if len(href)>1:
                            href=urllib.parse.urljoin(uri, href, allow_fragments=False)
                        if not href in uris :
                            if not href in self.touched_uris :
                                if not conf or not "skip_dir_pattern" in conf or not conf["skip_dir_pattern"] or not re.match(conf["skip_dir_pattern"],href):
                                    for pfx in pfxes:
                                        if href.startswith(pfx):
                                            uris.append(href)
                                            break

                if depth!=0:
                    for uri in uris:
                        self._crawl(uri,tgt_dir,pfxes,langs,conf,depth-1)

            # otherwise: check if CES/XML with language code
            elif  not conf or not "file_filter" in conf or conf["file_filter"]==None or re.match(conf["file_filter"], uri):
                # zip archives (here: lang codes only)
                if uri.lower().endswith("zip"):
                    myTgt=tgt_dir+"/"+uri.split("/")[-1]
                    with open(myTgt,"wb") as out:
                        r=requests.get(uri,headers={'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36' } )
                        out.write(r.content)
                        sys.stderr.write(uri+" => "+myTgt+"\n")
                        sys.stderr.flush()

                # CES, CES/XML
                elif "<cesdoc" in r.text.lower():
                    r=requests.get(uri,headers={'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36' } )
                    norm=r.text
                    lang=""
                    if not "<body" in norm:
                        norm=norm.lower()
                    if not "<body" in norm:
                        sys.stderr.write(uri+": warning: found no <body> element, skipping\n")
                    else:
                        norm=r.text[0:r.text.index("<body")].lower()
                        if 'iso639=' in norm:
                            lang=norm.split("iso639=")[1][0:20]
                            lang='"'.join(lang.split("'"))
                            lang=lang.split('"')[1].lower().strip()
                            if lang!="":
                                if not re.match(r"^[a-z][a-z][a-z]?$",lang):
                                    sys.stderr.write(uri+": warning: invalid ISO 639 language code \""+lang+"\"\n")
                                    lang=""
                        if lang=="":
                            if "lang=" in norm:
                                sys.stderr.write(uri+": warning: no ISO language code found, resort to @lang\n")
                                lang=norm.split("lang=")[1][0:20]
                                lang='"'.join(lang.split("'"))
                                lang=lang.split('"')[1].lower().strip()
                                if lang!="":
                                    if not re.match(r"^[a-z][a-z][a-z]?$",lang):
                                        sys.stderr.write(uri+": warning: invalid ISO 639 language code \""+lang+"\" in @lang\n")
                                        lang=""
                        if lang=="":
                            sys.stderr.write(uri+": warning: no ISO language code found, skipping\n")
                        else:
                            lang=self.normalize_lang(lang,"bcp47")[0]

                            if langs==None or len(lang)==0 or lang in langs:
                                myTgt=tgt_dir+"/"+lang+"/"+uri.split("/")[-1]
                                if not myTgt.lower().endswith("xml"):
                                    myTgt+=".xml"    # this is a workaround for Resnik's SGML bibles
                                sys.stderr.write(uri+" => "+myTgt+"\n")
                                if not os.path.exists(tgt_dir+"/"+lang):
                                    os.makedirs(tgt_dir+"/"+lang)
                                if os.path.exists(myTgt):
                                    sys.stderr.write(display_uri.strip()+": warning: found "+myTgt+", keeping it\n")
                                else:
                                    with open(myTgt,"w") as out:
                                        out.write(r.text)
                                        out.write("\n")
                                    with open(myTgt+".url","w") as out:
                                        out.write(uri+"\n")

                                #print("OUT",uri,lang)
                #     print(r.text)
                # print()
        sys.stderr.flush()
        return None

    code2src2tgt2code = None
    # maps src schema code to tgt schema code
    # note that the order or src and tgt schemas defines a selection preference

    def normalize_lang(self, codeOrCodes, schema="bcp47", src_schema=None):
        """ retrieve language codes if not populated yet.
            response:
            [] if code found but no target schema mapping
            error if code not found
            otherwise list (!) of codes [can be 1:m]
        """

        code2src2tgt2code=self.code2src2tgt2code

        # initialize codes

        if code2src2tgt2code==None or len(code2src2tgt2code)==0:
            code2src2tgt2code={}
            zipdir=self.cache_dir+"/lang_codes/"
            if not os.path.exists(zipdir):
                sys.stderr.write("caching ISO language codes in "+zipdir+", delete to refresh\n")
                sys.stderr.flush()

                os.makedirs(zipdir)
                iso639_3_conf={ "url" : "https://iso639-3.sil.org/code_tables/download_tables" , \
                                "file_filter" : r"^https://iso639-3.sil.org/sites/iso639-3/files/downloads/iso-639-3_Code_Tables_20[2-9][0-9][01][0-9][0-3][0-9].zip$" }
                self.crawl( iso639_3_conf, zipdir, pfxes=["https://iso639-3.sil.org/sites/iso639-3/files/downloads/"], depth=1 )

                # succeeded ?
                if len( [ file for file in os.listdir(zipdir) if file.lower().endswith("zip") ]) == 0:
                    sys.stderr.write("warning: automated retrieval of download link failed, resorting to version of 2021-02-18\n")
                    sys.stderr.flush()
                    self.crawl("https://iso639-3.sil.org/sites/iso639-3/files/downloads/iso-639-3_Code_Tables_20210218.zip",zipdir,depth=0)

            for file in os.listdir(zipdir):
                try:
                    file=zipdir+"/"+file
                    if file.lower().endswith("zip"):
                        with zipfile.ZipFile(file, "r") as zipped:
                            for tabfile in zipped.namelist():
                                additions=[]
                                if tabfile.endswith("iso-639-3.tab"):
                                    with zipped.open(tabfile,"r") as input:
                                        input.readline() # skip header
                                        for line in input:
                                            line=line.decode("utf-8").strip()
                                            line=re.sub(r"  +",r"\t",line)
                                            fields=line.split("\t")

                                            schema2code=[("iso639_3",fields[0].strip())]
                                            if len(fields[1].strip())>0:
                                                schema2code+=[("iso639_2B",fields[1].strip())]
                                            if len(fields[2].strip())>0:
                                                schema2code+=[("iso639_2T",fields[2].strip())]
                                            if len(fields[3].strip())>0:
                                                schema2code+=[("iso639_1",fields[3].strip())]
                                            if len(fields[6].strip())>0:
                                                schema2code+=[("label",fields[6].lower().strip())]

                                            for src,scode in schema2code:
                                                for tgt,tcode in schema2code:
                                                    additions.append((scode,src,tgt,tcode))

                                if tabfile.endswith("iso-639-3_Retirements.tab"):
                                    with zipped.open(tabfile,"r") as input:
                                        input.readline() # skip header
                                        for line in input:
                                            line=line.decode("utf-8").strip()
                                            fields=line.split("\t")

                                            scode=fields[0]
                                            tcode=fields[3]
                                            if tcode.strip()=="":
                                                # keep outdated identifiers without replacement as identifiers
                                                additions.append((scode,"iso639_3", "iso639_3", scode))
                                            else:
                                                additions.append((scode,"iso639_3", "iso639_3",tcode))

                                if tabfile.endswith("iso-639-3-macrolanguages.tab"):
                                    with zipped.open(tabfile,"r") as input:
                                        input.readline() # skip header
                                        for line in input:
                                            line=line.decode("utf-8").strip()
                                            fields=line.split("\t")
                                            if len(fields)>1:
                                                scode=fields[1].strip()
                                                tcode=fields[0].strip()
                                                additions.append((scode,"iso639_3", "iso639_3M", tcode))

                                for scode,src,tgt,tcode in additions:
                                    if not scode in code2src2tgt2code:
                                        code2src2tgt2code[scode] = { src : { tgt : tcode }}
                                    elif not src in code2src2tgt2code[scode]:
                                        code2src2tgt2code[scode][src] = { tgt : tcode }
                                    elif not tgt in code2src2tgt2code[scode][src]:
                                        code2src2tgt2code[scode][src][tgt] = tcode
                                    else:
                                        sys.stderr.write("warning: failed to overwrite "+tgt+" code "+code2src2tgt2code[scode][src][tgt]+" with "+tcode+"\n")
                                        sys.stderr.flush()

                except:
                    traceback.print_exc()
                    sys.stderr.write("while accessing "+file+"\n")
                    sys.stderr.flush()

            # transitive closure of code2src2tgt2code macro-families
            if code2src2tgt2code  != None:
                additions=[]
                for scode in code2src2tgt2code:
                    for src in code2src2tgt2code[scode]:
                        if "iso639_3M" in tgt:
                            tcode=code2src2tgt2code[scode][src]["iso639_3M"]
                            if tcode in code2src2tgt2code:
                                if "iso639_3" in code2src2tgt2code[tcode]:
                                    for schema in code2src2tgt2code[tcode]["iso639_3"]:
                                        if not schema in code2src2tgt2code[scode]["iso639_3"]:
                                            additions.append((scode,"iso639_3",schema,tcode))

                for scode,src,tgt,tcode in additions:
                    if not scode in code2src2tgt2code:
                        code2src2tgt2code[scode] = { src : { tgt : tcode }}
                    elif not src in code2src2tgt2code[scode]:
                        code2src2tgt2code[scode][src] = { tgt : tcode }
                    elif not tgt in code2src2tgt2code[scode][src]:
                        code2src2tgt2code[scode][src][tgt] = tcode
                    else:
                        sys.stderr.write("warning: failed to overwrite "+tgt+" code "+code2src2tgt2code[scode][src][tgt]+" with "+tcode+"\n")
                        sys.stderr.flush()

            # pprint(code2src2tgt2code)

            self.code2src2tgt2code=code2src2tgt2code

        # retrieve code

        if type(codeOrCodes)!=str:
            result=[]
            for code in codeOrCodes:
                result+=self.normalize_lang(code,schema=schema,src_schema=src_schema)
            return sorted(set(result))

        code=codeOrCodes.lower()

        if schema=="bcp47":
            if code in code2src2tgt2code:
                src_schemas=["iso639_1", "iso639_2T", "iso639_2B", "iso639_3", "label"]
                if src_schema!=None:
                    if src_schema in code2src2tgt2code[code]:
                        src_schemas=[src_schema]
                    else:
                        sys.stderr.write("warning: \""+code+"\" is not a "+src_schema+" code, extend search\n")
                        sys.stderr.flush()
                try:
                    for schema in ["iso639_1", "iso639_2T", "iso639_2B", "iso639_3"]:
                        result=self.normalize_lang(code,schema=schema)
                        if result!=None and len(result)>0:
                            return result
                except: pass
            if not "-" in code:
                sys.stderr.write("warning: unknown language code \""+code+"\", we use "+"mis-x-unknown-"+code+", instead\n")
                sys.stderr.flush()
                return [ "mis-x-unknown-"+code ]

        if "-" in code:
            sys.stderr.write("warning: no match for full BCP47 code \""+code+"\", reducing to "+code[0:code.index("-")]+"\n")
            sys.stderr.flush()
            return self.normalize_lang(code[0:code.index("-")])

        if code in code2src2tgt2code:
            for src in code2src2tgt2code[code]:
                if schema in code2src2tgt2code[code][src]:
                    return [ code2src2tgt2code[code][src][schema] ]
            return []
        else:
            raise Exception("code \""+code+"\" not found, did you mean any of "+", ".join(get_closest_strings(code,code2src2tgt2code.keys()))+"?")

    def get(self, lang, results=1, src=None, file_pattern=None):
            """ return dictionary: file_name -> verse_id -> text
            src is a string that restricts results to a particular collection
            file_pattern is a string or regexp that restricts results (operates on base name)
            results can limit the number of responses, with results < 1, return all results
            keep_comments if False, omit all content in parentheses
            drop_punctuation strip off punctuation symbols
            """

            langs=None
            if lang!=None:
                langs=self.normalize_lang(lang)

            result={}
            for collection in os.listdir(self.cache_dir):
                if src==None or re.match(src,str(collection)):
                    collection=self.cache_dir+"/"+collection
                    for dir in os.listdir(collection):
                        if dir in langs:
                            dir=collection+"/"+dir
                            for file in os.listdir(dir):
                                if file.lower().endswith("xml"):
                                    if file_pattern==None or re.match(file_pattern, file):
                                        file=dir+"/"+file
                                        verse2text={}
                                        with open(file,"r") as input:
                                            text=re.sub(r"\s+"," ", input.read())
                                            text=text.split("</seg>")
                                            for line in text:
                                                if "<seg" in line:
                                                    line=line[line.index("<seg"):]
                                                    if " id=" in line:
                                                        id=[ term for term in line.split(" ") if term.startswith("id=")][0]
                                                        id='"'.join(id.split("'"))
                                                        id=id.split('"')[1].strip()
                                                        if len(id)>0 and id[0]=="b":

                                                            string=self.preprocess(line)

                                                            if not id in verse2text:
                                                                verse2text[id]=string
                                                            else:
                                                                verse2text[id]+=" "+string
                                        result["/".join(file.split("/")[-3:])]=verse2text
                                        if len(result)==results:
                                            return self._format(result)
            return self._format(result)

    cache_dir=str(os.path.join(expanduser("~"),"Downloads","bibles"))

    config={
        "keep_comments" : True,         # if false, remove content of paired (and, heuristically, unpaired) parentheses
        "drop_punctuation" : False ,    # drop punctuation, insert whitespaces
        "lower": False,                 # lower case
        "format": "dict"                # return format, "dict" is a python object
        }

    def _format(self, result: dict):
        """ for serializing bible results
            note that conll mode performs whitespace tokenization only, so punctuation (etc.) is only treated as separate punctuation if it is surrounded by whitespaces
         """
        format=self.config["format"]
        if format=="dict":
            return result

        if format=="json":
            return json.dumps(result)

        if format=="text":
            output=""
            for id in result:
                output+="# document "+id+"\n"
                for verse in result[id]:
                    output+=verse+"\t"+result[id][verse]+"\n"
                output+="\n"
            return output

        if format=="conll":
            output=""
            for id in result:
                for verse in result[id]:
                    output+="# doc_id = "+id+"\n"
                    output+="# sent_id = "+verse+"\n"
                    output+="# text = "+result[id][verse]+"\n"
                    for nr,token in enumerate(result[id][verse].split()):
                        output+=str(nr+1)+"\t"+token+"\n"
                    output+="\n"
                output+="\n"
            return output


        raise Exception("unsupported return format \""+format+"\"")

    formats=["dict","text","conll","json"]


    def configure_output(self, keep_comments=None, drop_punctuation=None, lower=None, format=None):
        if keep_comments!=None:
            self.config["keep_comments"] = keep_comments
        if drop_punctuation!=None:
            self.config["drop_punctuation"] = drop_punctuation
        if lower!=None:
            self.config["lower"] = lower
        if format!=None:
            self.config["format"] = format
        sys.stderr.write("Retriever.config = "+str(self.config)+"\n")
        sys.stderr.flush()


    def preprocess(self, line:str):
                                                            """ configure with configure_output() """
                                                            string=line
                                                            string=re.sub(r"<[^>]*>","",string)

                                                            if not self.config["keep_comments"]:
                                                                # remove paring parentheses
                                                                string=re.sub(r"\([^\)]*\)","",string)
                                                                string=re.sub(r"{[^}]*}","",string)
                                                                string=re.sub(r"\[[^\]]*\]","",string)

                                                                # remove unpaired parentheses
                                                                string=re.sub(r".*[\)}\]>]","",string)
                                                                string=re.sub(r"[\({}\[<].*","",string)

                                                            if self.config["drop_punctuation"]:
                                                                string=re.sub(r"\s*[\"'-.,:;?!(){}\[\]/]\s*"," ",string)

                                                            if self.config["lower"]:
                                                                string=string.lower()

                                                            string=string.strip()
                                                            return string


    def __init__(self, cache_dir=None, sources=None, langs=None, format=None, keep_comments=None, drop_punctuation=None, lower=None):

        self.configure_output(keep_comments=keep_comments, drop_punctuation=drop_punctuation, lower=lower, format=format)

        if cache_dir!=None:
            self.cache_dir=cache_dir

        cache_dir=self.cache_dir
        src2conf=self.src2conf

        if langs!=None:
            langs=self.normalize_lang(langs)

        if sources==None:
            sources=list(src2conf.keys())
            sys.stderr.write("warning: no sources defined, we default to "+sources[0]+", other options: "+", ".join(sources[1:])+"\n")
            sources=sources[0:1]
            sys.stderr.flush()
        for src in sources:
            if not src in src2conf:
                sys.stderr.write("warning: "+src+" is not a predefined source \""+src+"\" ("+", ".join(sorted(src2conf.keys()))+"), assume this is a user-defined URI\n")
                sys.stderr.flush()
                try:
                    tgt_dir=cache_dir+"/user_defined/"
                    self.crawl(src,tgt_dir, langs=langs)
                except:
                    traceback.print_exc()
            else:
                tgt_dir=cache_dir+"/"+src
                sys.stderr.write("store source \""+src+"\" ("+src2conf[src]["url"]+") in "+tgt_dir+"/\n")
                sys.stderr.flush()
                if os.path.exists(tgt_dir):
                    sys.stderr.write("warning: found cache directory "+tgt_dir+", to refresh cache, delete it first\n")
                    sys.stderr.flush()
                else:
                    os.makedirs(tgt_dir)
                    self.crawl(src2conf[src],tgt_dir, langs=langs)

if __name__ == '__main__':
    # demo mode

    formats=Retriever.formats

    args=argparse.ArgumentParser("retrieve Bibles from various web sources, from command-line: retrieve first Bible per language")
    args.add_argument("id", nargs="?", type=str, help="language to return a Bible for, if none, go to interactive (demo) mode", default=None)
    args.add_argument("-subset", "--collections", type=str, action="extend", nargs="*", help="URI(s) or collection identifier(s), as for the latter, chose one of "+", ".join(Retriever.src2conf.keys()))
    args.add_argument("-c", "--cache_dir", type=str, help="directory to host locally cached Bibles, defaults to "+Retriever.cache_dir+".", default=Retriever.cache_dir)
    args.add_argument("-l", "--langs", type=str, action="extend", nargs="*", help="one or multiple languages, we recommend BCP47 codes", default=None)
    args.add_argument("-f", "--format", type=str, help="output format, one of "+", ".join(formats)+", defaults to "+formats[0], default=formats[0])
    args.add_argument("-no_comments", "--remove_comments", action="store_true", help="remove content in parentheses")
    args.add_argument("-no_punct", "--drop_punctuation", action="store_true", help="strip off punctation sings")
    args.add_argument("-lower", "--lower_case", action="store_true", help="lower case")
    args=args.parse_args()

    r = Retriever(cache_dir=args.cache_dir, sources=args.collections, langs=args.langs, format=args.format, keep_comments=not args.remove_comments, drop_punctuation=args.drop_punctuation, lower=args.lower_case)

    if args.id!=None:
        print(r.get(args.id))

    else:
        sys.stderr.write("\ninteractive mode: enter a language (ISO 639 code, BCP47 code, language name) or terminate with <ENTER>: ")
        sys.stderr.flush()
        for line in sys.stdin:
            line=line.strip()
            if line=="":
                sys.stderr.write("bye!")
                sys.exit(0)
            lang=line
            print(r.get(lang,1))
            sys.stderr.write("\ninteractive mode: enter a language (ISO 639 code, BCP47 code, language name) or terminate with <ENTER>: ")
            sys.stderr.flush()
