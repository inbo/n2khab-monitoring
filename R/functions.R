# Functions used to help in the planning googlesheet ----------------------

#' Return id of the planning googlesheet
gs_id <- function() "1HLtyGK_csi5W_v7XChxgTuVjS-RKXqc0Jxos1RBqpwk"


#' Sanity checks for the google sheet table "planning_v2".
#'
#' This function is used in data pipe-lines to check that everything
#' in the google sheet is as expected.
#' It will throw errors or warnings if something goes wrong.
#'
#' @details the function can be used in a dplyr pipe, which is why
#' it requires and returns the `data` argument.
#'
#' @param data a data frame (or derivative) loaded from a google sheet
perform_sanity_checks <- function(data) {
  # https://github.com/hadley/assertthat/issues/41

  # check if there are NA columns not supposed to be empty
  required_columns <- c("thema", "subthema", "start")

  # troublemakers <- data |>
  #   filter(if_any({{required_columns}}, is.na)) |>
  #   pull(taakcode) # <- this is non-informative if the "taakcode" was blank

  if (any(is.na(data[, required_columns]))) {
    troublemakers <- which(rowSums(is.na(data[, required_columns])) > 0)
    warning(paste0("Columns {",
                   paste(required_columns, collapse = ", "),
                   "} may not be empty! (line/s ",
                   troublemakers, ")"
                   )
            )
  }

  return(data)

  # further reading about warnings/errors etc.:
  # https://adv-r.hadley.nz/conditions.html#warnings
  # https://stackoverflow.com/a/68713357
  # https://reside-ic.github.io/blog/a-warning-about-warning/
}

#' Read the Planning_v2 sheet in the planning googlesheet.
#'
#' @details see R/functions.R/get_planning_long()
#'
#' @keywords internal
#'
#' @param ss The id of the planning googlesheet
get_planning_raw <- function(ss = gs_id()) {
  # read the planning data
  read_sheet(
    ss,
    sheet = "Planning_v2",
    range = cell_cols("A:AP"),
    col_types =
      c(
        rep("c", 5),   # task definition
        rep("l", 3),   # task properties
        "i",           # priority
        "l",           # selected for execution
        rep("c", 5),   # management stuff
        "c",           # who executes
        rep("d", 11),  # number of days per team member
        "c",           # who else executes
        "c",           # who reviews
        rep("d", 11),  # number of days per team member
        "c",           # who else reviews
        "c"            # total number of teamdays
      ) |>
      stringr::str_flatten(),
    .name_repair = "minimal"
    )
}



#' Generate a long-format planning table from the Planning_v2 sheet in the
#' planning googlesheet.
#'
#' Reads the 'wide-format' Planning_v2 sheet from the planning googlesheet and
#' tries to update the planned month intervals to actual (expected/required)
#' month intervals, by taking into account current task status, current date,
#' actual month that the task was started.
#' The 'long-format' part is about several things: putting persons below each
#' other, putting 'uitvoering' and 'review' below each other, and also the
#' expansion of intervals to the respective months.
#'
#' @param ss The id of the planning googlesheet
get_planning_long <- function(ss = gs_id()) {
  # read the planning data
  get_planning_raw(ss = ss) |>
    # clean planning data and turn it into long format
    clean_names() |>
    perform_sanity_checks() |>
    select(
      -uitvoerders,
      -reviewers,
      -starts_with("totaal_dagen"),
      -ends_with("_buiten_kern"),
      -starts_with("tijdsinvestering")
    ) |>
    rename_with(
      .cols = karen:softw_engineer,
      .fn = \(x) {
        str_c(x, "_1")
      }
    ) |>
    mutate(
      continuous = deadline == "Doorlopend",
      deadline = ifelse(
        deadline == "Doorlopend",
        paste0(max_y(), "-12"),
        deadline
      ),
      # intended dates
      start = ym(start),
      deadline = ym(deadline) + months(1) - days(1),
      # actual months (as dates) of starting and finishing (only for started tasks)
      gestart = ym(gestart),
      afgerond = ym(afgerond) + months(1) - days(1),
      # derived variables:
      # ####################
      # 2 logicals
      started = !is.na(gestart),
      finished = !is.na(afgerond),
      # first & last day of current month
      first_day_currentmonth = floor_date(today(), unit = "month"),
      last_day_currentmonth = ceiling_date(today(), unit = "month") - days(1),
      # which start date to take in calculating currently applicable interval?
      begin = case_when(
        started ~ gestart,
        !started & finished ~ start,
        .default = pmax(start, first_day_currentmonth, na.rm = TRUE)
      ),
      # which end date to take in calculating currently applicable interval?
      end = ifelse(finished, afgerond, deadline) |>
        as.Date(),
      # is the task overdue?
      overdue = !finished & today() > end,
      # number of months of the interval
      nr_months = case_when(
        started & overdue ~ as.period(last_day_currentmonth - begin),
        !started & overdue ~ period(1, "month"),
        is.na(start) & is.na(deadline) ~ period(0, "month"),
        .default = as.period(end - begin)
      ) |>
        as.numeric("months") |>
        round() |>
        as.integer()
    ) |>
    uncount(nr_months, .remove = FALSE) |>
    mutate(
      date = begin + months(row_number() - 1),
      y_month = str_c(year(date), "_", str_pad(month(date), 2, pad = "0")) |>
        factor(),
      .by = taakomschrijving
    ) |>
    pivot_longer(
      cols = karen_1:softw_engineer_2,
      names_to = c(".value", "task_type"),
      names_pattern = "(.+)_([12])$"
    ) |>
    pivot_longer(
      karen:softw_engineer,
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
    select(-c(first_day_currentmonth:end, nr_months))
}


#' @keywords internal
summarize_planning_long <- function(x,
                                    restrict_to_selected = TRUE,
                                    priorities = 1:10,
                                    max_year = max_y(),
                                    tempres = c("y_month", "y"),
                                    include_continuous = TRUE) {
  tempres <- if (!is.null(tempres)) (match.arg(tempres))
  x |>
    mutate(y = year(date)) |>
    filter(
      if (restrict_to_selected) doen_we else TRUE,
      prioriteit %in% priorities,
      y <= max_year,
      include_continuous | !continuous
    ) |>
    summarize(
      days = sum(nr_days) |> round(2),
      .by = c(person, all_of(tempres))
    ) |>
    arrange(person, {{ tempres }})
}

#' Summarize planning (days occupied) by person and by month or year
#'
#' @param planning_long Long format of planning data.
#' @param restrict_to_selected Logical.
#' Should only the tasks where `doen_we` is `TRUE` be kept?
#' If `FALSE`, then all tasks are kept.
#' @param priorities Numeric vector of priorities, used to filter the
#' 'prioriteit' column in x.
#' @param max_year Number; the maximum allowed year from planning_long.
#' @param tempres String. Temporal resolution of the result.
#' @param include_continuous Logical.
#' Should continuous tasks be included?
#' Defaults to `TRUE`; value `FALSE` can be useful in manual checks or
#' debugging.
summarize_planning <- function(planning_long,
                               restrict_to_selected = TRUE,
                               priorities = 1:10,
                               max_year = max_y(),
                               tempres = c("y_month", "y"),
                               include_continuous = TRUE) {
  tempres <- if (!is.null(tempres)) (match.arg(tempres))
  summarize_planning_long(
    x = planning_long,
    restrict_to_selected = restrict_to_selected,
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

#' Update the plansum_xxx sheets in the planning googlesheet
#'
#' @inheritParams get_planning_long
#' @inheritParams summarize_planning
update_planningsummary_sheets <- function(planning_long, ss = gs_id()) {
  summarize_planning(
    planning_long,
    restrict_to_selected = TRUE
  ) |>
    write_sheet(ss = ss, sheet = "plansum_doen_we")

  summarize_planning(
    planning_long,
    priorities = 1,
    restrict_to_selected = FALSE
  ) |>
    write_sheet(ss = ss, sheet = "plansum_priority_1")

  summarize_planning(
    planning_long,
    priorities = 1,
    tempres = "y",
    restrict_to_selected = FALSE
  ) |>
    write_sheet(ss = ss, sheet = "plansum_priority_1_year")

  summarize_planning(
    planning_long,
    priorities = 1:2,
    restrict_to_selected = FALSE
  ) |>
    write_sheet(ss = ss, sheet = "plansum_priority_1:2")

  summarize_planning(
    planning_long,
    priorities = 1:3,
    restrict_to_selected = FALSE
  ) |>
    write_sheet(ss = ss, sheet = "plansum_priority_1:3")

  summarize_planning(
    planning_long,
    priorities = 1:5,
    restrict_to_selected = FALSE
  ) |>
    write_sheet(ss = ss, sheet = "plansum_priority_1:5")
}


#' Generate and update the reordered planning tables per person in the planning
#' googlesheet
#'
#' @details
#' Note that this function only picks tasks for which
#' `doen_we` is `TRUE` _and_ which are not finished.
#' Also, task x month combinations that belong to past months are dropped.
#'
#' @inheritParams get_planning_long
#' @inheritParams summarize_planning
update_person_sheets <- function(planning_long,
                                 ss = gs_id(),
                                 max_year = max_y()) {
  planning_long |>
    filter(year(date) <= max_year) |>
    pivot_wider(
      names_from = task_type,
      values_from = nr_days,
      values_fill = 0
    ) |>
    filter(doen_we, !finished, floor_date(today(), unit = "month") <= date) |>
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
            statistisch:doen_we,
            afgerond,
            continuous:finished,
            date,
            uitvoering,
            review
          )) |>
          pivot_wider(
            names_from = y_month,
            values_from = task_days
          ) |>
          write_sheet(ss = ss, sheet = str_c(as.character(name), "_planning"))
      })
    })()
}


#' Generate a long-format table of available working days per person from the
#' Beschikbaarheid sheet in the planning googlesheet.
#'
#' @inheritParams get_planning_long
get_availability_long <- function(ss = gs_id()) {
  read_sheet(
    ss = ss,
    sheet = "Beschikbaarheid"
  ) |>
    mutate(y_month = factor(y_month)) |>
    select(y_month, ends_with("_mnm"), mo_gw:softw_engineer) |>
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
}


#' Summarize planning table by returning number of days left per person & month
#'
#' @param availability_long Long format of person availability data.
#' @inheritParams summarize_planning
summarize_days_left <- function(planning_long,
                                availability_long,
                                restrict_to_selected = TRUE,
                                priorities = 1:10,
                                max_year = max_y()) {
  planning_long |>
    summarize_planning_long(
      restrict_to_selected = restrict_to_selected,
      priorities = priorities,
      max_year = max_year
    ) |>
    inner_join(
      availability_long,
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


#' Update daysleft_xxx sheets with number of days left per person & month
update_daysleft_sheets <- function(planning_long,
                                   availability_long,
                                   ss = gs_id()) {
  summarize_days_left(
    planning_long,
    availability_long,
    restrict_to_selected = TRUE,
    max_year = max_y()
  ) |>
    write_sheet(ss = ss, sheet = "daysleft_doen_we")

  summarize_days_left(
    planning_long,
    availability_long,
    restrict_to_selected = FALSE,
    priorities = 1,
    max_year = max_y()
  ) |>
    write_sheet(ss = ss, sheet = "daysleft_priority_1")
}


