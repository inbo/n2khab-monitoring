# This file is supposed to be run to create timed backups of the MNM planning google sheet.
# The table is dumped to a binary file.
# Pure backup for now; we will take care of restoration later.


source("R/functions.R")
library(googlesheets4)


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
      message("No backup stored.")
      return(invisible(NULL))
    }
  }

  # check that the loaded table is of the right type and dimension
  if (!inherits(planning_table, "data.frame")) {
    # table loading can be unsuccessful.
    warning("backup unsuccessful: no data frame loaded.")
    return(invisible(NULL))
  }

  if ((nrow(planning_table) == 0) || (ncol(planning_table) == 0)) {
  # if a table was loaded, back it up.
    warning("Planning table is empty (zero dimension). Did the data load correctly? No backup stored.")
    return(invisible(NULL))
  }

  # choose a meaningful storage path
  extension <- match.arg(filetype)
  file_name <- paste0(format(Sys.time(), "%Y%m%d_planning_googlesheet"),
                      ".", extension)
  file_path_backup <- here::here("local_backups", file_name)

  # write the backup
  switch(extension,
         rds = saveRDS(planning_table, file_path_backup),
         csv = readr::write_csv(planning_table, file_path_backup)
         )

  # optionally report execution
  if (verbose) {
    message(paste0('planning sheet backed up here: ', file_path_backup))
  }

} # local_backup
