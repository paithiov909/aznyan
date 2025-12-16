#' Detail enhancement filter
#'
#' Applies OpenCV's `detailEnhance` to a `nativeRaster` image.
#' This filter enhances fine structures such as
#' edges and textures while preserving the overall appearance of the image.
#'
#' @param nr A `nativeRaster` object.
#' @param sgmS
#'  A numeric scalar giving the spatial sigma used for edge-preserving
#'  filtering. Larger values increase the spatial smoothing radius.
#'  Valid range: `0–200`.
#' @param sgmR A numeric scalar giving the range sigma controlling how strongly
#'  edges are preserved based on color differences.
#'  Valid range: `0–1`.
#' @returns A `nativeRaster` object.
#' @export
detail_enchance <- function(
  nr,
  sgmS = 10, # nolint
  sgmR = 0.15 # nolint
) {
  out <- azny_det_enhance(cast_nr(nr), nrow(nr), ncol(nr), sgmS, sgmR)
  as_nr(out)
}

#' Histogram equalization
#'
#' Performs histogram equalization on a `nativeRaster` image.
#' This function supports both standard histogram equalization
#' and adaptive histogram equalization (CLAHE).
#' Optionally, the equalized luminance can be merged back
#' into the original color channels to produce a color-preserving enhancement.
#'
#' @param nr A `nativeRaster` object.
#' @param limit A numeric scalar giving the clip limit used for adaptive
#'  histogram equalization (CLAHE). Ignored when `adp = FALSE`.
#'  Typical range: values around `40` are common.
#' @param grid An integer vector of length 2 specifying the grid size
#'  (`width`, `height`) for dividing the image when using CLAHE.
#' @param adp A logical scalar.
#'  If `TRUE`, uses adaptive histogram equalization (CLAHE).
#'  If `FALSE`, applies standard histogram equalization.
#' @param color A logical scalar.
#'  If `TRUE`, apply the equalized luminance back to the original BGR channels;
#'  if `FALSE`, return a grayscale-based result.
#' @returns A `nativeRaster` object.
#' @export
hist_eq <- function(
  nr,
  limit = 40,
  grid = c(8, 8),
  adp = FALSE,
  color = FALSE
) {
  grid <- as.integer(grid)
  if (anyNA(grid)) {
    rlang::abort("`grid` must be an integer vector of length 2.")
  }
  out <- azny_hist_eq(
    cast_nr(nr),
    nrow(nr),
    ncol(nr),
    grid[1],
    grid[2],
    limit,
    adp,
    color
  )
  as_nr(out)
}

#' Mean shift filtering
#'
#' Applies mean shift filtering to a `nativeRaster` image.
#' This edge-preserving smoothing technique groups pixels
#' in joint spatial–color space,
#' producing a stylized effect with flattened regions
#' while retaining clear boundaries.
#'
#' @param nr A `nativeRaster` object.
#' @param sp A numeric scalar giving the spatial window radius.
#'  Larger values increase the smoothing effect across neighboring pixels.
#' @param sr A numeric scalar giving the color (range) window radius.
#'  Larger values allow grouping across larger color differences.
#' @param max_level An integer scalar specifying the number of pyramid levels
#'  to process. Must be non-negative.
#' @returns A `nativeRaster` object.
#' @export
mean_shift <- function(nr, sp = 10, sr = 30, max_level = 1) {
  out <- azny_meanshift(
    cast_nr(nr),
    nrow(nr),
    ncol(nr),
    sp,
    sr,
    as.integer(max_level)
  )
  as_nr(out)
}

#' Oil painting effect
#'
#' Applies an oil-paint–style effect to a `nativeRaster` image.
#' This filter produces a painterly appearance
#' by quantizing and aggregating colors within a local neighborhood.
#'
#' @param nr A `nativeRaster` object.
#' @param size An integer scalar specifying the radius of the neighborhood
#'  used for computing the oil painting effect. Must be at least `2`.
#' @param ratio An integer scalar controlling the number of intensity bins
#'  used in the stylization process.
#'  Larger values preserve finer variations in tone.
#' @returns A `nativeRaster` object.
#' @export
oilpaint <- function(nr, size = 10, ratio = 1) {
  out <- azny_oilpaint(
    cast_nr(nr),
    nrow(nr),
    ncol(nr),
    as.integer(size),
    as.integer(ratio)
  )
  as_nr(out)
}

#' Pencil sketch effect
#'
#' Generates a pencil-sketch–style rendering of a `nativeRaster` image.
#' This filter produces grayscale or color pencil–like strokes by combining
#' edge extraction with tone mapping.
#'
#' @param nr A `nativeRaster` object.
#' @param sgmS A numeric scalar giving the spatial sigma controlling the
#'  smoothness of the underlying edge-preserving filter.
#'  Valid range: `0–200`.
#' @param sgmR A numeric scalar giving the range sigma controlling sensitivity
#'  to color differences when building the sketch effect.
#'  Valid range: `0–1`.
#' @param shade A numeric scalar specifying the shading factor determining
#'  how much texture is included in the sketch.
#'  Valid range: `0–1`.
#' @param color A logical scalar.
#'  If `TRUE`, return the stylized color sketch;
#'  if `FALSE`, return the grayscale pencil sketch.
#' @returns A `nativeRaster` object.
#' @export
pencil_sketch <- function(
  nr,
  sgmS = 60, # nolint
  sgmR = 0.07, # nolint
  shade = 0.02,
  color = FALSE
) {
  out <- azny_pencilskc(
    cast_nr(nr),
    nrow(nr),
    ncol(nr),
    sgmS,
    sgmR,
    shade,
    color
  )
  as_nr(out)
}

#' Edge-preserving smoothing filter
#'
#' Applies an edge-preserving smoothing filter to a `nativeRaster` image.
#' This filter attenuates noise and texture while retaining sharp boundaries,
#' producing a clean, stylized appearance.
#'
#' @param nr A `nativeRaster` object.
#' @param sgmS A numeric scalar giving the spatial sigma, which controls the
#' effective smoothing radius.
#' Valid range: `0–200`.
#' @param sgmR A numeric scalar giving the range sigma, which determines how
#' strongly edges are preserved based on color differences.
#' Valid range: `0–1`.
#' @param recursive A logical scalar.
#' If `TRUE`, use the recursive filtering mode (`RECURS_FILTER`);
#' if `FALSE`, use normalized convolution (`NORMCONV_FILTER`).
#' @returns A `nativeRaster` object.
#' @export
preserve_edge <- function(
  nr,
  sgmS = 60, # nolint
  sgmR = 0.44, # nolint
  recursive = TRUE
) {
  out <- azny_preserving(
    cast_nr(nr),
    nrow(nr),
    ncol(nr),
    sgmS,
    sgmR,
    recursive
  )
  as_nr(out)
}

#' Stylization filter
#'
#' Applies a stylization effect to a `nativeRaster` image.
#' This filter combines edge-aware smoothing
#' and abstraction to produce a painterly,
#' cartoon-like appearance while preserving prominent structures.
#'
#' @param nr A `nativeRaster` object.
#' @param sgmS A numeric scalar giving the spatial sigma controlling the
#'  smoothness of the stylization process.
#'  Valid range: `0–200`.
#' @param sgmR A numeric scalar giving the range sigma determining sensitivity
#'  to color differences during abstraction.
#'  Valid range: `0–1`.
#' @returns A `nativeRaster` object.
#' @export
stylize <- function(
  nr,
  sgmS = 60, # nolint
  sgmR = 0.44 # nolint
) {
  out <- azny_stylize(cast_nr(nr), nrow(nr), ncol(nr), sgmS, sgmR)
  as_nr(out)
}
