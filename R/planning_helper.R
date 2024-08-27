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


# id of the planning googlesheet ------------------------------------------

gs_id <- "1HLtyGK_csi5W_v7XChxgTuVjS-RKXqc0Jxos1RBqpwk"


# read the planning data --------------------------------------------------

df <- read_sheet(
  ss = gs_id,
  sheet = "Planning_v2",
  col_types = "ccccllliccccdddddddddddccdddddddddddcc",
  .name_repair = "minimal"
)


# clean planning data and turn it into long format ------------------------

df_long <-
  df |>
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
    .fn = \(x) {
      str_c(x, "_1")
    }
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


# functions ---------------------------------------------------------------

summarize_planning_long <- function(x,
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
      days = sum(nr_days) |> round(2),
      .by = c(person, {{ tempres }})
    ) |>
    arrange(person, {{ tempres }})
}

summarize_planning <- function(x,
                               priorities = 1,
                               max_year = 2025,
                               tempres = c("y_month", "y"),
                               include_continuous = TRUE) {
  summarize_planning_long(
    x = x,
    priorities = priorities,
    max_year = max_year,
    tempres = tempres,
    include_continuous = include_continuous
  ) |>
    pivot_wider(
      names_from = person,
      values_from = days,
      names_sort = TRUE
    )
}


# using the top level summarizing function --------------------------------

# for checking (use temporary view to filter non-continuous tasks in gsheet):
summarize_planning(
  df_long,
  priorities = 1:5,
  tempres = NULL,
  include_continuous = FALSE,
  max_year = 2028
)

summarize_planning(df_long, priorities = 1) |>
  write_sheet(ss = gs_id, sheet = "priority_1")
summarize_planning(df_long, priorities = 1, tempres = "y") |>
  write_sheet(ss = gs_id, sheet = "priority_1_year")
summarize_planning(df_long, priorities = 1:2) |>
  write_sheet(ss = gs_id, sheet = "priority_1:2")
summarize_planning(df_long, priorities = 1:5) |>
  write_sheet(ss = gs_id, sheet = "priority_1:5")

# create data frames with planning per person -----------------------------

max_year <- 2025

df_long |>
  filter(year(date) <= max_year) |>
  pivot_wider(
    names_from = task_type,
    values_from = nr_days,
    values_fill = 0
  ) |>
  nest(data = -person) |>
  (function(x) {
    walk2(x$person, x$data, function(name, df) {
      df |>
        mutate(
          task_days = str_c(
            round(uitvoering, 1),
            "+",
            round(review, 1),
            "=",
            round(uitvoering + review, 1)
          )
        ) |>
        arrange(start, deadline) |>
        select(-c(
          statistisch:automatisatie,
          continuous,
          date,
          uitvoering,
          review
        )) |>
        pivot_wider(
          names_from = y_month,
          values_from = task_days
        ) |>
        write_sheet(ss = gs_id, sheet = str_c(as.character(name), "_planning"))
    })
  })()


# read availability data and turn into long format ------------------------

avail <- read_sheet(
  ss = gs_id,
  sheet = "Beschikbaarheid"
)

avail_long <-
  avail |>
  mutate(y_month = factor(y_month)) |>
  select(y_month, ends_with("_mnm"), mo_gw:datamanager) |>
  rename_with(
    .cols = ends_with("_mnm"),
    .fn = \(x) str_remove(x, "_mnm$")
  ) |>
  pivot_longer(
    -y_month,
    names_to = "person",
    values_to = "days_avail"
  ) |>
  mutate(person = fct(person))


# function to return number of days left per person x month ---------------

#' Summarize planning table by returning number of days left per person & month
#'
#' @param x Long format of planning data.
#' @param y Long format of person availability data.
summarize_days_left <- function(x,
                                y,
                                priorities = 1) {
  x |>
    summarize_planning_long(priorities = priorities) |>
    inner_join(
      y,
      join_by(y_month, person),
      relationship = "many-to-one",
      unmatched = "drop"
    ) |>
    mutate(days_left = round(days_avail - days, 2)) |>
    pivot_wider(
      id_cols = y_month,
      names_from = person,
      values_from = days_left,
      names_sort = TRUE
    )
}


# apply function to return number of days left (person x month) -----------

summarize_days_left(df_long, avail_long, priorities = 1) |>
  write_sheet(ss = gs_id, sheet = "priority_1_avail")
