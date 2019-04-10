## Data management

[This list (under construction)](https://docs.google.com/spreadsheets/d/1E8ERlfYwP3OjluL8d7_4rR1W34ka4LRCE35JTxf3WMI) holds the metadata on dataset versions and their source location, both for binary and text-format data.
There are some useful filter-views available in this google sheet.

The data, or the results of dataset-specific reading functions (see [functionality](functionality.md)), are [tidied](https://r4ds.had.co.nz/tidy-data.html#tidy-data-1) and as much as possible internationalized:

- availability of English names for types, environmental pressures, ...
Other languages can be accomodated as well;
- English names for table headings (dataframe variables).

The data in this repo are organized in local folders.
How we store, distribute and version data, is given by an online [illustration](https://drive.google.com/open?id=1xZz9f9n8zSUxBJvW6WEFLyDK7Ya0u4iN).
The aim is to avoid the need for everyone to download each separate dataset from the authorative source location.

To be able to reproduce workflows (scripts and Rmarkdown files) that reside in this and other n2khab-repositories, some conventions are needed:

- data sources in **text-format (not too large)** are _versioned_ within the `n2khabutils` package:
    - `n2khabutils/inst/textdata` contains text-format **reference data**.
    Some of them come over from another repository; others may be written as the result of a synchronization script to give them a start;
- **binary** or **large** data sources are put in the folder `data`. The data are supposed to be divided as:
    - `data/10_raw`: local copies of binary/large inputdata versions are to be put here;
    - `data/20_processed`: generated binary/large data are put here by scripts.
    
    Each binary/large dataset is to be put in its *own subfolder* within one of the above folders.
The name of the subfolder is a fixed code (ID) according to the aforementioned [list](https://docs.google.com/spreadsheets/d/1E8ERlfYwP3OjluL8d7_4rR1W34ka4LRCE35JTxf3WMI).
As far as possible, the corresponding file(s) get the same name (this also holds for the text-format data in `n2khabutils`);
- the workflows should use relative paths when referring to these data.

Perhaps some binary datasets will receive a versioning system in the future, such as git LFS, if there is reason to suspect that the used versions will not be maintained in the source location in the long term.

