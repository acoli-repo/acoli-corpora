# Grimm, Kinder- und Hausmärchen

- de (1857) (7.Ausgabe, letzter Hand)
	- `de/`: `cd de/; make 1857`
	- `nds/`: `cd de/; make 1857` (sic!)
- en (1884, translated from de 1857, https://en.wikisource.org/wiki/Grimm%27s_Household_Tales,_Volume_1)
	- `en/`: `cd en/; make 1884`
- en (1823, translated from de 1812)
	- `en/*1823-alm.md`: manually derived from http://people.rc.rit.edu/~coagla/affectdata/index.html, automated mapping with `en/*1884.md` by (match-files.py)[../../scripts/match-files.py] with ngram size 5