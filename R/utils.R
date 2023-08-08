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
