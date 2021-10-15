# Bible API: Retrieval scripts for bibles in CES/XML format(s)

`retrieve.py`

Creates a local mirror of CES/XML files with explicit segment ids (<seg id="...">) from
one or several online collections
also normalizes language identifiers to BCP47 specifications, although we don't validate against the IANA registry
So, regardless of whether you ask for "eng" or "en" and whether the Bible specifies its language as "eng" or "en",
you can retrieve an English Bible with either valid code

Note that it performs its own download routine, so, no need to clone this repo beforehand.

## Usage

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

## TODO

Can be extended to build other Bibles on-the-fly, in particular:
- wrapper around ACoLi build scripts
