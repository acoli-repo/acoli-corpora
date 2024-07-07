# Stating Area for Grimm

## www.grimmstories.com

[**DONE**], partially hand-corrected and integrated with `../../grimm`

massively multilingual, but no sources are provided. these are thus reconstructed by an online search for the oldest matching full text for texts in which we find some variation using Google Books and Google. Note that any potential source published after May 2006 may actually have been taken *from* the website instead, because that is when www.grimmstories.com was [registered](https://www.duplichecker.com/domain-age-checker.php)). In particular, this is the case for obscure bulk eBooks without additional artwork. However, these eBooks typically cost 0.99€, the original sources are in the public domain and the language is designed to be simple so that the creative height might not even be sufficient to count in court, so there is absolutely no financial risk here.

- German (de)
	- Jacob und Wilhelm Grimm (2020). Grimms Märchen – Vollständig überarbeitete Ausgabe in HD. Null Papier Verlag, 10. Dezember 2020, 1. Auflage
		- confirmed for the High German text of Dat Maeken von Brakel. In all original editons, this was Low German, and this High German translation is a perfect match, and the only match). The edition is recent, but there is no financial risk, as the commercial price is 0.99€ (https://null-papier.de/shop/grimms-maerchen-vollstaendig-ueberarbeitete-ausgabe-in-hd/)
- English (en)
	- Lucy Crane and Walter Crane (1882), Household Stories, from the Collection of the Bros. Grimm (1882)
		- confirmed for "The rabbit's bride"
- Danish (da)
	- Jacob und Wilhelm Grimm (1970), Grimms Eventyr, Selected and translated by Anine Rud, Gyldendal
		- based on Rotkäppchen
- Greek (el)
	- a modern children's edition from https://www.alexandfriends.gr/en/fairytales/. Copyright Alex'n'Friends 
		- tested on Froschkönig, contains original art
- Spanish (es)
	- maybe Cuentos escogidos de los Hermanos Grimm (José S. Viedma, trad.). Madrid: Gaspar editores. 1879. ?
		- The text of Froschkönig is identical to a 2015 eBook without declaration of provenance (which may actually be taken from www.grimmstories.com)
- Finnish
	- https://www.gutenberg.org/ebooks/45046, Jakob ja Wilhelm Grimm (1876), KOTI-SATUJA LAPSILLE JA NUORISOLLE, Saksan-kielestä suomentanut J. A. Hahnsson, K. E. Holm, Helsinki, 1876. 
- Polish
	- probably 1940 or 1929 (https://pl.wikisource.org/wiki/Autor:Bracia_Grimm, 1940 translator [died 1925](https://pl.wikipedia.org/wiki/Cecylia_Niewiadomska), 1929 translator [died 1928](https://pl.wikipedia.org/wiki/Boles%C5%82aw_Londy%C5%84ski))

We keep the metadata as is. Because we have multiple versions of the same text in German and English, we manually provide the following metadata for these languages

- de: Jacob und Wilhelm Grimm (2020). Grimms Märchen – Vollständig überarbeitete Ausgabe in HD. Null Papier Verlag, 10. Dezember 2020, 1. Auflage
- en: Lucy Crane and Walter Crane (1882), Household Stories, from the Collection of the Bros. Grimm (1882)

- `file2khm.tsv` created by running `../../scripts/match-files.py` over `grimm/de` (1857 and 1812; alignment was primarily with 1857) and `grimm/en` (1884, 1823-alm; alignment was primarily with 1857), where these disagreed (incl. all Low German texts), I aligned manually against `grimm/de`.