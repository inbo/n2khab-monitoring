## Use this script FROM WITHIN THE PACKAGE RSTUDIO PROJECT,
## i.e. the n2khabutils.Rproj file in the subfolder n2khabutils.

# library(usethis)

# usethis::create_package(path = "../n2khabutils")
3# use_gpl3_license(name = "Research Institute for Nature and Forest")

devtools::load_all()

devtools::document()

# Some useful keyboard shortcuts for package authoring:
#
#   Build and Reload Package:  'Ctrl + Shift + B'
#   Check Package:             'Ctrl + Shift + E'
#   Test Package:              'Ctrl + Shift + T'
#   Load Package:              'Ctrl + Shift + L'
#   Generate ROxgen2 docu:     'Ctrl + Shift + D'

