## Welcome

This repo will hold _the **n2khabutils** R package with data definitions and preprocessing functions_, useful for analyses regarding Flemish Natura 2000 habitats and regionally important biotopes (RIBs).
Apart from the package, some housekeeping workflows are provided, such as installing the package, updating some of the text data, datachecks for the workflows and the creation of some of the (generated) binary data.
The repo is set up with a special interest in the design, review and analysis of Natura 2000 habitat monitoring programmes at the Flemish scale (each is a combination of multiple monitoring schemes):

- MNE: monitoring programme for the natural environment
- MHQ: monitoring programme for biotic habitat quality

_The ultimate aim is to achieve open and reproducible data workflows. That is a prerequisite for qualifiable science, for sharing and for broad cooperation._


## Getting started

The repo is meant to fit the draft principles and setup in [this googlesheet](https://docs.google.com/spreadsheets/d/18U4AmiMnnApbgQTnfWbeZ3dAH3_4ISxUob_SX-maKV8), for long-term N2KHAB projects.

Summarizing schemes of the setup:

- relationships between possible, future [repositories](https://drive.google.com/open?id=1RQsjxch0YKdqJSPIDjCG_wEbYTlP3oDv);
- data storage and versioning [workflows](https://drive.google.com/open?id=1xZz9f9n8zSUxBJvW6WEFLyDK7Ya0u4iN).

### Find your way: repository structure

This is the structure of the repo:

```
├── data                    <- Binary or large data! Copy needed data here. IGNORED by git.
    ├── 10_raw
    ├── 20_processed        <- Either copy from a source location, or generate yourself.
├── src                     <- Put scripts / R markdown files here.
├── n2khabutils             <- R-package
    ├── inst
        ├── textdata        <- Textual data delivered with the package (in vc-format).
                               They can be read into R by package functions or with
                               git2rdata::read_vc().
    ├── man
    ├── R                   <- Package functions are to be made here.
    ├── DESCRIPTION
    ├── n2khabutils.Rproj   <- RStudio project file for convenient package management
    ├── NAMESPACE
    ├── LICENSE
├── datamanagement.md       <- How data are organized and stored
├── functionality.md        <- Functionality needed in this and associated n2khab-repos
├── n2khab-inputs.Rproj     <- Main RStudio project file
├── README.md
└── LICENSE
```

### Managing data

See the separate [document](datamanagement.md) on data management.


### Writing functions and workflows

See the separate [document](functionality.md) on needed functionality.


### Coding tools: it's never too late for learning!

When writing functions for `n2khabutils` or writing workflows (in `src`):

- please use `tidyverse`, `sf` and `raster` packages for data reading.
Discover the human-friendly way of coding a data processing pipeline through the use of [pipes](https://r4ds.had.co.nz/pipes.html)!
Organise data in R in a [tidy](https://r4ds.had.co.nz/tidy-data.html#tidy-data-1) way in order to avoid troubles later on.
Recommended resources to get started are:
    - [R for Data Science](https://r4ds.had.co.nz/)
    - [Geocomputation with R](https://geocompr.robinlovelace.net)
- preferrably use `git2rdata::write_vc()` when an R _dataframe_ needs to be written to disk for later use (see <https://inbo.github.io/git2rdata/>).
Define the sorting order well (avoid ties) by using the `sorting` argument, in order to get meaningful _diffs_ when data are updated later.
The function stores the object in a version-control + R friendly format (tab separated values (.tsv) plus metadata on sorting order and variables (.yml)).
The R object can then be 100% recreated using `git2rdata::read_vc()`!!


### How can I contribute code?

More detailed info on git workflows at INBO: <https://inbo.github.io/tutorials/tags/git/>.
See also [these git workshop materials](https://inbo.github.io/git-course/index.html).

1. Make commits (in your local clone of the remote repo on Github) _in your own git branch_, branched off from the `master` branch.
(But see this in a relative manner: exactly the same process can be repeated by someone else in turn, relative to your branch.)
You can push your branch to the remote as often as you like, as it will not influence other branches (first time: do `git push -u origin yourbranchname`; afterwards `git push` suffices). It serves as a backup and enables others to work with you on that branch.
1. Meanwhile, make sure that your branch stays up to date with evolutions in `master` (i.e. in your local repo, update `master` with `git checkout master && git pull` and then, with your own branch checked out again, do `git merge --no-ff master`), in order to prevent merge conflicts with `master` later on.
At this stage, you need to resolve any merge conflicts that may arise in your own branch.
1. Propose to merge your commits into `master`: this starts with making a 'pull request' (PR; actually this is a merge request) and assign at least one reviewer before a merge can be decided. At that moment, open online discussion in the repo is possible on your changes (for other open discussion that you want to start, make an _issue_). As long as no merge is performed, more commits can be added to this PR with `git push`, e.g. to implement requested changes by others.
    - note that, if you branched off another (reference) branch than `master`, make sure to change the reference branch in the pull request (the default reference is `master`).
1. After your PR is merged, pull the reference branch (usually `master`) and clean up your local repo in order to keep up with the remote.

