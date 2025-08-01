#' Create color code while premultiplying alpha
#'
#' @param r,g,b,a Numeric scalars.
#' @param max A numeric scalar.
#' @returns A color code.
#' @export
premul <- function(r, g, b, a, max = 255) {
  alpha <- a / max
  grDevices::rgb(r * alpha, g * alpha, b * alpha, a, maxColorValue = max)
}

#' Apply predefined color filter
#'
#' @description
#' Applies one of the predefined color filters
#' that are ported from [Rustagram](https://github.com/ha-shine/rustagram).
#'
#' The following filters are available:
#' - 1977
#' - aden
#' - brannan
#' - brooklyn
#' - clarendon
#' - earlybird
#' - gingham
#' - hudson
#' - inkwell
#' - kelvin
#' - lark
#' - lofi
#' - maven
#' - mayfair
#' - moon
#' - nashville
#' - reyes
#' - rise
#' - slumber
#' - stinson
#' - toaster
#' - valencia
#' - walden
#'
#' @param nr A `nativeRaster` object.
#' @param filter The name of the filter.
#' @returns A `nativeRaster` object.
#' @export
apply_filter <- function(
    nr,
    filter = c(
      "1977", "aden", "brannan", "brooklyn", "clarendon", "earlybird", "gingham",
      "hudson", "inkwell", "kelvin", "lark", "lofi", "maven", "mayfair", "moon",
      "nashville", "reyes", "rise", "slumber", "stinson", "toaster", "valencia",
      "walden"
    )) {
  filter <- rlang::arg_match(filter)
  switch(filter,
    "1977" = apply_1977(nr),
    "aden" = apply_aden(nr),
    "brannan" = apply_brannan(nr),
    "brooklyn" = apply_brooklyn(nr),
    "clarendon" = apply_clarendon(nr),
    "earlybird" = apply_earlybird(nr),
    "gingham" = apply_gingham(nr),
    "hudson" = apply_hudson(nr),
    "inkwell" = apply_inkwell(nr),
    "kelvin" = apply_kelvin(nr),
    "lark" = apply_lark(nr),
    "lofi" = apply_lofi(nr),
    "maven" = apply_maven(nr),
    "mayfair" = apply_mayfair(nr),
    "moon" = apply_moon(nr),
    "nashville" = apply_nashville(nr),
    "reyes" = apply_reyes(nr),
    "rise" = apply_rise(nr),
    "slumber" = apply_slumber(nr),
    "stinson" = apply_stinson(nr),
    "toaster" = apply_toaster(nr),
    "valencia" = apply_valencia(nr),
    "walden" = apply_walden(nr)
  )
}

#' @noRd
apply_1977 <- function(nr) {
  bg <-
    contrast(nr, .1) |>
    brighten(.1) |>
    saturate(.3)
  fg <- fill_with(ncol(nr), nrow(nr), premul(243, 106, 188, 76))
  blend_screen(fg, bg)
}

#' @noRd
apply_aden <- function(nr) {
  hue_rotate(nr, -.3490659) |> # -20 deg
    contrast(-.1) |>
    saturate(-.2) |>
    brighten(.2) |>
    restore_transparency()
}

#' @noRd
apply_brannan <- function(nr) {
  bg <- sepia(nr, .2) |>
    contrast(.2)
  fg <- fill_with(ncol(nr), nrow(nr), premul(161, 44, 199, 59))
  blend_lighten(fg, bg)
}

#' @noRd
apply_brooklyn <- function(nr) {
  bg <- contrast(nr, -.1) |>
    brighten(.1) |>
    restore_transparency()
  fg <- fill_with(ncol(nr), nrow(nr), premul(168, 223, 193, 150))
  blend_overlay(fg, bg)
}

#' @noRd
apply_clarendon <- function(nr) {
  bg <- contrast(nr, .2) |>
    saturate(.35)
  fg <- fill_with(ncol(nr), nrow(nr), premul(127, 187, 227, 101))
  blend_overlay(fg, bg)
}

#' @noRd
apply_earlybird <- function(nr) {
  bg <- contrast(nr, -.1) |>
    sepia(.05)
  fg <- fill_with(ncol(nr), nrow(nr), premul(208, 186, 142, 150))
  blend_overlay(fg, bg)
}

#' @noRd
apply_gingham <- function(nr) {
  bg <- brighten(nr, .05) |>
    hue_rotate(-.1745329) # -10 deg
  fg <- fill_with(ncol(nr), nrow(nr), premul(230, 230, 230, 255))
  blend_softlight(fg, bg)
}

#' @noRd
apply_hudson <- function(nr) {
  bg <- brighten(nr, .5) |>
    contrast(-.1) |>
    saturate(.1)
  fg <- fill_with(ncol(nr), nrow(nr), premul(166, 177, 255, 208))
  out <- blend_multiply(fg, bg)
  restore_transparency(out)
}

#' @noRd
apply_inkwell <- function(nr) {
  sepia(nr, .3) |>
    contrast(.1) |>
    brighten(.1) |>
    grayscale()
}

#' @noRd
apply_kelvin <- function(nr) {
  bg <-
    blend_colordodge(
      nr,
      fill_with(ncol(nr), nrow(nr), premul(56, 44, 52, 255))
    )
  fg <- fill_with(ncol(nr), nrow(nr), premul(183, 125, 33, 255))
  blend_overlay(fg, bg)
}

#' @noRd
apply_lark <- function(nr) {
  bg <- contrast(nr, -.1) |>
    blend_colordodge(
      fill_with(ncol(nr), nrow(nr), premul(34, 37, 63, 255))
    )
  fg <- fill_with(ncol(nr), nrow(nr), premul(242, 242, 242, 204))
  blend_darken(fg, bg)
}

#' @noRd
apply_lofi <- function(nr) {
  nr |>
    saturate(.1) |>
    contrast(.5)
}

#' @noRd
apply_maven <- function(nr) {
  nr |>
    sepia(.25) |>
    brighten(-.005) |>
    contrast(-.005) |>
    saturate(.5)
}

#' @noRd
apply_mayfair <- function(nr) {
  bg <- contrast(nr, .1) |>
    saturate(.1)
  fg <- fill_with(ncol(nr), nrow(nr), premul(255, 200, 200, 153))
  blend_overlay(fg, bg)
}

#' @noRd
apply_moon <- function(nr) {
  bg <- contrast(nr, .1) |>
    brighten(.1) |>
    blend_softlight(
      fill_with(ncol(nr), nrow(nr), premul(160, 160, 160, 255)),
      dst = _
    )
  fg <- fill_with(ncol(nr), nrow(nr), premul(56, 56, 56, 255))
  out <- blend_lighten(fg, bg)
  grayscale(out)
}

#' @noRd
apply_nashville <- function(nr) {
  bg <- sepia(nr, .02) |>
    contrast(.2) |>
    brighten(.05) |>
    saturate(.2) |>
    blend_darken(
      fill_with(ncol(nr), nrow(nr), premul(247, 176, 143, 243)),
      dst = _
    )
  fg <- fill_with(ncol(nr), nrow(nr), premul(0, 70, 150, 230))
  blend_lighten(fg, bg)
}
