# This file is supposed to be run to create timed backups of the MNM planning google sheet.
# The table is dumped to a binary file.
# Pure backup for now; we will take care of restoration later.


source("R/functions.R")
library(googlesheets4)

#' Read the Planning_v2 sheet in the planning googlesheet.
#' @details see R/functions.R/get_planning_long()
#' @param ss The id of the planning googlesheet
get_planning_raw <- function(ss = gs_id()) {
  # read the planning data
  read_sheet(
    ss,
    sheet = "Planning_v2",
    col_types = "ccccclllilccccccdddddddddddccdddddddddddcc",
    .name_repair = "minimal"
    )
}


#' Store a local backup of the google planning table.
#' @details
#' Take the planning table and save it to disk, either as `rds` or as `csv`.
#' @param ss a google sheet ID.
#' @param filetype rds (binary) or csv (text).
#' @param verbose whether or not output shall be printed.
#' @examples write_local_backup(verbose = TRUE, filetype = 'rds')
write_local_backup <- function(ss = gs_id(), verbose = TRUE, filetype = c('rds', 'csv')) {

  # query the planning table
  planning_table <- get_planning_raw(ss)

  # check if the directory exists
  if (!file.exists(here::here("local_backups"))) {
    if (utils::askYesNo("Shall we create a local backups folder?")) {
      # create it... if the user confirms
      dir.create(here::here("local_backups"), showWarnings = FALSE)
    } else {
      print("No backup stored.")
      return(NA)
    }
  }

  # backup the table
  if (missing(planning_table)) {
    # table loading can be unsuccesful.
    print("backup unsuccesful: no table loaded.")
  } else {
    # if a table was loaded, back it up.

    # ... in a smart (?) location
    extension <- match.arg(filetype)

    # choose a meaningful storage path
    file_name <- paste0(format(Sys.time(), "%Y%m%d_planning_googlesheet"), ".", extension)
    file_path_backup <- here::here("local_backups", file_name)

    # write the backup
    switch(extension,
           rds = saveRDS(planning_table, file_path_backup),
           csv = write.csv(planning_table, file_path_backup)
           )

    # optionally report execution
    if (verbose) {
      print(paste0('planning sheet backed up here: ', file_path_backup))
    }

  } # table backup
} # local_backup
