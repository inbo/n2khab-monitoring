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

gs_id <- "1HLtyGK_csi5W_v7XChxgTuVjS-RKXqc0Jxos1RBqpwk"

df <- read_sheet(
  ss = gs_id,
  sheet = "Planning_v2",
  col_types = "ccccllliccccdddddddddddccdddddddddddcc",
  .name_repair = "minimal"
)

df_long <- df |>
    clean_names() |>
    select(
      -uitvoerders,
      -reviewers,
      -starts_with("totaal_dagen"),
      -ends_with("_buiten_kern"),
      -starts_with("tijdsinvestering")
    ) |>
    rename_with(
        .cols = karen:datamanager,
        .fn = \(x) {str_c(x, "_1")}
    ) |>
    mutate(
        continuous = deadline == "Doorlopend",
        deadline = ifelse(deadline == "Doorlopend", "2025-12", deadline),
        start = ym(start),
        deadline = ym(deadline) + months(1) - days(1),
        nr_months = as.period(deadline - start) |>
            as.numeric("months") |>
            round() |>
            as.integer()
    ) |>
    uncount(nr_months, .remove = FALSE) |>
    mutate(
        date = start + months(row_number() - 1),
        y_month = str_c(year(date), "_", str_pad(month(date), 2, pad = "0")) |>
            factor(),
        .by = taakomschrijving
    ) |>
    pivot_longer(
      cols = karen_1:datamanager_2,
      names_to = c(".value", "task_type"),
      names_pattern = "(.+)_([12])$"
    ) |>
    pivot_longer(
        karen:datamanager,
        names_to = "person",
        values_to = "nr_days",
        values_drop_na = TRUE
    ) |>
    mutate(
        task_type = ifelse(task_type == "1", "uitvoering", "review") |> fct(),
        nr_days = ifelse(
            continuous,
            nr_days,
            nr_days / nr_months
        ),
        across(where(is.character), fct)
    ) |>
    select(-nr_months)

summarize_planning <- function(x,
                               priorities = 1,
                               max_year = 2025,
                               tempres = c("y_month", "y"),
                               include_continuous = TRUE) {
    tempres <- if (!is.null(tempres)) (match.arg(tempres))
    x |>
        mutate(y = year(date)) |>
        filter(
          prioriteit %in% priorities,
          y <= max_year,
          include_continuous | !continuous,
          # generieke_omschrijving == "Aanwervingen"
        ) |>
        summarize(
            days = sum(nr_days),
            .by = c(person, {{tempres}})
        ) |>
        arrange(person, {{tempres}}) |>
        pivot_wider(
          names_from = person,
          values_from = days,
          names_sort = TRUE
        )
}

# for checking (use temporary view to filter non-continuous tasks in gsheet):
summarize_planning(
  df_long,
  priorities = 1:3,
  tempres = NULL,
  include_continuous = FALSE,
  max_year = 2028
)

summarize_planning(df_long, priorities = 1) |>
    write_sheet(ss = gs_id, sheet = "priority_1")

