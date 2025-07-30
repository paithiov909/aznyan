#' Swap channels
#'
#' @param nr A `nativeRaster` object.
#' @param from The channels to swap from.
#' @param to The channels to swap to.
#' @returns A `nativeRaster` object.
#' @export
swap_channels <- function(nr, from = c(0, 1, 2, 3), to = c(1, 2, 0, 3)) {
  mapping <- c(rbind(from, to))
  out <- azny_swap_channels(
    cast_nr(nr),
    nrow(nr),
    ncol(nr),
    as.integer(mapping)
  )
  as_nr(out)
}

#' Resize image
#'
#' @param nr A `nativeRaster` object.
#' @param wh The width and height.
#' @param resize_mode The resize mode.
#' @param set_size Whether `wh` is actual width and height instead of coef.
#' @returns A `nativeRaster` object.
#' @export
resize <- function(
  nr,
  wh = c(1.0, 1.0),
  resize_mode = c(1, 2, 3, 4, 5, 6, 0),
  set_size = FALSE
) {
  resize_mode <- int_match(resize_mode, "resize_mode", c(0, 1, 2, 3, 4, 5, 6))
  out <- azny_resize(
    cast_nr(nr),
    nrow(nr),
    ncol(nr),
    as.double(wh[1:2]),
    resize_mode,
    set_size
  )
  as_nr(out)
}

#' Resample image
#'
#' @param nr A `nativeRaster` object.
#' @param wh The width and height coef for reduction.
#' @param resize_mode1 The resize mode for reduction.
#' @param resize_mode2 The resize mode for expansion.
#' @returns A `nativeRaster` object.
#' @export
resample <- function(
  nr,
  wh = c(0.2, 0.2),
  resize_mode1 = c(1, 2, 3, 4, 5, 6, 0),
  resize_mode2 = c(1, 2, 3, 4, 5, 6, 0)
) {
  resize_red <- int_match(resize_mode1, "resize_mode1", c(0, 1, 2, 3, 4, 5, 6))
  resize_exp <- int_match(resize_mode2, "resize_mode2", c(0, 1, 2, 3, 4, 5, 6))
  out <- azny_resample(
    cast_nr(nr),
    nrow(nr),
    ncol(nr),
    as.double(wh[1:2]),
    resize_red,
    resize_exp
  )
  as_nr(out)
}
