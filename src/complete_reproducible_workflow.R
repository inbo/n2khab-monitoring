## This R script lists the steps in order, required to generate original text
## data and derived (binary) data in the 'textdata' and 'data/20_processed'
## subfolders respectively. It requires the RAW binary data to be present in the
## 'data/10_raw' subfolder in the specified way (see datamanagement.md).

## Note on the relative paths: this script is supposed to be run from
## the root of the n2khab-inputs repository. Advice: simply run it from the
## n2khab-inputs.Rproj RStudio project.

## !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! #
## WARNING ! This script may take a very LONG time to run. You are advised
## to have a closer look into the sourced files: do you really need
## everything?
## !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! #


# Generating the data folder inside this repository
# -------------------------------------------------

n2khabutils::filemanag_folders(root = "git")


# Generating textdata files for the n2khabutils package
# -----------------------------------------------------

# Normally you will not require this step if you just need the latest versions
# of these data and already have the n2khabutils package installed (see
# README.md). These data are included in the package. Hence, this step is
# normally only required to update the package because of updates in these data.

setwd("src/generate_textdata")
rmarkdown::render_site(output_format = 'bookdown::html_document2',
                       encoding = 'UTF-8')

# Generating GeoTIFF and GPKG files, derived from the GRTSmaster_habitats data source
# --------------------------------------------------------------------------

# Be warned: this can take > 10 hours.

setwd("src/generate_GRTS_10_GRTSmh_base4frac")
rmarkdown::render_site(output_format = 'bookdown::html_document2',
                       encoding = 'UTF-8')

setwd("src/generate_GRTS_20_GRTSmh_brick")
rmarkdown::render_site(output_format = 'bookdown::html_document2',
                       encoding = 'UTF-8')

setwd("src/generate_GRTS_30_GRTSmh_diffres")
rmarkdown::render_site(output_format = 'bookdown::html_document2',
                       encoding = 'UTF-8')


# Generating habitatmap_stdized
# ------------------------------

setwd("src/generate_habitatmap_stdized")
rmarkdown::render_site(output_format = 'bookdown::html_document2',
                       encoding = 'UTF-8')









