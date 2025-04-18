# Generated by cpp11: do not edit by hand

azny_medianblur <- function(png, ksize) {
  .Call(`_aznyan_azny_medianblur`, png, ksize)
}

azny_boxblur <- function(png, boxW, boxH, normalize, border) {
  .Call(`_aznyan_azny_boxblur`, png, boxW, boxH, normalize, border)
}

azny_gaussianblur <- function(png, boxW, boxH, sigmaX, sigmaY, border) {
  .Call(`_aznyan_azny_gaussianblur`, png, boxW, boxH, sigmaX, sigmaY, border)
}

azny_bilateralblur <- function(png, d, sigmacolor, sigmaspace, border, alphasync) {
  .Call(`_aznyan_azny_bilateralblur`, png, d, sigmacolor, sigmaspace, border, alphasync)
}

azny_diffusion <- function(png, iter, decay_factor, decay_offset, gamma, sigma) {
  .Call(`_aznyan_azny_diffusion`, png, iter, decay_factor, decay_offset, gamma, sigma)
}

azny_cannyfilter <- function(png, asize, balp, gradient, thres1, thres2) {
  .Call(`_aznyan_azny_cannyfilter`, png, asize, balp, gradient, thres1, thres2)
}

azny_cannyrgb <- function(png, asize, balp, gradient, thres1, thres2) {
  .Call(`_aznyan_azny_cannyrgb`, png, asize, balp, gradient, thres1, thres2)
}

azny_laplacianfilter <- function(png, ksize, balp, border, scale, delta) {
  .Call(`_aznyan_azny_laplacianfilter`, png, ksize, balp, border, scale, delta)
}

azny_laplacianrgb <- function(png, ksize, balp, border, scale, delta) {
  .Call(`_aznyan_azny_laplacianrgb`, png, ksize, balp, border, scale, delta)
}

azny_sobelfilter <- function(png, ksize, balp, dx, dy, border, scale, delta) {
  .Call(`_aznyan_azny_sobelfilter`, png, ksize, balp, dx, dy, border, scale, delta)
}

azny_sobelrgb <- function(png, ksize, balp, dx, dy, border, scale, delta) {
  .Call(`_aznyan_azny_sobelrgb`, png, ksize, balp, dx, dy, border, scale, delta)
}

azny_swap_channels <- function(png, mapping) {
  .Call(`_aznyan_azny_swap_channels`, png, mapping)
}

azny_resize <- function(png, wh, resize_mode, set_size) {
  .Call(`_aznyan_azny_resize`, png, wh, resize_mode, set_size)
}

azny_resample <- function(png, wh, resize_red, resize_exp) {
  .Call(`_aznyan_azny_resample`, png, wh, resize_red, resize_exp)
}

azny_morphologyfilter <- function(png, ksize, ktype, mode, iterations, border, alphasync, pt) {
  .Call(`_aznyan_azny_morphologyfilter`, png, ksize, ktype, mode, iterations, border, alphasync, pt)
}

azny_morphologyrgb <- function(png, ksize, ktype, mode, iterations, border, alphasync, pt) {
  .Call(`_aznyan_azny_morphologyrgb`, png, ksize, ktype, mode, iterations, border, alphasync, pt)
}
