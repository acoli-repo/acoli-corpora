# Bible API: Retrieval scripts for bibles in CES/XML format(s)

`retrieve.py`

Creates a local mirror of CES/XML files with explicit segment ids (<seg id="...">) from
one or several online collections
also normalizes language identifiers to BCP47 specifications, although we don't validate against the IANA registry
So, regardless of whether you ask for "eng" or "en" and whether the Bible specifies its language as "eng" or "en",
you can retrieve an English Bible with either valid code

Note that it performs its own download routine, so, no need to clone this repo beforehand.

## Usage

When called as a standalone application, it opens in demo mode:

  $> python3 retrieve.py
     demo mode: enter a language (ISO or BCP47 code):

Use `eng` (or `en`) for English, `deu` (or `de` or `ger`) for German. We support two-letter (ISO 639-1) codes, three-letter codes (ISO 639-2 and ISO 639-3) and BCP47 codes (composed of ISO 639 codes with additions and possible extensions).
In addition, you can also use `English` and `German`, but using BCP47 codes is recommended. We use the labels provided by SIL (*as part of their definitions*), and these include additional, non-trivial additions to the proper names. So, `Old High German` will not work, but you have to search for `Old High German (ca. 750-1050)` [sic!]. Likewise, you must adhere to their use of non-ASCII characters (UTF-8, so, search for `Old Provençal (to 1500)` will work, `Old Provencal (to 1500)` will fail.)

If you enter a complex BCP47 code, e.g., `de-CH` (Standard German in Switzerland), and lookup fails, this will automatically resort to the base code (`de`).

Programmatically, use it as a library:

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

        $> r.configure(format="json")
        $> r.get("eng",1)
        # return json string (instead of default Python dict)

        $> r.configure(format="text")
        $> r.get("eng",1)
        # text output, TSV format with VERSE<TAB>TEXT and document id as comment

        $> r.configure(format="conll")
        $> r.get("eng",1)
        # text output, TSV format with ID<TAB>WORD, note that we do whitespace tokenization only, so punctuation is not stripped

        # for gazeteer-based annotation:
        # get the same normalization with
        $> r.preprocess("this is another (small, ...) Fragment to be compared with")

Note that you can use the actual name of the language (case-independent) instead of ISO/BCP47 codes. The language names are those used by SIL.

## TODO

Can be extended to build other Bibles on-the-fly, in particular:
- wrapper around ACoLi build scripts
