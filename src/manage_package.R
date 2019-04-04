## Use this script FROM WITHIN THE PACKAGE RSTUDIO PROJECT,
## i.e. the n2khabutils.Rproj file in the subfolder n2khabutils.

# Some history:
#
# library(usethis)
# usethis::create_package(path = "../n2khabutils")
# use_gpl3_license(name = "Research Institute for Nature and Forest")



# Some useful keyboard shortcuts for package authoring:
#
#   Build and Reload Package:  'Ctrl + Shift + B' (same as RStudio button 'install & restart')
#   Check Package:             'Ctrl + Shift + E' (same as RStudio button 'check')
#   Test Package:              'Ctrl + Shift + T'
#   Load Package:              'Ctrl + Shift + L' (makes current package state available
#                                                   in your R session, without installing)
devtools::load_all()
#   Generate ROxgen2 docu:     'Ctrl + Shift + D'
devtools::document()

# Doing a local package installation (from here):

devtools::install()

# Doing a github-based package installation (defaults to the master branch; will be put in the n2khab-inputs README):

remotes::install_github("inbo/n2khab-inputs", subdir = "n2khabutils")

