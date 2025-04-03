#' Sobel filter
#'
#' @param png A raw vector of PNG image.
#' @param ksize The size of kernel.
#' @param balp The angle of Sobel filter.
#' @param dx The direction of Sobel filter.
#' @param dy The direction of Sobel filter.
#' @param border The type of pixel extrapolation method.
#' @param scale The scale of Sobel filter.
#' @param delta The delta of Sobel filter.
#' @returns A raw vector of PNG image.
#' @name sobel-filter
#' @rdname sobel-filter
NULL

#' @rdname sobel-filter
#' @export
sobel_filter <- function(png, ksize = 3,
                         balp = TRUE,
                         dx = 1, dy = dx,
                         border = c(4, 0, 1, 2, 3),
                         scale = 1,
                         delta = 0) {
  border <- int_match(border, "border", c(0, 1, 2, 3, 4))
  azny_sobelfilter(png, ksize, balp, dx, dy, border, scale, delta)
}

#' @rdname sobel-filter
#' @export
sobel_rgb <- function(png, ksize = 3,
                      balp = TRUE,
                      dx = 1, dy = dx,
                      border = c(4, 0, 1, 2, 3),
                      scale = 1,
                      delta = 0) {
  border <- int_match(border, "border", c(0, 1, 2, 3, 4))
  azny_sobelrgb(png, ksize, balp, dx, dy, border, scale, delta)
}
