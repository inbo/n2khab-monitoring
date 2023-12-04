## Welcome

This repo documents on the interconnections between several repositories that are related to *Flemish Natura 2000 habitat monitoring programmes*.
Hence it is the **starting point** to find your way through these repositories.
Some repositories (especially [n2khab](https://github.com/inbo/n2khab) and [n2khab-preprocessing](https://github.com/inbo/n2khab-preprocessing)) have a much broader scope,
as they also support other _N2KHAB_ projects, i.e. projects that focus on Natura 2000 habitat _in some way_ (and which may as well use the _n2khab_-prefix for their git repository name).

On the GitHub website of this repo, **centralized task planning** is done that relates to the other repositories, typically in the context of monitoring.
This is done in the form of issues, most of which are visualized in the 'Tasks' project.

The related repositories are set up with a special interest in _reproducible_ and _transparent_ design, review and analysis of Natura 2000 habitat monitoring programmes at the Flemish scale (each is a combination of multiple monitoring schemes):

- MNE: monitoring programme for the natural environment
- MHQ: monitoring programme for biotic habitat quality

The ultimate aim is to achieve open and reproducible data workflows.
That is a prerequisite for qualifiable science, for sharing and for broad cooperation.


## Overview

The repo is meant to fit the draft principles and setup in [this googlesheet](https://docs.google.com/spreadsheets/d/18U4AmiMnnApbgQTnfWbeZ3dAH3_4ISxUob_SX-maKV8), for long-term N2KHAB projects.
The googlesheet is partly in Dutch.

Some summarizing schemes (in English):

- relationships between possible, future [repositories](https://drive.google.com/open?id=1RQsjxch0YKdqJSPIDjCG_wEbYTlP3oDv);
- data storage and versioning [workflows](https://drive.google.com/open?id=1xZz9f9n8zSUxBJvW6WEFLyDK7Ya0u4iN).

You should definitely have a look at the distribution and setup of standard data sources for N2KHAB projects:

```r
vignette("v020_datastorage", package = "n2khab")
```

Specific overviews are given in:

- [list (under construction)](https://docs.google.com/spreadsheets/d/1E8ERlfYwP3OjluL8d7_4rR1W34ka4LRCE35JTxf3WMI) with metadata of dataset versions and their source location
- the [document](functionality.md) on intended functionality, especially functions of the `n2khab` R package and related repositories;
- the [draft overview of functions per repository](https://docs.google.com/spreadsheets/d/18U4AmiMnnApbgQTnfWbeZ3dAH3_4ISxUob_SX-maKV8/edit#gid=924567109).

Short description of the _currently existing_ repositories related to Flemish Natura 2000 habitat monitoring:

- **[n2khab](https://github.com/inbo/n2khab)**: R package that provides data definitions, standard checklists and preprocessing functions.
Its scope is N2KHAB projects.
Several functions return preprocessed datasets (see `n2khab-preprocessing`) as standardized R-objects.
- **[n2khab-preprocessing](https://github.com/inbo/n2khab-preprocessing)**: provides workflows to generate processed data from raw data that are important to N2KHAB-projects.
- **[n2khabmon](https://github.com/inbo/n2khabmon)**: R package to prepare and manage Flemish monitoring schemes regarding Natura 2000 habitats.
- **[n2khab-samplingframes](https://github.com/inbo/n2khab-samplingframes)**: sampling frames and code to reproduce or update these.
- **[n2khab-mne-design](https://github.com/inbo/n2khab-mne-design)**: design of the Flemish monitoring programme for the natural environment (MNE).
- **[n2khab-sample-admin](https://github.com/inbo/n2khab-sample-admin)**: sample management and associated code.



## Repository history

Previous to commit `be6be8e`, this repo was called 'n2khab-inputs' and it also harboured the code of the [n2khab](https://github.com/inbo/n2khab) and [n2khab-preprocessing](https://github.com/inbo/n2khab-preprocessing) repos in specific subfolders.
Hence, the older version history of those repos remains stored here.
As a convenience, both repos also hold the older version history, but in a rewritten (shrinked) form as defined by the related files and folders.
See [this](https://github.com/inbo/n2khab-monitoring/issues/28) issue, where the migration is documented.

