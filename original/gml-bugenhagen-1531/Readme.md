# Bugenhagen's Middle Low German Passion of Christ (1531)

Johannes Bugenhagen's Passion of Christ is a Middle Low German gospel harmony and commentary. Note that various translations of this text exist, including 16th c. Danish and modern English. This digital edition was created by Christian Chiarcos and colleagues at the Applied Computational Linguistics (ACoLi) lab at Goethe University Frankfurt, Germany, in an effort to provide test data for experiments in annotation projection. 

## Edition

This edition provides:
- Transcript of the Middle Low German text (manually typed). Note that the transcript maintains the original line breaks, but only as whitespaces, not as markup elements. Also note that some ligatures have been resolved at this level. No other normalization has been taking place. 
- Simplified transcript, with ligatures expanded and side-notes dropped
- TEI-compliant basic format. Note that for Bible verses, we do not use @xml:id (which *identifies* a verse), but instead introduce two novel attributes that refer to the *canonical* (Biblical) verse: @id (for cross-references with a single verse) and @altid (for cross-references with additional verses, in particular, partial matches)
- Both transcripts are aligned with the corresponding Bible passages, re-using the ID schema of https://github.com/acoli-repo/acoli-corpora/tree/master/biblical.

The specific value of this edition is its alignment with Bible verses, and these make it ideal for projection and alignment experiments on Middle Low German. 

Released to the public at Easter 2020. Distributed as open data under CC-BY (de), see LICENSE and attribution below.

## Attribution

For redistribution as data, please give attribution to Christian Chiarcos, https://github.com/acoli-repo/acoli-corpora.

When using this data in scientific publications, please refer to the following publications:

* Chiarcos, C., et al. (2014). New technologies for Old Germanic. Resources and research on parallel Bibles in older continental Western Germanic. In Proceedings of the 8th Workshop on Language Technology for Cultural Heritage, Social Sciences, and Humanities (LaTeCH) (pp. 22-31).

* Sukhareva, M., & Chiarcos, C. (2016). Combining ontologies and neural networks for analyzing historical language varieties. a case study in middle low German. In Proceedings of the Tenth International Conference on Language Resources and Evaluation (LREC'16), pp. 1471-1480.


