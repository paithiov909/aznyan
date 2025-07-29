#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @useDynLib aznyan, .registration = TRUE
#' @importFrom utils write.table
## usethis namespace: end
NULL

#' Convert PNG image data into recorded plot
#'
#' @param nr A `nativeRaster` object.
#' @returns A recorded plot is invisibly returned.
#' @export
as_recordedplot <- function(nr) {
  grid::grid.newpage(recording = FALSE)
  grid::grid.raster(nr, interpolate = TRUE)
  invisible(grDevices::recordPlot(load = "aznyan"))
}

#' Cast `x` into integers if it's a `nativeRaster` object
#' @noRd
cast_nr <- function(nr) {
  if (!inherits(nr, "nativeRaster")) {
    rlang::abort("`nr` must be a nativeRaster object.")
  }
  as.integer(nr)
}

#' Take `x` and set its class to `nativeRaster`
#' @noRd
as_nr <- function(x) {
  class(x) <- c("nativeRaster", class(x))
  x
}

#' Match `x` to `values`
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
