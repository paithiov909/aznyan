#' Image thresholding
#'
#' @param nr A `nativeRaster` object.
#' @param threshold The threshold value.
#' @param maxv The maximum value.
#' @param bsize The block size.
#' @param C The C value for adaptive thresholding.
#' @param mode The mode of thresholding.
#' @param invert Whether to invert the result in adaptive thresholding.
#' @returns A `nativeRaster` object.
#'
#' @rdname thres
#' @name thres
#' @aliases adpthres
NULL

#' @rdname thres
#' @export
thres <- function(
    nr,
    threshold = 100,
    maxv = 255,
    mode = c(0, 1, 2, 3, 4, 5, 6)) {
  if (threshold < 0 || threshold > 255) {
    rlang::abort("`threshold` must be in range [0, 255]")
  }
  if (maxv < 0 || maxv > 255) {
    rlang::abort("`maxv` must be in range [0, 255]")
  }
  mode <- int_match(mode, "mode", c(0, 1, 2, 3, 4, 5, 6))
  out <- azny_thres(cast_nr(nr), nrow(nr), ncol(nr), threshold, maxv, mode)
  as_nr(out)
}

#' @rdname thres
#' @export
adpthres <- function(
    nr,
    maxv = 255,
    bsize = 1,
    C = 5, # nolint
    mode = c(0, 1),
    invert = FALSE) {
  if (maxv < 0 || maxv > 255) {
    rlang::abort("`threshold` must be in range [0, 255]")
  }
  if (bsize < 1 || bsize > 50) {
    rlang::abort("`bsize` must be in range [1, 50]")
  }
  mode <- int_match(mode, "mode", c(0, 1))
  out <- azny_adpthres(cast_nr(nr), nrow(nr), ncol(nr), as.logical(mode), maxv, bsize, invert, C)
  as_nr(out)
}
