#' Sobel filter
#'
#' @param png A raw vector of PNG image.
#' @param ksize The size of kernel.
#' @param balp Whether to remove black background.
#' @param dx The direction of Sobel filter.
#' @param dy The direction of Sobel filter.
#' @param border The type of pixel extrapolation method.
#' @param use_rgb Whether to use RGB Sobel filter.
#' @param scale The scale of Sobel filter.
#' @param delta The delta of Sobel filter.
#' @returns A raw vector of PNG image.
#' @export
sobel_filter <- function(png, ksize = 3,
                         balp = TRUE,
                         dx = 1, dy = dx,
                         border = c(3, 4, 0, 1, 2),
                         use_rgb = TRUE,
                         scale = 1.0,
                         delta = 0.0) {
  border <- int_match(border, "border", c(0, 1, 2, 3, 4))
  if (use_rgb) {
    azny_sobelrgb(png, ksize, balp, dx, dy, border, scale, delta)
  } else {
    azny_sobelfilter(png, ksize, balp, dx, dy, border, scale, delta)
  }
}

#' Laplacian filter
#'
#' @param png A raw vector of PNG image.
#' @param ksize The size of kernel.
#' @param balp Whether to remove black background.
#' @param border The type of pixel extrapolation method.
#' @param use_rgb Whether to use RGB Laplacian filter.
#' @param scale The scale of Laplacian filter.
#' @param delta The delta of Laplacian filter.
#' @returns A raw vector of PNG image.
#' @export
laplacian_filter <- function(png, ksize = 3,
                             balp = TRUE,
                             border = c(3, 4, 0, 1, 2),
                             use_rgb = TRUE,
                             scale = 1.0,
                             delta = 0.0) {
  border <- int_match(border, "border", c(0, 1, 2, 3, 4))
  if (use_rgb) {
    azny_laplacianrgb(png, ksize, balp, border, scale, delta)
  } else {
    azny_laplacianfilter(png, ksize, balp, border, scale, delta)
  }
}

#' Canny filter
#'
#' @param png A raw vector of PNG image.
#' @param asize Aparture size for Sobel operation.
#' @param balp Whether to remove black background.
#' @param use_rgb Whether to use RGB Canny filter.
#' @param grad Flag to be passed to `L2gradient`.
#' @param thres1 The first threshold.
#' @param thres2 The second threshold.
#' @returns A raw vector of PNG image.
#' @export
canny_filter <- function(png, asize = 2,
                         balp = FALSE,
                         use_rgb = TRUE,
                         grad = TRUE,
                         thres1 = 100.0,
                         thres2 = 200.0) {
  if (use_rgb) {
    azny_cannyrgb(png, asize, balp, grad, thres1, thres2)
  } else {
    azny_cannyfilter(png, asize, balp, grad, thres1, thres2)
  }
}
