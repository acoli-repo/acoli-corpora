# Grimm, Kinder- und Hausmärchen

- de (1857) (7.Ausgabe, letzter Hand)
	- `de/`: `cd de/; make 1857`
	- `nds/`: `cd de/; make 1857` (sic!)
- en (1884, translated from de 1857, https://en.wikisource.org/wiki/Grimm%27s_Household_Tales,_Volume_1)
	- `en/`: `cd en/; make 1884`
- en (1823, translated from de 1812)
	- `en/*1823-alm.md`: manually derived from http://people.rc.rit.edu/~coagla/affectdata/index.html, automated mapping with `en/*1884.md` by (match-files.py)[../../scripts/match-files.py] with ngram size 5 in [alm2khm.tsv](alm2khm.tsv)
- de (1812/15) (1. Ausgabe), automatically build (`cd de/; make 1812`), but IDs semiautomatically mapped
	- `de/`: mapping with score < 0.5 manually, using https://khm.li/)
	- `nds/`: `mv $(egrep -l -i ' dat ' de/*.md) nds/`

## Known issues

- in the German 1857 version, our file khm-152 is actually  KHM-151\* and all the following numbers are set off by 1. This is also true for anything aligned with the German 1857 verson (i.e. for *all* data)
	- until it is confirmed that this offset is a systematic error: **ONLY USE FILES until khm-150!!!**
	- for the "official" numbering see https://khm.li/