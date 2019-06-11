# This script allows the conversion of vc-formatted files because of specific
# upgrades of the git2rdata package that change the way files are written.
# Its repository is at https://github.com/inbo/git2rdata

# The used functions runs from the root of the repo

getwd()


# 2019-05-16
# -------------------------------------------------------------------
# Previous state of git2rdata: commit 4b1f2fd
# Conversion to new state of git2rdata: commit df1ba32 (tag v0.0.4)

git2rdata::upgrade_data(path = "src/generate_textdata/rawraw_data")
    # rawraw_data/10_compmeetnet_types_milieudrukken.yml updated
    # rawraw_data/10_compmeetnet_types_milieudrukken.yml
    # "rawraw_data/10_compmeetnet_types_milieudrukken"

git2rdata::upgrade_data(path = "n2khabutils/inst/textdata")
    # ../../n2khabutils/inst/textdata/env_pressures.yml updated
    # ../../n2khabutils/inst/textdata/namelist.yml updated
    # ../../n2khabutils/inst/textdata/schemes.yml updated
    # ../../n2khabutils/inst/textdata/scheme_types.yml updated
    # ../../n2khabutils/inst/textdata/types.yml updated
    # ../../n2khabutils/inst/textdata/env_pressures.yml
    # "../../n2khabutils/inst/textdata/env_pressures"
    # ../../n2khabutils/inst/textdata/namelist.yml
    # "../../n2khabutils/inst/textdata/namelist"
    # ../../n2khabutils/inst/textdata/schemes.yml
    # "../../n2khabutils/inst/textdata/schemes"
    # ../../n2khabutils/inst/textdata/scheme_types.yml
    # "../../n2khabutils/inst/textdata/scheme_types"
    # ../../n2khabutils/inst/textdata/types.yml
    # "../../n2khabutils/inst/textdata/types"
