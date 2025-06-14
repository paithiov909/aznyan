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

azny_write_smcube <- function(input_path, output_path) {
  .Call(`_aznyan_azny_write_smcube`, input_path, output_path)
}

azny_read_cube <- function(file_path, verbose) {
  .Call(`_aznyan_azny_read_cube`, file_path, verbose)
}

azny_apply_cube <- function(png, lut_data, cube_size, intensity, is_r_fastest) {
  .Call(`_aznyan_azny_apply_cube`, png, lut_data, cube_size, intensity, is_r_fastest)
}

azny_decode_rec709 <- function(in_vec) {
  .Call(`_aznyan_azny_decode_rec709`, in_vec)
}

azny_encode_rec709 <- function(in_vec) {
  .Call(`_aznyan_azny_encode_rec709`, in_vec)
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

azny_meanshift <- function(png, sp, sr, maxl) {
  .Call(`_aznyan_azny_meanshift`, png, sp, sr, maxl)
}

azny_preserve_edges <- function(png, sgmS, sgmR, mode) {
  .Call(`_aznyan_azny_preserve_edges`, png, sgmS, sgmR, mode)
}

azny_thres <- function(png, thres, maxv, mode) {
  .Call(`_aznyan_azny_thres`, png, thres, maxv, mode)
}

azny_adpthres <- function(png, adpthres, maxv, bsize, mode, valC) {
  .Call(`_aznyan_azny_adpthres`, png, adpthres, maxv, bsize, mode, valC)
}
