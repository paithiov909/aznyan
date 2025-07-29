#' Sobel filter
#'
#' @param nr A `nativeRaster` object.
#' @param ksize The size of kernel.
#' @param balp Whether to remove black background.
#' @param dx The direction of Sobel filter.
#' @param dy The direction of Sobel filter.
#' @param border The type of pixel extrapolation method.
#' @param use_rgb Whether to use RGB Sobel filter.
#' @param scale The scale of Sobel filter.
#' @param delta The delta of Sobel filter.
#' @returns A `nativeRaster` object.
#' @export
sobel_filter <- function(
    nr,
    ksize = 3,
    balp = TRUE,
    dx = 1,
    dy = dx,
    border = c(3, 4, 0, 1, 2),
    use_rgb = TRUE,
    scale = 1.0,
    delta = 0.0) {
  border <- int_match(border, "border", c(0, 1, 2, 3, 4))
  if (use_rgb) {
    out <- azny_sobelrgb(cast_nr(nr), nrow(nr), ncol(nr), ksize, balp, dx, dy, border, scale, delta)
  } else {
    out <- azny_sobelfilter(cast_nr(nr), nrow(nr), ncol(nr), ksize, balp, dx, dy, border, scale, delta)
  }
  as_nr(out)
}

#' Laplacian filter
#'
#' @param nr A `nativeRaster` object.
#' @param ksize The size of kernel.
#' @param balp Whether to remove black background.
#' @param border The type of pixel extrapolation method.
#' @param use_rgb Whether to use RGB Laplacian filter.
#' @param scale The scale of Laplacian filter.
#' @param delta The delta of Laplacian filter.
#' @returns A `nativeRaster` object.
#' @export
laplacian_filter <- function(
    nr,
    ksize = 3,
    balp = TRUE,
    border = c(3, 4, 0, 1, 2),
    use_rgb = TRUE,
    scale = 1.0,
    delta = 0.0) {
  border <- int_match(border, "border", c(0, 1, 2, 3, 4))
  if (use_rgb) {
    out <- azny_laplacianrgb(cast_nr(nr), nrow(nr), ncol(nr), ksize, balp, border, scale, delta)
  } else {
    out <- azny_laplacianfilter(cast_nr(nr), nrow(nr), ncol(nr), ksize, balp, border, scale, delta)
  }
  as_nr(out)
}

#' Canny filter
#'
#' @param nr A `nativeRaster` object.
#' @param asize Aparture size for Sobel operation.
#' @param balp Whether to remove black background.
#' @param use_rgb Whether to use RGB Canny filter.
#' @param grad Flag to be passed to `L2gradient`.
#' @param thres1 The first threshold.
#' @param thres2 The second threshold.
#' @returns A `nativeRaster` object.
#' @export
canny_filter <- function(
    nr,
    asize = 2,
    balp = FALSE,
    use_rgb = TRUE,
    grad = TRUE,
    thres1 = 100.0,
    thres2 = 200.0) {
  if (use_rgb) {
    out <- azny_cannyrgb(cast_nr(nr), nrow(nr), ncol(nr), asize, balp, grad, thres1, thres2)
  } else {
    out <- azny_cannyfilter(cast_nr(nr), nrow(nr), ncol(nr), asize, balp, grad, thres1, thres2)
  }
  as_nr(out)
}
