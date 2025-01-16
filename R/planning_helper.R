# Setup for googledrive authentication. Set the appropriate env vars in
# .Renviron and make sure you ran googledrive::drive_auth() interactively with
# these settings for the first run (or to renew an expired Oauth token)
if (Sys.getenv("GARGLE_OAUTH_EMAIL") != "") {
  options(gargle_oauth_email = Sys.getenv("GARGLE_OAUTH_EMAIL"))
}
if (Sys.getenv("GARGLE_OAUTH_CACHE") != "") {
  options(gargle_oauth_cache = Sys.getenv("GARGLE_OAUTH_CACHE"))
}

library(googlesheets4)
library(dplyr)
library(tidyr)
library(janitor)
library(stringr)
library(forcats)
library(lubridate)
library(purrr)
source("R/functions.R")

# Optionally change below max_year value; it's used to limit processed results
max_y <- function() 2025

# Get planning table as long-table format
pl_long <- get_planning_long()

# Get number number of available days as long-table format (person x month)
avail_long <- get_availability_long()

# Below sheet updates can be picked as desired, or just be run all together
# ###########################################################################

# Update the reordered planning tables per person in the planning googlesheet
update_person_sheets(pl_long)

# Update the daysleft_xxx sheets with number of days left per person & month
update_daysleft_sheets(pl_long, avail_long)

# Update the plansum_xxx sheets in the planning googlesheet
update_planningsummary_sheets(pl_long)




# Don't run below; it's for checks only --------------------------------------

# (use temporary view to filter non-continuous tasks in gsheet)
if (FALSE) {
  summarize_planning(
    pl_long,
    restrict_to_selected = FALSE,
    priorities = 1:5,
    tempres = NULL,
    include_continuous = FALSE,
    max_year = 2028
  )
}
