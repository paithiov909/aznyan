#' Gamma and inverse gamma in 'Rec.709' color space
#'
#' @param x A numeric vector.
#' @returns A numeric vector.
#' @rdname rec709
#' @name rec709
NULL

#' @rdname rec709
#' @export
decode_rec709 <- function(x) azny_decode_rec709(x)

#' @rdname rec709
#' @export
encode_rec709 <- function(x) azny_encode_rec709(x)

#' Conversion between RGB and HSL
#'
#' @param x An integer matrix with 3 rows.
#' @returns An integer matrix of the same size as `x`
#' @rdname rgb-hsl
#' @name rgb-hsl
NULL

#' @rdname rgb-hsl
#' @export
rgb2hls <- function(x) azny_rgb_to_hls(x)

#' @rdname rgb-hsl
#' @export
hls2rgb <- function(x) azny_hls_to_rgb(x)

#' @export
fill_with <- function(width, height, color) {
  packed_int <- colorfast::col_to_int(color) |>
    rep(width * height)
  dim(packed_int) <- c(height, width)
  as_nr(packed_int)
}

#' @export
contrast <- function(nr, amount) {
  sz <- dim(nr)
  ret <- nr_to_rgba(nr, "nr")
  rgb <- clamp((ret[1:3, ] / 255 - 0.5) * amount + 0.5, 0, 1) * 255
  as_nr(azny_pack_integers(rgb, ret[4, ] * 1, sz[1], sz[2]))
}

#' @export
brighten <- function(nr, amount) {
  sz <- dim(nr)
  ret <- nr_to_rgba(nr, "nr")
  rgb <- clamp((ret[1:3, ] / 255) * (1 + amount), 0, 1) * 255
  as_nr(azny_pack_integers(rgb, ret[4, ] * 1, sz[1], sz[2]))
}

#' @export
darken <- function(nr, amount) {
  sz <- dim(nr)
  ret <- nr_to_rgba(nr, "nr")
  rgb <- clamp((ret[1:3, ] / 255) * (1 - amount), 0, 1) * 255
  as_nr(azny_pack_integers(rgb, ret[4, ] * 1, sz[1], sz[2]))
}

#' @export
grayscale <- function(nr) {
  sz <- dim(nr)
  ret <- nr_to_rgba(nr, "nr")
  rgb <- t(colSums(ret[1:3, ]) / 3) %x% c(1, 1, 1)
  as_nr(azny_pack_integers(rgb, ret[4, ] * 1, sz[1], sz[2]))
}

#' @export
sepia <- function(nr, intensity = 1, depth = 20) {
  sz <- dim(nr)
  ret <- nr_to_rgba(nr, "nr")
  rgb <- rbind(
    ret[1, ] + depth * 2,
    ret[2, ] + depth,
    colSums(ret[1:3, ]) / 3
  ) |>
    clamp(0, 255)
  rgb[3, ] <- clamp(rgb[3, ] - (rgb[3, ] * intensity), 0, 255)
  as_nr(azny_pack_integers(rgb, ret[4, ] * 1, sz[1], sz[2]))
}

#' @export
saturate <- function(nr, amount) {
  sz <- dim(nr)
  ret <- nr_to_rgba(nr, "nr")
  hls <- rgb2hls(ret[1:3, ])
  hls[2, ] <- (azny_saturate_value(hls[2, ] / 255, amount) * 255) |>
    clamp(0, 255) |>
    as.integer()
  rgb <- hls2rgb(hls)
  as_nr(azny_pack_integers(rgb * 1, ret[4, ] * 1, sz[1], sz[2]))
}
