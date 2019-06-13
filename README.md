## Welcome

This repo documents on the interconnections between several repositories that are related to *Flemish Natura 2000 habitat monitoring programmes*.
Hence it is the **starting point** to find your way through these repositories.
Some repositories (especially [n2khab](https://github.com/inbo/n2khab) and [n2khab-preprocessing](https://github.com/inbo/n2khab-preprocessing)) have a much broader scope,
as they also support other _N2KHAB_ projects, i.e. projects that focus on Natura 2000 habitat (and which may as well use the _n2khab_-prefix for their git repository name).

On the GitHub website, **centralized task planning** is done that concerns the other repositories.
This is done in the form of issues, most of which are visualized in the 'Tasks' project.

Several repositories are set up with a special interest in _reproducible_ and _transparent_ design, review and analysis of Natura 2000 habitat monitoring programmes at the Flemish scale (each is a combination of multiple monitoring schemes):

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

More specific overviews are given in:

- the [document](datamanagement.md) on data management;
- [list (under construction)](https://docs.google.com/spreadsheets/d/1E8ERlfYwP3OjluL8d7_4rR1W34ka4LRCE35JTxf3WMI) with metadata of dataset versions and their source location
- the [document](functionality.md) on intended functionality, especially functions of n2khab and related repositories;
- the [draft overview of functions per repository](https://docs.google.com/spreadsheets/d/18U4AmiMnnApbgQTnfWbeZ3dAH3_4ISxUob_SX-maKV8/edit#gid=924567109).

Referral to the _currently existing_ 'n2khab-' repositories and their short characteristic:

- **n2khab**: R package that provides data definitions, standard checklists and preprocessing functions.
Its scope is N2KHAB projects.
Several functions return preprocessed datasets (see `n2khab-preprocessing`) as standardized R-objects.
- **n2khab-preprocessing**: provides workflows to generate processed data from important raw data for N2KHAB-projects.
- **n2khab-mne-design**: design of the Flemish monitoring programme for the natural environment (MNE).


## Repository history

Previous to commit `be6be8e`, this repo was called 'n2khab-inputs' and it also harboured the code of the [n2khab](https://github.com/inbo/n2khab) and [n2khab-preprocessing](https://github.com/inbo/n2khab-preprocessing) in specific subfolders.
Hence, the older version history of those repos remains stored here.
As a convenience, both repos also hold this older version history, but in a rewritten (shrinked) form as defined by the related files and folders.
See [this](https://github.com/inbo/n2khab-monitoring/issues/28) issue, where the migration is documented.

