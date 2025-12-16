#' Swap or remap image channels
#'
#' Remaps color or alpha channels of a `nativeRaster` image using arbitrary
#' pairwise assignments. This function wraps OpenCV's `mixChannels`, allowing
#' reordering or selective copying of the BGRA channels.
#'
#' @param nr A `nativeRaster` object.
#' @param from An integer vector of length 4 giving the source channel indices
#' (`0 = B`, `1 = G`, `2 = R`, `3 = A`). Each element specifies which channel
#' to read from.
#' @param to An integer vector of length 4 giving the destination channel
#' indices (`0 = B`, `1 = G`, `2 = R`, `3 = A`). Each element specifies where
#' the corresponding `from` channel is written.
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

#' Resize or resample a `nativeRaster` image
#'
#' These functions provide flexible image scaling based on OpenCV's
#' `resize`, supporting both direct resizing and two-stage
#' downsample–upsample resampling. The operations apply to all BGRA channels.
#'
#' ## `resize()`
#'
#' Resizes an image either by specifying a scaling factor (`wh`) or, when
#' `set_size = TRUE`, by specifying a target width and height directly.
#' Interpolation is controlled through `resize_mode`.
#'
#' ## `resample()`
#'
#' Downsamples and then upsamples an image, potentially using different
#' interpolation modes for reduction and expansion. This can be used to create
#' stylized pixelation or texture effects, depending on the scaling factors and
#' interpolation methods.
#'
#' @param nr A `nativeRaster` object.
#' @param wh A numeric vector of length 2.
#' For `resize()`: scaling factors when `set_size = FALSE`, or target
#' dimensions (`width`, `height`) when `set_size = TRUE`.
#' For `resample()`: downsampling factors in each direction.
#' @param resize_mode An integer scalar selecting the interpolation mode for
#' `resize()`.
#' Must be one of `0–6`, corresponding to OpenCV's interpolation flags.
#' @param set_size A logical scalar.
#' If `TRUE`, `wh` is interpreted as absolute output dimensions;
#' if `FALSE`, `wh` is used as scaling factors.
#' @param resize_mode1 An integer scalar giving the interpolation mode for the
#' downsampling step in `resample()`. Must be one of `0–6`.
#' @param resize_mode2 An integer scalar giving the interpolation mode for the
#' upsampling step in `resample()`. Must be one of `0–6`.
#' @returns A `nativeRaster` object.
#' @rdname resize
#' @name resize
#' @aliases resample
NULL

#' @rdname resize
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

#' @rdname resize
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
