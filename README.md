## Welcome

This repo will hold **data definitions and preprocessing steps** that are necessary for analyses regarding Flemish Natura 2000 habitats and regionally important biotopes (RIBs).
The repo is set up with a special interest in the design, review and analysis of Natura 2000 habitat monitoring programmes at the Flemish scale (each is a combination of multiple monitoring schemes):

- MNE: monitoring programme for the natural environment
- MHQ: monitoring programme for biotic habitat quality

**The repo is under construction.**

## Principles and guidelines

The repo is meant to fit the draft principles and setup in [this gsheet](https://docs.google.com/spreadsheets/d/18U4AmiMnnApbgQTnfWbeZ3dAH3_4ISxUob_SX-maKV8), for long-term N2K-HAB projects.

### Organizing data

Regarding binary or text-format data: see [this list (under construction)](https://docs.google.com/spreadsheets/d/1E8ERlfYwP3OjluL8d7_4rR1W34ka4LRCE35JTxf3WMI) for metadata on dataset versions and for their source location.

The data, or the results of dataset-specific reading functions, are as much as possible internationalized:

- English names for types, environmental pressures, ...;
- English names for table headings (dataframe variables).

All `read_xxx()` functions in this repo read data from local folders:

- binary data sources are present in `../n2khab-binarydata` (this means that a folder `n2khab-binarydata` exists _next to this repository_).
These may also include _large_ text-format files, such as large rasters.
For the sake and ease of reproducibility, this folder may be uploaded to Zenodo as a whole once in a while (a few, yet unpublished datasets may also be published separately.)
Perhaps some datasets will receive a versioning system in the future, such as git LFS, if there is reason to suspect that the used versions will not be maintained in the source location in the long term.
The sources are supposed to be divided as:
    - `../n2khab-binarydata/10_input`: local copies of binary inputdata versions are to be put here;
    - `../n2khab-binarydata/20_generated`: generated binary data are put here by the code;
- data sources in text-format (not too large) are _versioned_ within this repository, in two folders:
    - `10_inputdata_textformat`: local copies of text-format inputdata versions are to be put here. Most of them come over from another repository;
    - `20_generateddata_textformat`: generated text-format data are put here by the code.
    
Each dataset is to be put in its *own subfolder* within one of the above folders.
The name of the subfolder is a fixed code (ID) according to the aforementioned [list](https://docs.google.com/spreadsheets/d/1E8ERlfYwP3OjluL8d7_4rR1W34ka4LRCE35JTxf3WMI).
As far as possible, the corresponding file(s) get the same name.

### Writing functions

See the separate [document](functionality.md) on needed functionality.


### R packages

- please use `tidyverse`, `sf` and `raster` packages for data reading and ([pipe](https://r4ds.had.co.nz/pipes.html#when-not-to-use-the-pipe-friendly)-friendly) processing.
Organise data in R in a [tidy](https://r4ds.had.co.nz/tidy-data.html#tidy-data-1) way.
Recommended resources to get started are:
    - [R for Data Science](https://r4ds.had.co.nz/)
    - [Geocomputation with R](https://geocompr.robinlovelace.net)
- preferrably use `git2rdata::write_vc()` when an R _dataframe_ needs to be written to disk for later use (see <https://inbo.github.io/git2rdata/>).
Define the sorting order well (avoid ties) by using the `sorting` argument, in order to get meaningful _diffs_ when data are updated later.
The function stores the object in a version-control + R friendly format (tab separated values (.tsv) plus metadata on sorting order and variables (.yml)).
The R object can then be 100% recreated using `git2rdata::read_vc()`.


### How to contribute code?

More detailed info on git workflows at INBO: <https://inbo.github.io/tutorials/tags/git/>

1. Make commits (in your local clone of the remote repo on Github) _in your own git branch_, branched off from the `master` branch.
(But see this in a relative manner: exactly the same process can be repeated by someone else in turn, relative to your branch)
You can push your branch to the remote as often as you like, as it will not influence other branches (`git push -u origin yourbranchname`; afterwards `git push` suffices). It serves as a backup and enables others to work with you on that branch.
1. Meanwhile, make sure that your branch stays up to date with evolutions in master (i.e. in your local repo, update master with `git checkout master && git pull` and then, with your own branch checked out again, do `git merge --no-ff master`), in order to prevent merge conflicts with master later on.
At this stage, you need to resolve any merge conflicts that may arise in your own branch.
1. Propose to merge your commits into master: this starts with making a 'pull request' (PR; actually this is a merge request) and assign at least one reviewer before a merge can be decided. At that moment, open online discussion in the repo is possible on your changes (for other open discussion that you want to start, make an _issue_). As long as no merge is performed, more commits can be added to this PR with `git push`, e.g. to implement requested changes by others.
    - note that, if you branched off another (reference) branch than `master`, make sure to change the reference branch in the pull request (the default reference is `master`).
1. After your PR is merged, pull the reference branch (usually `master`) and clean up your local repo in order to keep up with the remote.




    
