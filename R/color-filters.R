#' Apply predefined color filter
#'
#' Applies one of the predefined color filters
#' that are ported from [Rustagram](https://github.com/ha-shine/rustagram).
#'
#' ## Options
#' The following filters are available:
#'
#' - 1977
#' - aden
#' - brannan
#' - brooklyn
#' - clarendon
#' - earlybird
#' - gingham
#' - hudson
#' - inkwell
#' - kelvin
#' - lark
#' - lofi
#' - maven
#' - mayfair
#' - moon
#' - nashville
#' - reyes
#' - rise
#' - slumber
#' - stinson
#' - toaster
#' - valencia
#' - walden
#'
#' @param nr A `nativeRaster` object.
#' @param filter The name of the filter.
#' @returns A `nativeRaster` object.
#' @export
color_filter <- function(
  nr,
  filter = c(
    "1977",
    "aden",
    "brannan",
    "brooklyn",
    "clarendon",
    "earlybird",
    "gingham",
    "hudson",
    "inkwell",
    "kelvin",
    "lark",
    "lofi",
    "maven",
    "mayfair",
    "moon",
    "nashville",
    "reyes",
    "rise",
    "slumber",
    "stinson",
    "toaster",
    "valencia",
    "walden"
  )
) {
  filter <- rlang::arg_match(filter)
  filter_id <- match(
    filter,
    c(
      "1977",
      "aden",
      "brannan",
      "brooklyn",
      "clarendon",
      "earlybird",
      "gingham",
      "hudson",
      "inkwell",
      "kelvin",
      "lark",
      "lofi",
      "maven",
      "mayfair",
      "moon",
      "nashville",
      "reyes",
      "rise",
      "slumber",
      "stinson",
      "toaster",
      "valencia",
      "walden"
    )
  ) -
    1L
  as_nr(azny_color_filter(cast_nr(nr), nrow(nr), ncol(nr), filter_id))
}
