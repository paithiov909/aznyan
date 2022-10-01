#' Arrange a character column with patterns
#'
#' @param tbl A data.frame.
#' @param col Column name.
#' @param patterns A character vector.
#' @return data.frame.
#'
#' @export
arrange_with <- function(tbl, col, patterns) {
  col <- rlang::enquo(col)
  stopifnot(is.character(dplyr::pull(tbl, !!col)))
  for (str in patterns) {
    cases <- stringr::str_which(dplyr::pull(tbl, !!col), str)
    tbl <- tbl[c(cases, setdiff(seq_len(nrow(tbl)), cases)), ]
  }
  tbl
}

#' Check if dates are within Japanese era
#'
#' @param date Dates.
#' @param era String.
#' @return logicals
#'
#' @export
is_within_era <- function(date, era) {
  stringi::stri_datetime_format(
    lubridate::as_date(date),
    format = "G",
    locale = "ja-u-ca-japanese"
  ) == era
}

#' An R implementation of NanoID
#'
#' @param size Integer.
#' @param alpha A character vector.
#' @return string scalar.
#'
#' @export
nano <- function(size = 21L,
                 alpha = c(LETTERS, letters, as.character(0:9), "_", "-")) {
  bytes <- bitwAnd(as.integer(openssl::rand_bytes(size)), 63)
  id <- alpha[bytes + 1]
  paste0(id, collapse = "")
}

#' Parse dates to Japanese dates
#'
#' @param date Dates.
#' @param format String.
#' @return a chacter vector.
#'
#' @export
parse_to_jdate <- function(date,
                           format = NULL) {
  if (missing(format)) {
    format <- enc2utf8("Gy\u5e74M\u6708d\u65e5")
  }
  stringi::stri_datetime_format(
    as.Date(date),
    format = format,
    locale = "ja-u-ca-japanese"
  )
}

#' Call a function n times
#'
#' Simply executes a function specified times inside `purrr::map`.
#'
#' @param fn A function.
#' @param n Integer.
#' @param ... Other arguments are passed to function f.
#' @param .walk If supplied `TRUE`, executes the function
#' inside `purrr::walk` rather than `purrr::map`.
#'
#' @export
times <- function(fn, n = 2L, ..., .walk = FALSE) {
  if (isTRUE(.walk)) {
    purrr::walk(seq_len(n), function(n) rlang::exec(fn, ...))
  } else {
    purrr::map(seq_len(n), function(n) rlang::exec(fn, ...))
  }
}

#' Xtabs with tidy selecting
#'
#' @param tbl A data.frame
#' @param ... Column names go to right side of formula (tidy-selection).
#' @param .by Column name goes to left side of formula.
#' @return a contingency table in array representation of S3 class
#' `c("xtabs", "table")`.
#'
#' @export
xtabs_tidy <- function(tbl, ..., .by = NULL) {
  loc <- tidyselect::eval_select(rlang::expr(c(...)), tbl)
  fml <- paste(
    ifelse(missing(.by), "", rlang::ensym(.by)),
    "~",
    paste(colnames(tbl)[loc], collapse = " + ")
  )
  stats::xtabs(fml, tbl) %>%
    stats::addmargins() %>%
    stats::ftable()
}
