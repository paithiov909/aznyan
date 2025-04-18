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
  if (!requireNamespace("fastpng", quietly = TRUE)) {
    rlang::abort("fastpng package is required.")
  }
  png <- fastpng::read_png(png, type = "nativeraster", rgba = TRUE)
  grid::grid.newpage(recording = FALSE)
  grid::grid.raster(png)
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
