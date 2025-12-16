#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @useDynLib aznyan, .registration = TRUE
## usethis namespace: end
NULL

#' Get or set number of OpenCV threads
#'
#' @param n An integer scalar larger than `1`.
#' If missing, returns the current number of threads.
#' @returns Current number of threads used by OpenCV.
#' @export
#' @keywords internal
aznyan_num_threads <- function(n) {
  if (missing(n)) {
    return(get_num_threads())
  }
  set_num_threads(n)
}

#' Convert image data into a recorded plot
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
    rlang::abort(msg, call = rlang::caller_env())
  }
  as.integer(nr)
}


#' Cast native raster into 4*(w*h)-dimensional integer matrix
#'
#' @param nr A `nativeRaster` object.
#' @param nm Name of `nr`
#' @returns integer matrix
#' @noRd
nr_to_rgba <- function(nr, nm) {
  if (missing(nm)) {
    nm <- deparse1(substitute(nr))
  }
  cast_nr(nr, nm) |>
    azny_unpack_integers()
}

#' Check if two nativeRaster objects have the same dimensions
#' @noRd
check_nr_dim <- function(src, dst) {
  if (!identical(dim(src), dim(dst))) {
    rlang::abort(
      "The two nativeRaster objects must have the same dimensions.",
      call = rlang::caller_env()
    )
  }
  invisible(NULL)
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
    rlang::abort(msg, call = rlang::caller_env())
  }
  tmp
}
