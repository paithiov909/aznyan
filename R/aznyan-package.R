#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @useDynLib aznyan, .registration = TRUE
## usethis namespace: end
NULL

#' Convert image data into recorded plot
#'
#' @param nr A `nativeRaster` object.
#' @returns A recorded plot is invisibly returned.
#' @export
#' @keywords internal
as_recordedplot <- function(nr) {
  grid::grid.newpage(recording = FALSE)
  grid::grid.raster(nr, interpolate = TRUE)
  invisible(grDevices::recordPlot(load = "aznyan"))
}

#' Cast `x` into integers if it's a `nativeRaster` object
#' @param nr A `nativeRaster` object.
#' @param nm Name of `nr`
#' @noRd
cast_nr <- function(nr, nm = "nr") {
  if (!inherits(nr, "nativeRaster")) {
    msg <- glue::glue("`{nm}` must be a nativeRaster object.")
    rlang::abort(msg)
  }
  as.integer(nr)
}

#' Take `x` and set its class as `nativeRaster`
#' @param x Object to be set class.
#' @noRd
as_nr <- function(x) {
  class(x) <- c("nativeRaster", class(x))
  x
}

#' Match `x` to `values`
#' @param x Object to be matched.
#' @param arg Argument name.
#' @param values Possible values.
#' @noRd
int_match <- function(x, arg, values) {
  tmp <- match(x[1], values) - 1L
  if (is.na(tmp)) {
    msg <- glue::glue(
      "`{arg}` must be one of {paste0(values, collapse = ', ')}. Got {x}."
    )
    rlang::abort(msg)
  }
  tmp
}
