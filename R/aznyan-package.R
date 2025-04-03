#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @useDynLib aznyan, .registration = TRUE
## usethis namespace: end
NULL

#' Convert PNG image data into recorded plot
#'
#' @param png A raw vector of PNG image.
#' @returns A recorded plot.
#' @export
as_recordedplot <- function(png) {
  if (!requireNamespace("png", quietly = TRUE)) {
    rlang::abort("png package is required.")
  }
  graphics::plot.new()
  grid::grid.raster(png::readPNG(png, native = TRUE))
  grDevices::recordPlot(load = "aznyan")
}

int_match <- function(x, arg, values) {
  x <- match(x[1], values) - 1L
  if (is.na(x)) {
    msg <- glue::glue(
      "`{arg}` must be one of {paste0(values, collapse = ', ')}. Got {x}."
    )
    rlang::abort(msg)
  }
  x
}
