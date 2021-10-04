# ACoLi Corpora

Various open source corpora assembled, annotated or maintained by the Applied Computational Linguistics (ACoLi) group at Goethe University Frankfurt, Germany.

Note that some of the data provided here is separately maintained, so that this repo uses the `submodule` functionality of git.
However, the aggregator repository is updated occasionally, only, to point to the most recent version. To retrieve the most up-to-date versions, clone this repo using

    $> git clone --recurse-submodules --remote-submodules https://github.com/acoli-repo/acoli-corpora

For updating an existing installation in the directory `./acoli-corpora/`, run

    $> cd ./acoli-corpora/
    $> git submodule update --recursive .

Note that these repositories do not have strong interdependencies in the aggregator, but that this has been mostly created to faciliate a quick-and-easy local setup of all
corpora in one go. For development or annotation, we recommend to work within the submodule repositories directly.
