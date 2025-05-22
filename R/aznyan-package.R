#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @useDynLib aznyan, .registration = TRUE
#' @importFrom utils write.table
## usethis namespace: end
NULL

#' Convert PNG image data into recorded plot
#'
#' @param png A raw vector of PNG image.
#' @returns A recorded plot is invisibly returned.
#' @export
as_recordedplot <- function(png) {
  if (!requireNamespace("fastpng", quietly = TRUE)) {
    rlang::abort("fastpng package is required.")
  }
  png <- fastpng::read_png(png, type = "nativeraster", rgba = TRUE)
  grid::grid.newpage(recording = FALSE)
  grid::grid.raster(png)
  invisible(grDevices::recordPlot(load = "aznyan"))
}

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
