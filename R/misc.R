#' Create a native raster filled with a color
#'
#' @param color Color name or hex code.
#' @param width,height A positive integer scalar.
#' @returns A `nativeRaster` object.
#' @export
fill_with <- function(color, width, height) {
  packed_int <- colorfast::col_to_int(color[1])
  out <- matrix(packed_int, nrow = height, ncol = width)
  as_nr(out)
}

#' Select pixel positions from a nativeRaster object
#'
#' @description
#' This function scans a `nativeRaster` image and returns the positions
#' (row, column, and linear index) of pixels whose values fall within a given
#' range.
#'
#' Optionally, pixels can be grouped into contiguous runs along rows or columns,
#' and only runs of a minimum length can be retained.
#' This makes it suitable as a building block for pixel sorting
#' or other effects that operate on contiguous pixel segments.
#'
#' @details
#' Pixel values are normalized to the range `[0, 1]` before comparison.
#' For `"hue"`, `"luminance"`, and `"saturation"`, the image is
#' internally converted to HLS color space using OpenCV.
#'
#' @param nr A `nativeRaster` object.
#' @param range A numeric vector of length 2 specifying the lower and upper
#'   bounds (in `[0, 1]`) used to select pixels.
#' @param by A string specifying which pixel value to use for selection.
#' @param direction Direction used to define contiguous runs when
#'   `min_length > 1`. Either `"row"` (horizontal runs) or
#'   `"col"` (vertical runs).
#' @param min_length Minimum length of contiguous pixel runs to retain.
#'   If `min_length <= 1`, all matching pixels are returned without
#'   run grouping.
#'
#' @returns
#' If `min_length <= 1`, a tibble with columns:
#'   * row: Row index (1-based).
#'   * col: Column index (1-based).
#'   * index: Linear index in the nativeRaster vector (1-based).
#'
#' If `min_length > 1`, a tibble with columns:
#'   * group: Row or column index defining the scan direction.
#'   * pos: Position within each group.
#'   * run: Contiguous run identifier.
#'   * index: Linear index in the nativeRaster vector (1-based).
#'
#' @importFrom rlang .data
#' @export
pixel_positions <- function(
  nr,
  range = c(0, .5),
  by = c("luma", "blue", "green", "red", "hue", "luminance", "saturation"),
  direction = c("row", "col"),
  min_length = 1
) {
  by <- rlang::arg_match(by)
  mode <-
    wh0(
      c("luma", "blue", "green", "red", "hue", "luminance", "saturation") == by
    )
  range <- clamp(range, 0, 1)

  ret <-
    azny_pixel_positions(
      cast_nr(nr),
      nrow(nr),
      ncol(nr),
      mode,
      min(range),
      max(range)
    ) |>
    as.data.frame()

  colnames(ret) <- c("row", "col", "index")
  out <- structure(ret, class = c("tbl_df", "tbl", "data.frame"))

  if (min_length <= 1) {
    return(out)
  }

  if (!requireNamespace("dplyr", quietly = TRUE)) {
    cli::cli_abort("dplyr is required to filter pixels")
  }
  direction <- rlang::arg_match(direction, c("row", "col"))
  out |>
    dplyr::rename_with(
      ~ if (direction == "row") {
        c("group", "pos", "index")
      } else {
        c("pos", "group", "index")
      }
    ) |>
    dplyr::arrange(.data$group, .data$pos) |>
    dplyr::group_by(.data$group) |>
    dplyr::mutate(
      run = cumsum(
        .data$pos != dplyr::lag(.data$pos, default = .data$pos[1] - 1L) + 1L
      )
    ) |>
    dplyr::ungroup() |>
    dplyr::group_by(.data$group, .data$run) |>
    dplyr::filter(dplyr::n() >= min_length) |>
    dplyr::ungroup() |>
    dplyr::select(c("group", "pos", "run", "index"))
}

#' Pack and unpack RGBA values
#'
#' @param r,g,b,a Numeric vectors of equal length in range `[0, 255]`.
#' @param x An integer vector that contains native packed integers.
#' @returns Integers.
#' @rdname pack-unpack
#' @name pack-unpack
NULL

#' @rdname pack-unpack
#' @export
pack_color <- function(r, g, b, a) {
  rgb <-
    rbind(
      floor(r),
      floor(g),
      floor(b)
    )
  a <- floor(a)
  as.integer(azny_pack_integers(rgb, a, 1, length(a)))
}

#' @rdname pack-unpack
#' @export
unpack_color <- function(x) azny_unpack_integers(as.integer(x))

#' Conversion between RGB and HLS color spaces
#'
#' @param x An integer matrix with 3 rows.
#' @returns An integer matrix of the same size as `x`
#' @rdname rgb-hls
#' @name rgb-hls
NULL

#' @rdname rgb-hls
#' @export
rgb2hls <- function(x) azny_rgb_to_hls(floor(x))

#' @rdname rgb-hls
#' @export
hls2rgb <- function(x) azny_hls_to_rgb(floor(x))

#' Swap or remap image channels
#'
#' Remaps color or alpha channels of a `nativeRaster` image using arbitrary
#' pairwise assignments. This function wraps OpenCV's `mixChannels`, allowing
#' reordering or selective copying of the BGRA channels.
#'
#' @param nr A `nativeRaster` object.
#' @param from An integer vector of length 4 giving the source channel indices
#'  (`0 = B`, `1 = G`, `2 = R`, `3 = A`). Each element specifies which channel
#'  to read from.
#' @param to An integer vector of length 4 giving the destination channel
#'  indices (`0 = B`, `1 = G`, `2 = R`, `3 = A`). Each element specifies where
#'  the corresponding `from` channel is written.
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
#' Resizes an image either by specifying a scaling factor (`wh`) or, when
#' `set_size = TRUE`, by specifying a target width and height directly.
#' Interpolation is controlled through `resize_mode`.
#'
#' ## `resample()`
#' Downsamples and then upsamples an image, potentially using different
#' interpolation modes for reduction and expansion. This can be used to create
#' stylized pixelation or texture effects, depending on the scaling factors and
#' interpolation methods.
#'
#' @param nr A `nativeRaster` object.
#' @param wh A numeric vector of length 2.
#'
#' * For `resize()`: scaling factors when `set_size = FALSE`, or target dimensions (`width`, `height`) when `set_size = TRUE`.
#' * For `resample()`: downsampling factors in each direction.
#'
#' @param resize_mode An integer scalar selecting the interpolation mode for `resize()`.
#'  Must be one of `0–6`, corresponding to OpenCV's interpolation flags.
#' @param set_size A logical scalar.
#'  If `TRUE`, `wh` is interpreted as absolute output dimensions;
#'  if `FALSE`, `wh` is used as scaling factors.
#' @param resize_mode1 An integer scalar giving the interpolation mode for the
#'  downsampling step in `resample()`. Must be one of `0–6`.
#' @param resize_mode2 An integer scalar giving the interpolation mode for the
#'  upsampling step in `resample()`. Must be one of `0–6`.
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

#' Warp a `nativeRaster` image using perspective transformation
#'
#' Warps an image using a perspective transformation,
#' keeping the same dimensions as the input image.
#'
#' @details
#' `border` corresponds to the OpenCV extrapolation types:
#'
#' 0. cv::BORDER_CONSTANT
#' 1. cv::BORDER_REPLICATE
#' 2. cv::BORDER_REFLECT
#' 3. cv::BORDER_WRAP
#' 4. cv::BORDER_REFLECT_101
#'
#' @param nr A `nativeRaster` object.
#' @param mat A 3x3 matrix specifying the perspective transformation.
#' @param border An integer scalar selecting pixel extrapolation method.
#' @returns A `nativeRaster` object.
#' @export
warp_perspective <- function(
  nr,
  mat = diag(1, 3),
  border = c(3, 4, 0, 1, 2)
) {
  border <- int_match(border, "border", c(0, 1, 2, 3, 4))
  if (anyNA(mat)) {
    cli::cli_abort("mat must not contain NAs")
  }
  out <- azny_warp_perspective(
    cast_nr(nr),
    nrow(nr),
    ncol(nr),
    as.matrix(mat),
    border
  )
  as_nr(out)
}
