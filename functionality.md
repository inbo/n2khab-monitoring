<style type="text/css">

a:link, a:hover, a:active, a:visited {
    color:#C04384;
}

</style>

### Table of Contents

   * [Functionality and good practices](#functionality-and-good-practices)
   * [Input data and high-level functions needed to achieve several results {#results}](#input-data-and-high-level-functions-needed-to-achieve-several-results-results)
      * [Needed for drawing probability samples](#needed-for-drawing-probability-samples)
      * [Needed for making a sampling frame](#needed-for-making-a-sampling-frame)
      * [Needed for making the 'base' sampling frame](#needed-for-making-the-base-sampling-frame)
      * [Needed for composing a temporary sampling schedule as a selection from a legacy judgment sample (existing measurement locations)](#needed-for-composing-a-temporary-sampling-schedule-as-a-selection-from-a-legacy-judgment-sample-existing-measurement-locations)
      * [Needed for model-building in support of the design](#needed-for-model-building-in-support-of-the-design)
      * [Needed for inferences (also relevant for inference simulations in the design stage)](#needed-for-inferences-also-relevant-for-inference-simulations-in-the-design-stage)
   * [Data and intermediate functions, needed in support of the high-level functions {#intermediate}](#data-and-intermediate-functions-needed-in-support-of-the-high-level-functions-intermediate)
      * [Needed to obtain the attributes 'type' and the type's spatial proportion](#needed-to-obtain-the-attributes-type-and-the-types-spatial-proportion)
      * [Needed for restricting the spatial target population for each monitoring programme (target population restricting data)](#needed-for-restricting-the-spatial-target-population-for-each-monitoring-programme-target-population-restricting-data)
      * [Needed for defining relevant existing measurement locations with 'usefulness' attributes](#needed-for-defining-relevant-existing-measurement-locations-with-usefulness-attributes)
      * [As a helper for several before-mentioned functions](#as-a-helper-for-several-before-mentioned-functions)
   * [Further needed reading functions as a helper for several functions, mentioned before](#further-needed-reading-functions-as-a-helper-for-several-functions-mentioned-before)
   
# Functionality and good practices

Note: this document also applies to related n2khab-repositories

- data (pre)processing is to be reproducible, and is therefore defined by:
    - R-functions that aim for standardized data-reading, data-conversions etc., with arguments for undecided aspects that the user can set (including also, the directory of the dataset)
    - R-scripts or ideally, literate scripts (R markdown) that define the actual workflow (processing pipeline), including the chosen arguments of the functions
- in some cases it can be useful to store (and version) the result of a workflow as well (although it can be reproduced), especially if:
    - it is useful to offer immediate access to the resulting dataversion, e.g.:
        - by other colleagues
        - to compare versions in time more easily
    - the workflow is computationally intensive
- hence, the aim is to write easily usable functions to achieve the below [results](#results). One function can encapsulate other functions, e.g. functions like XXXX
- when contributing: please use `tidyverse`, `sf` and `raster` packages for data reading and ([pipe](https://r4ds.had.co.nz/pipes.html#when-not-to-use-the-pipe-friendly)-friendly) processing.
Organise data in R in a [tidy](https://r4ds.had.co.nz/tidy-data.html#tidy-data-1) way.
Recommended resources to get started are:
    - [R for Data Science](https://r4ds.had.co.nz/)
    - [Geocomputation with R](https://geocompr.robinlovelace.net)
- preferrably use `git2rdata::write_vc()` when R dataframes need to be written to disk for later use (see <https://inbo.github.io/git2rdata/>)
- use standardized names of datafiles, to be found [here](https://docs.google.com/spreadsheets/d/1E8ERlfYwP3OjluL8d7_4rR1W34ka4LRCE35JTxf3WMI) (see column `ID`).
These names are irrespective of the actual dataversion, which also has an ID.
There are some useful filter-views available in the google sheet.

For further consideration: one way of sharing the functionality (and optionally, the included textual data) will be to distribute it as an R package. I.e. a user just types `library(n2khab-inputs)` to have all functionality available.

<DIV STYLE="background:#E8C3D58B;padding:10px">

_Explanatory notes on the function arguments used further:_

- `project`: refers to MNE or BIOQUAL
- `programme`: the specific monitoring programme within MNE or BIOQUAL
- `object`: a data object in R
- `datadir`: the directory where the dataset can be found (in a subfolder named as the dataset's ID)
- `outputdir`: the directory where the dataset is to be written (in a subfolder named as the dataset's ID)
- `threshold_pct`: the areal percentage threshold used to withhold types from the habitat map
- `resolution`: the resolution that the user wants for the evaluation grid
- `evaluation_grid`: coarse grid based on GRTSmaster
- `cell_samplesizes`: dataframe with sample size per evaluation cell
- `connection`: database connection

_Dataset IDs can be found in [this googlesheet](https://docs.google.com/spreadsheets/d/18U4AmiMnnApbgQTnfWbeZ3dAH3_4ISxUob_SX-maKV8)._

</DIV>


# Input data and high-level functions needed to achieve several results {#results}


## Needed for drawing probability samples

(Only briefly considered for now.)

- sampling frame
- the sampling design:
    - the design type
    - attributes of spatial, temporal and revisit design
- optionally: algorithm to decide on the uptake of matching, existing monitoring locations
    
<DIV STYLE="background:#E8C3D58B;padding:10px">

_**Needed functions: in repo n2khab-mne-design / n2khab-bioqual**_

_**Scripts/Rmarkdown: in repo n2khab-mne-design / n2khab-bioqual**_

_**Results: to be written into repo n2khab-mne-design / n2khab-bioqual, or in a separate repo with the sampling administration**_

</DIV>
    
## Needed for making a sampling frame

- a 'base' sampling frame that does not distinguish between monitoring programmes, but instead provides the unioned spatial target population for the monitoring programmes;
- information that complements the 'base' sampling frame, in order to restrict the spatial target population for each monitoring programme and completely define the respective target populations.

<DIV STYLE="background:#E8C3D58B;padding:10px">

_**Needed functions: in repo n2khab-samplingframe:**_

- `write_samplingframe(project, programme, outputdir)`

_**Scripts/Rmarkdown: in repo n2khab-samplingframe**_

_**Results: to be written into repo n2khab-samplingframe**_

</DIV>


## Needed for making the 'base' sampling frame

A 'base' sampling frame is implemented as a unioned **dataframe** of the spatial target populations of the respective types.
Each row represents a spatial unit that belongs to the target population of one type.
The 'base' sampling frame can either be separated between MNE and BIOQUAL, or provided with a TRUE/FALSE attribute for MNE and BIOQUAL.
The spatial unit can correspond to a grid cell from a GRTS master grid (terrestrial types), a line segment (lotic types) or a polygon of non-fixed size (lentic types).

The 'base' sampling frame needs input data in order to provide the following attributes when drawing samples:

- spatial unit definition (ID, spatial attributes): derived from:
    - GRTSmaster
    - watersurfaces
    - habitatstreams
    - flanders (used to restrict the previous layers, as far as needed)
- the attributes 'type' and the type's spatial proportion
- domains:
    - SACH (Special Areas of Conservation: Habitats Directive (Flanders))
    - biogeoregions
- GRTS ranking number: derived from:
    - GRTSmaster
    - algorithms to join the GRTSmaster ranking number to spatial units (of terrestrial, lotic, lentic types respectively)
    
In practice, it is possible to build up the base sampling frame in steps, i.e. according to the needs.
E.g., the addition of watersurfaces and streams can also be postponed.
    
    
<DIV STYLE="background:#E8C3D58B;padding:10px">

_**Needed functions: in repo n2khab-samplingframe:**_

- `make_base_samplingframe(outputdir)`

_**Scripts/Rmarkdown: in repo n2khab-samplingframe**_

_**Results: to be written into repo n2khab-samplingframe**_

</DIV>


## Needed for composing a temporary sampling schedule as a selection from a legacy judgment sample (existing measurement locations)

(Cf. chapter 6 of [this](https://drive.google.com/open?id=1OlLCdEAvWOelzXeTytqsuKfcw7B3HQov) report -- in Dutch.)

- relevant existing measurement locations with 'usefulness' attributes
- sampling frame
- GRTSmaster (in order to generate an evaluation grid and for selecting locations within the evaluation cells)
- sampling design attributes, especially spatial sample sizes

Plus the supporting functions (see [further](#intermediate)) to scale up GRTSmaster to make the evaluation grid and calculate the expected sample size for each evaluation cell.

<DIV STYLE="background:#E8C3D58B;padding:10px">

_**Needed functions: in repo n2khab-mne-design:**_

- `sample_legacy_sites_groundwater(evaluation_grid, cell_samplesizes, outputdir)`
- `sample_probabilistic_sites_groundwater(evaluation_grid, cell_samplesizes, outputdir)`

The suffix `_groundwater` can also be replaced by something else. Programme specific functions are used here because of the peculiarities.

_**Scripts/Rmarkdown: in repo n2khab-mne-design**_

_**Results: to be written into repo n2khab-mne-design**_

</DIV>


## Needed for model-building in support of the design

- a dataset of the environmental variable of interest, that has at least some relevance to the target population (and ideally, spatial and/or temporal overlap)
- optionally:
    - spatial attributes of existing measurement locations
- the attributes 'type' and the type's spatial proportion
- target population restricting data
- spatial layers supporting sample simulation:
    - soilmap
    - ecoregions
    - etc.
   
   
## Needed for inferences (also relevant for inference simulations in the design stage)

I.e. including model-assisted inference.

- sampling-unit-level design attributes, including type, sampling weights, time (at least at the level of the revisit design's specifications), domain and poststratum specification
- typegroup definitions
- auxiliary variable(s) (see [draft list](https://docs.google.com/spreadsheets/d/14jiHfF4vZUlmfPKiry8HCDDt-HFFvhDhW9_SFvtdSkk) -- in Dutch), known for the whole of the sampling frame, either:
    - categorical variable defining poststrata (for poststratification)
    - continuous variable (for regression estimation)
    
    Examples include:
    - soilmap
    - ecoregions
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






# Data and intermediate functions, needed in support of the high-level functions {#intermediate}

## Needed to obtain the attributes 'type' and the type's spatial proportion

Possible dataframes or spatial objects to join this information to, include GRTSmaster, piezometerdata, lenticwaterdata ... Often, more than one type can be linked to a spatial unit and therefore the information is typically not directly part of a spatial object (they use a common identifier). Instead, a long (tidy) dataframe is generated to enlist all types that are recorded at a location.

Depending on the purpose, the type-attribute is to be derived from one of more of the following:

- habitatmap
- habitatdune
- habitatstreams
- watersurfaces
- bioqual_terrestrial_locs
- bioqual_lentic_locs
- bioqual_lotic_locs

Moreover, it is brought in consistency, and restricted to the type codes from the following lists:

- types_checklist
- types_per_programme

Also, main types need to be linked to their corresponding _sub_types in order to be picked up when selections are defined at the subtype level (needed when no subtype information exists for a given spatial object).

Further, an extra attribute is needed in most applications -- especially when using the `habitatmap` dataset -- that provides the associated areal proportion of each row.

Ideally, an intermediate spatial layer is generated that combines the above layers and integrates their information.


<DIV STYLE="background:#E8C3D58B;padding:10px">

_**Needed functions: in repo n2khab-inputs:**_

Both functions take into account type code consistency and link subtypes to main types. Both functions generate a data set consisting of both a spatial object and a tidy dataframe, including areal proportions.

- `write_terr_habitatmap(threshold_pct, outputdir)`
    - this function reads and integrates `habitatmap`, `habitatdune` and `bioqual_terrestrial_locs`
- `write_integrated_habitatmap(threshold_pct, outputdir)`
    - incorporates `write_terr_habitatmap()` but inserts the spatial units from `habitatstreams` and `watersurfaces` while retaining useful (type) attributes, including those from `bioqual_lentic_locs` and `bioqual_lotic_locs`

_**Results: to be written into repo n2khab-inputs**_

</DIV>



## Needed for restricting the spatial target population for each monitoring programme (target population restricting data)

Separate data next to the sampling frame are needed to restrict the spatial target population for each monitoring programme, in order to completely define the respective spatial target populations. These data are comprised of:

- programmes: provides an ID for each monitoring programme, its defining attributes (e.g. in MNE: compartment, environmental pressure, (sometimes:) variables) and mentions whether a further spatial restriction layer is needed
- types_per_programme: dataframe that lists the types of the target population of respective monitoring programmes
- spatial restriction to units irrespective of type -- depending on the monitoring programme: derived from:
    - shallowgroundwater
    - floodsensitive
    - other possible spatial layers
    
<DIV STYLE="background:#E8C3D58B;padding:10px">

_**Needed functions: in repo n2khab-inputs:**_

- `read_programmes(datadir)`
- `read_types_per_programme(datadir)`
- `read_shallowgroundwater(datadir)`

_**Results: NOT to be written**_

</DIV>

<br/>

<DIV STYLE="background:#E8C3D58B;padding:10px">

_**Needed functions: in inborutils package:**_

- `read_floodsensitive(datadir)`

_**Results: NOT to be written**_

</DIV>

## Needed for defining relevant existing measurement locations with 'usefulness' attributes

- spatial attributes of existing measurement locations
- 'usefulness' attributes of the locations that allow to make selections which maximize 1) usefulness of existing data and 2) the potential of follow-up in the near future. These are derived of a dataset of the environmental variable of interest, that has at least a relevant overlap with the target population
- spatial selection criteria:
    - the attributes 'type' and the type's spatial proportion
    - target population restricting data
    - topological criteria for spatially joining the target population with the existing measurement locations


<DIV STYLE="background:#E8C3D58B;padding:10px">

_**Needed functions: in repo n2khab-inputs:**_

- `filter_groundwater_sites(groundwater_sites, groundwater_joinedattributes, scheme, outputdir)`
    - combines the spatial object returned by `qualify_groundwater_sites()` with the dataframe returned by `spatialjoin_groundwater_sites()` (see further), and restricts it according to the types and optional spatial restrictions as imposed by the specified MNE-scheme.
    - returns the shrinked forms of `groundwater_sites` _and_ `groundwater_joinedattributes`.
    - _alternatively, define a function that encapsulates `qualify_groundwater_sites()` and `spatialjoin_groundwater_sites()` and applies the restriction._

_**Results: to be written into repo n2khab-inputs**_

</DIV>




## As a helper for several before-mentioned functions

<DIV STYLE="background:#E8C3D58B;padding:10px">

_**Needed functions: in repo n2khab-inputs:**_

- `spatialjoin_GRTSmaster(object)`
    - takes a spatial R object (polygons, line segments, points), makes a spatial join with `GRTSmaster` and returns a spatial R object with GRTS attributes added;
    - potentially involves an open GIS-backend;
    - for polygons and line segments, implements a point selection procedure to comply with BIOQUAL selections.
- `make_evaluation_grid(resolution)`
- `qualify_groundwater_sites(xg3_metadata, xg3_data, chemistry_metadata, chemistry_data)`
    - the arguments conform to the formats returned by `read_groundwater_xg3()` and `read_groundwater_chemistry()`
    - the function flags sites with the following quality criteria:
        - XG3 data available
        - hydrochemical data available
        - recent data available (either XG3 or hydrochemical)
        - length of the 'useful XG3 data series', i.e. the longest available XG3 data series that has more measured than unmeasured years
        - number of gaps (missing years) in the useful XG3 data series
    - the function returns a spatial object (hereafter named `groundwater_sites`) with the quality criteria, and with the piezometer IDs and coordinates
- `spatialjoin_groundwater_sites(object, topological_criterion, groundwater_sites)`
    - takes a spatial R object (e.g. soilmap, terr_habitatmap, integrated_habitatmap) and uses a `topological_criterion` (e.g. intersect with buffer around piezometers with radius x) to make a spatial join with a spatial object `groundwater_sites` as returned by `qualify_groundwater_sites()`
    - returns a tidy dataframe (hereafter named `groundwater_joinedattributes`) with piezometer IDs and the joined attributes (as buffers may be used, a long format is necessary)


_**Results: NOT to be written**_

</DIV>

<br/>

<DIV STYLE="background:#E8C3D58B;padding:10px">

_**Needed functions: in repo n2khab-mne-design:**_

- `expected_sample_size(project, programme, evaluation_grid)`

_**Results: NOT to be written**_

</DIV>




# Further needed reading functions as a helper for several functions, mentioned before

<DIV STYLE="background:#E8C3D58B;padding:10px">

_**Needed functions: in repo n2khab-inputs:**_

- `read_programmes(datadir)`
- `read_types_per_programme(datadir)`
- `read_types_checklist(datadir)`
- `read_shallowgroundwater(datadir)`
- `read_GRTSmaster(datadir)` ^[If this is not feasible within R, an open GIS-backend needs to be called by R.]
- `read_habitatmap(datadir)`
    - returns spatial object and tidy dataframe, making use of `tidy_habitatmap()`
- `read_watersurfaces(datadir)`
- `read_habitatstreams(datadir)`
- `read_floodsensitive(datadir)`
- `read_flanders(datadir)`
- `read_SACH(datadir)`
- `read_biogeoregions(datadir)`
- `read_ecoregions(datadir)`
- `read_habitatdune(datadir)`
- `read_terr_habitatmap(datadir)`
    - loads the R object, returned by `read_terr_habitatmap()`
- `read_integrated_habitatmap(datadir)`
    - loads the R object, returned by `read_integrated_habitatmap()`
- `read_soilmap(datadir)`
- `read_bioqual_terrestrial_locs(datadir)`
- `read_bioqual_lentic_locs(datadir)`
- `read_bioqual_lotic_locs(datadir)`
- `read_groundwater_xg3(connection)`
    - defines the query to be executed in the database, in order to extract metadata _and_ XG3 data
    - it implements the following criteria:
        - filter bottom no deeper than 3 meters below soil surface
        - from piezometer couples, only the most shallow one is retained
- `read_groundwater_chemistry(connection)`
    - defines the query to be executed in the database, in order to extract metadata _and_ hydrochemical data
    - it implements the following criteria:
        - filter bottom no deeper than 3 meters below soil surface
        - from piezometer couples, only the most shallow one is retained

_**Results: NOT to be written**_

</DIV>

<br/>

<DIV STYLE="background:#E8C3D58B;padding:10px">

_**Needed functions: in inborutils package:**_

- `tidy_habitatmap(object)`
    - returns spatial object and tidy dataframe
- `tidy_xxx(object)`
    - for other INBO references layers which can use tidying

_**Results: NOT to be written**_

</DIV>




