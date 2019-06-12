### Table of Contents

   * [Functionality and good practices](#functionality-and-good-practices)
   * [1. Input data and high-level functions needed to achieve a sampling design and analysis results](#1-input-data-and-high-level-functions-needed-to-achieve-a-sampling-design-and-analysis-results)
      * [1.1 Data &amp; functions for drawing probability samples](#11-data--functions-for-drawing-probability-samples)
      * [1.2 Data &amp; functions for making sampling frames](#12-data--functions-for-making-sampling-frames)
      * [1.3 Data &amp; functions for making the 'base' sampling frame](#13-data--functions-for-making-the-base-sampling-frame)
      * [1.4 Data &amp; functions for composing a temporary sampling schedule as a selection from a legacy judgment sample (existing measurement locations)](#14-data--functions-for-composing-a-temporary-sampling-schedule-as-a-selection-from-a-legacy-judgment-sample-existing-measurement-locations)
      * [1.5 Data &amp; functions for model-building in support of the design](#15-data--functions-for-model-building-in-support-of-the-design)
      * [1.6 Data &amp; functions for inferences (also relevant for inference simulations in the design stage)](#16-data--functions-for-inferences-also-relevant-for-inference-simulations-in-the-design-stage)
   * [2. Data and intermediate functionality, needed in support of the high-level functions](#intermediate)
      * [2.1 Data &amp; functions to obtain the attributes 'type' and the type's spatial proportion](#21-data--functions-to-obtain-the-attributes-type-and-the-types-spatial-proportion)
      * [2.2 Data &amp; functions for restricting the spatial target population for each monitoring scheme (target population restricting data)](#22-data--functions-for-restricting-the-spatial-target-population-for-each-monitoring-scheme-target-population-restricting-data)
      * [2.3 Data &amp; functions for defining relevant existing measurement locations with 'usefulness' attributes](#23-data--functions-for-defining-relevant-existing-measurement-locations-with-usefulness-attributes)
      * [2.4 Intermediate-level helper functions](#24-intermediate-level-helper-functions)
   * [3. Low-level helper functions](#3-low-level-helper-functions)
      * [3.1 Reading data](#31-reading-data)
      * [3.2 Data checking](#32-data-checking)
      * [3.3 Data definition](#33-data-definition)
      
## Functionality and good practices

**Note: this document also applies to related n2khab repositories (mentioned below). [This picture](https://drive.google.com/open?id=1RQsjxch0YKdqJSPIDjCG_wEbYTlP3oDv) shows their relations.**

- data (pre)processing is to be reproducible, and is therefore defined by:
    - R-functions that aim at standardized data-reading, data-conversions etc., with arguments for undecided aspects that the user can set (including also, the directory of the dataset).
    These R-functions are made available to the user through the `n2khab` package.
    - R-scripts or ideally, literate scripts (R markdown) that define the actual workflow (processing pipeline), including the chosen arguments of the functions
- in some cases it can be useful to store (and version) the resulting dataset of a workflow as well (although it can be reproduced), especially if:
    - it is useful to offer immediate access to the resulting dataversion, e.g.:
        - by other colleagues
        - to compare versions in time more easily
    - the workflow is computationally intensive
- hence, the aim is to write easily usable functions to achieve the targeted results. A function can call other (helper) functions, therefore also high-level functions are to be made to enhance automatisation and reproducibility.
- when contributing: please use `tidyverse`, `sf`, `raster` and `git2rdata` packages for data reading and processing.
See the [README](README.md) file!
- use standardized names of datafiles, to be found [here](https://docs.google.com/spreadsheets/d/1E8ERlfYwP3OjluL8d7_4rR1W34ka4LRCE35JTxf3WMI) (see column `ID`).
These names are irrespective of the actual dataversion, which also has an ID.
There are some useful filter-views available in the google sheet.

<DIV STYLE="background:#E8C3D58B;padding:10px">

_Explanatory notes on function arguments used further:_

- `programme`: refers to MNE or MHQ
- `scheme`: the specific monitoring scheme within MNE or MHQ
- `object`: a data object in R
- `path`: the directory where the dataset can be found
- `file`: the filename, without extension in the case of multiple files with different extensions
- `outputdir`: the directory where the dataset is to be written (should be a subfolder of `outputdir` named as the dataset's ID)
- `threshold_pct`: the areal percentage threshold used to withhold types from `habitatmap`
- `resolution`: the resolution that the user wants for the highlevel raster
- `highlevel_raster`: coarse raster based on `GRTSmaster_habitats`
- `cell_samplesizes`: dataframe with sample size per evaluation cell
- `connection`: database connection

_Dataset IDs can be found in [this googlesheet](https://docs.google.com/spreadsheets/d/18U4AmiMnnApbgQTnfWbeZ3dAH3_4ISxUob_SX-maKV8)._

_**XG3** in the below context refers to HG3 and/or LG3 (in piezometers)._

</DIV>


# 1. Input data and high-level functions needed to achieve a sampling design and analysis results


## 1.1 Data & functions for drawing probability samples

(Only briefly considered for now.)

- sampling frame
- the sampling design:
    - the design type
    - attributes of spatial, temporal and revisit design

<DIV STYLE="background:#E8C3D58B;padding:10px">

_**Needed functions: in repo n2khab-mne-design / n2khab-mhq-design**_

_**Scripts/Rmarkdown: in repo n2khab-mne-design / n2khab-mhq-design**_

_**Results: to be written into repo n2khab-mne-design / n2khab-mhq-design, or in a separate repo with the sampling administration**_

</DIV>
    
## 1.2 Data & functions for making sampling frames

- `base_samplingframe`: a 'base' sampling frame (see 1.3) that does not distinguish between monitoring schemes, but instead provides the unioned spatial target population for the monitoring schemes of MHQ and/or MNE;
- _target population restricting data_ (see 2.2): information that complements the 'base' sampling frame, in order to restrict the spatial target population for each monitoring scheme and completely define the respective target populations.

<DIV STYLE="background:#E8C3D58B;padding:10px">

_**Needed functions: in repo n2khab-samplingframes:**_

- `write_samplingframe(programme, scheme, outputdir)`

_**Scripts/Rmarkdown: in repo n2khab-samplingframes**_

_**Results: to be written into repo n2khab-samplingframes**_

</DIV>


## 1.3 Data & functions for making the 'base' sampling frame

A 'base' sampling frame is implemented as a unioned **dataframe** of the spatial target populations of the respective types (for all monitoring schemes of MNE or MHQ as a whole).
Each row represents a spatial unit that belongs to the target population of one type.
The 'base' sampling frame can either be separated between MNE and MHQ, or provided with a TRUE/FALSE attribute for MNE and MHQ.
The spatial unit can correspond to a raster cell from a GRTS master raster (terrestrial types), a line segment (lotic types) or a polygon of non-fixed size (lentic types).

The 'base' sampling frame needs input data in order to provide the following attributes when drawing samples:

- spatial unit definition (ID, spatial attributes): derived from:
    - `GRTSmaster_habitats`
    - `terr_habitatmap`
    - `integrated_habitatmap`
    - `mhq_terrestrial_locs`
    - `mhq_lentic_locs`
    - `mhq_lotic_locs`
    - `flanders` (used to restrict the previous layers, as far as needed)
- the attributes 'type' and the type's spatial proportion (see 2.1)
- domains:
    - `sac` (Special Areas of Conservation: Habitats Directive (Flanders))
    - `biogeoregions`
- GRTS ranking number: derived from:
    - `GRTSmaster_habitats`
    - algorithms to join the `GRTSmaster_habitats` ranking number to spatial units (of terrestrial, lotic, lentic types respectively)
    
In practice, it is possible to build up the base sampling frame in steps, i.e. according to the needs.
E.g., the addition of `integrated_habitatmap` (which combines `terr_habitatmap` with `watersurfaces`, `habitatstreams`) can also be postponed.
    
    
<DIV STYLE="background:#E8C3D58B;padding:10px">

_**Needed functions: in repo n2khab-samplingframes:**_

- `write_base_samplingframe(outputdir)`

_**Scripts/Rmarkdown: in repo n2khab-samplingframes**_

_**Results: to be written into repo n2khab-samplingframes**_

</DIV>


## 1.4 Data & functions for composing a temporary sampling schedule as a selection from a legacy judgment sample (existing measurement locations)

(Cf. chapter 6 of [this](https://drive.google.com/open?id=1OlLCdEAvWOelzXeTytqsuKfcw7B3HQov) report -- in Dutch.)

- relevant existing measurement locations with 'usefulness' attributes (see 2.3)
- `samplingframe`
- highlevel raster for evaluation
- aimed sample size for each evaluation cell
- sampling design attributes, especially spatial sample sizes

Plus the supporting functions (see [further](#intermediate)) to scale up `GRTSmaster_habitats` to make the highlevel raster and calculate the expected sample size for each evaluation cell.

<DIV STYLE="background:#E8C3D58B;padding:10px">

_**Needed functions: in repo n2khab-mne-design:**_

- `sample_legacy_sites_groundwater(highlevel_raster, cell_samplesizes, outputdir)`
- `sample_probabilistic_sites_groundwater(highlevel_raster, cell_samplesizes, outputdir)`

The suffix `_groundwater` can also be replaced by something else. Subprogramme (e.g. groundwater) specific functions are used here because of the peculiarities.

_**Scripts/Rmarkdown: in repo n2khab-mne-design**_

_**Results: to be written into repo n2khab-mne-design**_

</DIV>


## 1.5 Data & functions for model-building in support of the design

(Cf. chapter 7 of [this](https://drive.google.com/open?id=1OlLCdEAvWOelzXeTytqsuKfcw7B3HQov) report -- in Dutch.)

- a dataset of the environmental variable of interest, that has at least some relevance to the target population (and ideally, spatial and/or temporal overlap)
- optionally:
    - spatial attributes of existing measurement locations
- the attributes 'type' and the type's spatial proportion
- target population restricting data
- spatial layers supporting sample simulation:
    - `soilmap`
    - `ecoregions`
    - etc.
   
   
## 1.6 Data & functions for inferences (also relevant for inference simulations in the design stage)

(Cf. chapter 9 of [this](https://drive.google.com/open?id=1OlLCdEAvWOelzXeTytqsuKfcw7B3HQov) report -- in Dutch.)

I.e. including model-assisted inference.

- sampling-unit-level design attributes, including type, sampling weights, time (at least at the level of the revisit design's specifications), domain and poststratum specification
- `scheme_types`, defining typegroups if applicable
- auxiliary variable(s) (see [draft list](https://docs.google.com/spreadsheets/d/14jiHfF4vZUlmfPKiry8HCDDt-HFFvhDhW9_SFvtdSkk) -- in Dutch), known for the whole of the sampling frame, either:
    - categorical variable defining poststrata (for poststratification)
    - continuous variable (for regression estimation)
    
    Examples include:
    - `soilmap`
    - `ecoregions`
- domain population totals for more efficient domain estimation (i.e. subpopulation estimation through poststratification)

<DIV STYLE="background:#E8C3D58B;padding:10px">

_**Needed functions: in repo n2khab-mne-design or in a more general n2khab inference functions repo:**_

- `status_estimates(samplingunits_dataframe, domain, auxiliaries, typegroups)`
    - `samplingunits_dataframe` provides sampling weights, population size of domain, poststratum and total population, typegroup membership, type
    - `auxiliaries` are variable names, to be provided in `samplingunits_dataframe`, which will be evaluated as categorical (for poststratification) or continuous (for regression estimation)
    - returns estimates and confidence intervals from design-based spatial or spatiotemporal inference
- `localtrend_estimates()`
    - returns modelled temporal trend parameter for each site (mean & confidence interval), which can subsequently be fed into `status_estimates()` for design-based spatial inference
    
_**Scripts/Rmarkdown: in same repo**_

_**Results: to be written into repo n2khab-mne-design (simulations) or n2khab-mne-result (result), same could be done for n2khab-mhq**_

</DIV>






# 2. Data and intermediate functionality, needed in support of the high-level functions {#intermediate}

## 2.1 Data & functions to obtain the attributes 'type' and the type's spatial proportion

Possible dataframes or spatial objects to join this information to, include `GRTSmaster_habitats`, `groundwater_sites`, `lenticwater_sites`, ... Often, more than one type can be linked to a spatial unit and therefore the information is typically not directly part of a spatial object (they use a common identifier). Instead, a long (tidy) dataframe (tibble) is generated to enlist all types that are recorded at a location.

Depending on the purpose, the type-attribute is to be derived from one or more of the following:

- `habitatmap`
- `habitatdune`
- `habitatstreams`
- `watersurfaces`
- `mhq_lentic_locs`
- `mhq_lotic_locs`

Moreover, it is brought in consistency, and restricted to the type codes from the datasource `types`.

Also, main types need to be linked to their corresponding _subtypes_ in order to be picked up when selections are defined at the subtype level (needed when no subtype information exists for a given spatial object).

Further, extra attributes are needed in most applications -- especially when using the `habitatmap` dataset: the rank and the associated areal proportion of each row.

Ideally, an intermediate spatial layer is generated that combines the above layers and integrates their information.


<DIV STYLE="background:#E8C3D58B;padding:10px">

_**Needed functions: in package n2khab:**_

Both functions take into account type code consistency and link subtypes to main types. Both functions generate a data set consisting of both a spatial object and a long / tidy dataframe (tibble), including areal proportions.

- `write_terr_habitatmap(threshold_pct, outputdir)`
    - this function reads and integrates `habitatmap` and `habitatdune`
- `write_integrated_habitatmap(threshold_pct, outputdir)`
    - incorporates `write_terr_habitatmap()` but inserts the spatial units from `habitatstreams` and `watersurfaces` while retaining useful (type) attributes, ideally including those from `mhq_lentic_locs` and `mhq_lotic_locs`

_**Dedicated writing workflow (scripts/Rmarkdown): in repo n2khab-inputs**_

_**Results of the dedicated writing workflow: to be written into `data/20_processed`**_

</DIV>



## 2.2 Data & functions for restricting the spatial target population for each monitoring scheme (target population restricting data)

Separate data next to the sampling frame are needed to restrict the spatial target population for each monitoring scheme, in order to completely define the respective spatial target populations. These data are comprised of:

- `schemes`: provides an ID for each monitoring scheme, its defining attributes (e.g. in MNE: compartment, environmental pressure, (sometimes:) variable) and mentions whether a further spatial restriction layer is needed
- `scheme_types`: dataframe that lists the types of the target population of respective monitoring schemes
- spatial restriction to units irrespective of type -- depending on the monitoring scheme (see [list](https://docs.google.com/spreadsheets/d/14jiHfF4vZUlmfPKiry8HCDDt-HFFvhDhW9_SFvtdSkk/edit#gid=907349910)): derived from:
    - `shallowgroundwater`
    - `floodsensitive`
    - other possible spatial layers
    
<DIV STYLE="background:#E8C3D58B;padding:10px">

_**Needed functions: in package n2khab:**_

- `read_schemes(path, file)`
- `read_scheme_types(path, file)`
- `read_shallowgroundwater(path, file)`
- `read_floodsensitive(path, file)`

_**Results: NOT to be written**_

</DIV>


## 2.3 Data & functions for defining relevant existing measurement locations with 'usefulness' attributes

- spatial attributes of existing measurement locations
- 'usefulness' attributes of the locations that allow to make selections which maximize 1) usefulness of existing data and 2) the potential of follow-up in the near future. These are derived of a dataset of the environmental variable of interest, that has at least a relevant overlap with the target population
- usefulness selection criteria
- spatial selection criteria:
    - the attributes 'type' and the type's spatial proportion (see 2.1)
    - target population restricting data (see 2.2)
    - topological criteria for spatially joining the target population with the existing measurement locations


<DIV STYLE="background:#E8C3D58B;padding:10px">

_**Needed functions: in repo inborutils:**_

- `qualify_groundwater_sites(xg3_metadata, xg3_data, chemistry_metadata, chemistry_data)`
    - the input objects conform to the formats returned by `read_groundwater_xg3()` and `read_groundwater_chemistry()` (see part 3)
    - the function flags sites with the following quality characteristics:
        - XG3 data available
        - hydrochemical data available
        - recent data available (either XG3 or hydrochemical)
        - length of the 'useful XG3 data series', i.e. the longest available XG3 data series that has more hydrological years _with_ than _without_ an XG3 observation, and that starts and ends with a hydrological year with an XG3 observation
        - number of gaps (missing years) in the useful XG3 data series
        - first hydrological year of the useful XG3 data series
        - last hydrological year of the useful XG3 data series
    - the function returns a spatial object (hereafter named `groundwater_sites`) with the quality criteria, and with the piezometer IDs and coordinates
- `spatialjoin_groundwater_sites(object, topological_criterion, groundwater_sites)`
    - takes a spatial R object (e.g. `soilmap`, `terr_habitatmap`, `integrated_habitatmap`) and uses a `topological_criterion` (e.g. intersect with buffer around piezometers with radius x) to make a spatial join with a spatial object `groundwater_sites` as returned by `qualify_groundwater_sites()`
    - returns a tidy dataframe (tibble) (hereafter named `groundwater_joinedattributes`) with piezometer IDs and the joined attributes (as buffers may be used, a long format is necessary)

_**Results: NOT to be written**_

</DIV>

<br/>

<DIV STYLE="background:#E8C3D58B;padding:10px">

_**Needed functions: in package n2khab:**_

- `filter_groundwater_sites(groundwater_sites, groundwater_joinedattributes, scheme, usefulness)`
    - combines the spatial object returned by `qualify_groundwater_sites()` with a dataframe (tibble), returned by `spatialjoin_groundwater_sites()` and which provides type & type attributes, and restricts the result:
        - according to the types and optional spatial restrictions as imposed by the specified MNE-`scheme`;
        - according to `usefulness` criteria, which could be given as a dataframe with the allowed minimum and maximum values of quality characteristics
    - returns the shrinked forms of `groundwater_sites` _and_ `groundwater_joinedattributes`, as a GeoJSON file or shapefile (points) and a dataframe (tibble), respectively.
    - _alternatively, define a function that encapsulates `qualify_groundwater_sites()` and `spatialjoin_groundwater_sites()` and applies the restriction._

_**Dedicated writing workflow (scripts/Rmarkdown): in repo n2khab-mne-design**_

_**Results of the dedicated writing workflow: to be written into repo n2khab-mne-design**_

</DIV>



## 2.4 Intermediate-level helper functions

<DIV STYLE="background:#E8C3D58B;padding:10px">

_**Needed functions: in package n2khab:**_

- `spatialjoin_GRTS(object)`
    - takes a spatial R object (polygons, line segments, points), makes a spatial join with `GRTSmaster_habitats` and returns a spatial R object with GRTS attributes added;
    - potentially involves an open GIS-backend;
    - for polygons and line segments, implements a point selection procedure to comply with MHQ selections.
- `write_highlevel_GRTSmh(resolution)`
    - writes `highlevel_raster`, i.e. a scaled up version (using `resolution`) of `GRTSmaster_habitats`
- `soiltexture_coarse()`
    - takes a vector with soil type codes (character of factor) and converts this into a factor with three coarse texture classes (fine / coarse / peat)


_**Results: NOT to be written**_

</DIV>

<br/>

<DIV STYLE="background:#E8C3D58B;padding:10px">

_**Needed functions: in repo n2khab-mne-design:**_

- `expected_sample_size(programme, scheme, highlevel_raster)`

_**Results: NOT to be written**_

</DIV>




# 3. Low-level helper functions

## 3.1 Reading data

To recall, `read_xxx()` functions typically return:

- tidy formatted data (which may mean that a spatial dataset is to be kept separate from long-formatted attributes).
    - While several `read_xxx()` functions refer to data that are more specific to n2khab projects, other `read_xxx()` functions have broader interest.
    Therefore, place the latter (only) in the [inborutils](https://github.com/inbo/inborutils) package.
- data with English variable names and labels of identifiers (such as types, pressures, ...)
- [tibbles](https://r4ds.had.co.nz/tibbles.html) instead of dataframes
- only the variables needed for n2khab projects

So, depending on the data source, it may require more than a `read_vc()` or `st_read()` statement.

<DIV STYLE="background:#E8C3D58B;padding:10px">

_**Needed functions: in package n2khab:**_

- For reading input data:
    - `read_env_pressures(path, file)`
    - `read_schemes(path, file)`
    - `read_scheme_types(path, file)`
    - `read_types(path, file)`
    - `read_namelist(path, file)`
        - this holds the names, corresponding to codes in other textual data sources (`types`, `env_pressures` etc.), supporting multiple languages.
    - `read_GRTSmh(path, file)`
        - if this is not feasible within R, an open GIS-backend needs to be called by R
    - `read_habitatmap(path, file)`
        - returns spatial object and long (tidy) tibble
    - `read_habitatdune(path, file)`
    - `read_habitatstreams(path, file)`
    - `read_sac(path, file)`
    - `read_mhq_terrestrial_locs(path, file)`
    - `read_mhq_lentic_locs(path, file)`
    - `read_mhq_lotic_locs(path, file)`
        
- In some cases, for reading generated data:
    - `read_terr_habitatmap(path, file)`
        - loads the R objects, returned by `write_terr_habitatmap()`
    - `read_integrated_habitatmap(path, file)`
        - loads the R objects, returned by `write_integrated_habitatmap()`
    - `read_samplingframe(path, file)`
        - loads the R object, returned by `write_samplingframe()`
    - `read_base_samplingframe(path, file)`
        - loads the R object, returned by `write_base_samplingframe()`

_**Results: NOT to be written**_

</DIV>

<br/>

<DIV STYLE="background:#E8C3D58B;padding:10px">

_**Needed functions: in inborutils package:**_

- For reading input data:
    - `read_watersurfaces(path, file)`
    - `read_flanders(path, file)`
    - `read_provinces(path, file)`
    - `read_biogeoregions(path, file)`
    - `read_ecoregions(path, file)`
    - `read_soilmap(path, file)`
    - `read_groundwater_xg3(connection, selection)`
        - defines the query to be executed in the groundwater database, in order to extract metadata _and_ XG3 data
        - it implements criteria, which can be given by a dataframe argument `selection`:
            - maximum filter bottom depth as meters below soil surface (workflow implementation: at most 3 meters below soil surface)
            - from piezometer couples, which to retain (workflow implementation: only the most shallow one)
    - `read_groundwater_chemistry(connection, selection)`
        - defines the query to be executed in the groundwater database, in order to extract metadata _and_ hydrochemical data
        - it implements criteria, which can be given by a dataframe argument `selection`:
            - maximum filter bottom depth as meters below soil surface (workflow implementation: at most 3 meters below soil surface)
            - from piezometer couples, which to retain (workflow implementation: only the most shallow one)

_**Results: NOT to be written**_

</DIV>


## 3.2 Data checking

Workflows (in no matter which repo) will depend on the user that places data in the right location, and most of all: _the **right** data_ in the right location.

The following things are therefore needed  in each repo where data processing is done (analysis repositories and _n2khab-inputs_):

- `datalist_chosen`: a tabular file that clearly defines which data sources and versions thereof are needed (the file is versioned in the respective repo)
- functionality regarding the definition of data sources and data versions (see 3.3)
- a housekeeping workflow that checks whether the right data are present, as defined by `datalist_chosen`, and which should be run on a regular basis


<DIV STYLE="background:#E8C3D58B;padding:10px">

_**Needed functions: in package n2khab**_

- `check_inputdata(checksums, root, checksumdelay=14*24*3600)`
    - checks data presence, data version and integrity, cf. the functionality described [here](https://docs.google.com/spreadsheets/d/18U4AmiMnnApbgQTnfWbeZ3dAH3_4ISxUob_SX-maKV8/edit#gid=0&range=B74)
    - it generates, next to each file, a metadata file and, under certain conditions, a checksum file
    - it checks the current metadata against the metadata file and it checks the checksum against the checksum in the `checksums` dataframe, which is to be generated from `datalist_chosen`, `dataversions` and `datasources`
    - it reports to the user

_**Dedicated workflow (scripts/Rmarkdown): in repo n2khab-inputs plus other repos with data processing**_

_**Results: NOT to be written**_

</DIV>


## 3.3 Data definition

In order to allow for checks (see 3.2) and further metadata, definition of data is needed:

- `datasources`: tabular file that defines data sources (mirrors worksheet 'data sources' in [this googlesheet](https://docs.google.com/spreadsheets/d/1E8ERlfYwP3OjluL8d7_4rR1W34ka4LRCE35JTxf3WMI/edit#gid=0)): attributes like ID, n2khab-repo, data owner, authorative source location, relative local path where data is to be expected.
- `dataversions` (in _n2khab-inputs_): tabular file that defines data versions (mirrors worksheet 'data source versions in [this googlesheet](https://docs.google.com/spreadsheets/d/1E8ERlfYwP3OjluL8d7_4rR1W34ka4LRCE35JTxf3WMI/edit#gid=1017627684)): attributes like sourceID, versionID, authorative source location, fileserver data path, **filename**, **checksum**.
- a housekeeping workflow that updates `datasources` and `dataversions`, and which should be run on a regular basis

<DIV STYLE="background:#E8C3D58B;padding:10px">

_**Needed functions: in package n2khab:**_

Functions that keep `datasources` and `dataversions` in sync with the mirror google sheet:

- `write_datasources(outputdir)`
- `write_dataversions(outputdir)`
    
_**Dedicated writing workflow (scripts/Rmarkdown): in repo n2khab-inputs**_

_**Results of the dedicated writing workflow: to be written into repo n2khab-inputs**_

</DIV>
















