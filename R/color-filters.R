#' Create color codes while premultiplying alpha
#'
#' @param r,g,b,a Numeric vectors.
#' @param max An integer scalar. The maximum value of the color code.
#' @returns Color codes.
#' @export
premul <- function(r, g, b, a, max = 255L) {
  alpha <- a / max
  grDevices::rgb(r * alpha, g * alpha, b * alpha, a, maxColorValue = max)
}

#' Apply predefined color filter
#'
#' Applies one of the predefined color filters
#' that are ported from [Rustagram](https://github.com/ha-shine/rustagram).
#'
#' ## Options
#' The following filters are available:
#'
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
color_filter <- function(
  nr,
  filter = c(
    "1977",
    "aden",
    "brannan",
    "brooklyn",
    "clarendon",
    "earlybird",
    "gingham",
    "hudson",
    "inkwell",
    "kelvin",
    "lark",
    "lofi",
    "maven",
    "mayfair",
    "moon",
    "nashville",
    "reyes",
    "rise",
    "slumber",
    "stinson",
    "toaster",
    "valencia",
    "walden"
  )
) {
  filter <- rlang::arg_match(filter)
  switch(
    filter,
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
  fg <- fill_with(premul(243, 106, 188, 76), ncol(nr), nrow(nr))
  blend_screen(bg, fg) # bg, fg
}

#' @noRd
apply_aden <- function(nr) {
  hue_rotate(nr, -.3490659) |> # -20 deg
    contrast(-.1) |>
    saturate(-.2) |>
    brighten(.2) |>
    reset_alpha()
}

#' @noRd
apply_brannan <- function(nr) {
  bg <- sepia(nr, .2) |>
    contrast(.2)
  fg <- fill_with(premul(161, 44, 199, 59), ncol(nr), nrow(nr))
  blend_lighten(fg, bg)
}

#' @noRd
apply_brooklyn <- function(nr) {
  bg <- contrast(nr, -.1) |>
    brighten(.1) |>
    reset_alpha()
  fg <- fill_with(premul(168, 223, 193, 150), ncol(nr), nrow(nr))
  blend_overlay(fg, bg)
}

#' @noRd
apply_clarendon <- function(nr) {
  bg <- contrast(nr, .2) |>
    saturate(.35)
  fg <- fill_with(premul(127, 187, 227, 101), ncol(nr), nrow(nr))
  blend_overlay(fg, bg)
}

#' @noRd
apply_earlybird <- function(nr) {
  bg <- contrast(nr, -.1) |>
    sepia(.05)
  fg <- fill_with(premul(208, 186, 142, 150), ncol(nr), nrow(nr))
  out <- blend_overlay(bg, fg) # bg, fg
  reset_alpha(out)
}

#' @noRd
apply_gingham <- function(nr) {
  bg <- brighten(nr, .05) |>
    hue_rotate(-.1745329) # -10 deg
  fg <- fill_with(premul(230, 230, 230, 255), ncol(nr), nrow(nr))
  blend_softlight(fg, bg)
}

#' @noRd
apply_hudson <- function(nr) {
  bg <- brighten(nr, .5) |>
    contrast(-.1) |>
    saturate(.1)
  fg <- fill_with(premul(166, 177, 255, 208), ncol(nr), nrow(nr))
  out <- blend_multiply(fg, bg)
  reset_alpha(out)
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
      fill_with(premul(56, 44, 52, 255), ncol(nr), nrow(nr))
    )
  fg <- fill_with(premul(183, 125, 33, 255), ncol(nr), nrow(nr))
  blend_overlay(fg, bg)
}

#' @noRd
apply_lark <- function(nr) {
  bg <- contrast(nr, -.1) |>
    blend_colordodge(
      fill_with(premul(34, 37, 63, 255), ncol(nr), nrow(nr))
    )
  fg <- fill_with(premul(242, 242, 242, 204), ncol(nr), nrow(nr))
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
  fg <- fill_with(premul(255, 200, 200, 153), ncol(nr), nrow(nr))
  blend_overlay(fg, bg)
}

#' @noRd
apply_moon <- function(nr) {
  bg <- contrast(nr, .1) |>
    brighten(.1) |>
    blend_softlight(
      fill_with(premul(160, 160, 160, 255), ncol(nr), nrow(nr)),
      dst = _
    )
  fg <- fill_with(premul(56, 56, 56, 255), ncol(nr), nrow(nr))
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
      fill_with(premul(247, 176, 153, 243), ncol(nr), nrow(nr)),
      dst = _
    )
  fg <- fill_with(premul(0, 70, 150, 230), ncol(nr), nrow(nr))
  blend_lighten(fg, bg)
}

#' @noRd
apply_reyes <- function(nr) {
  bg <- sepia(nr, .22) |>
    brighten(.1) |>
    contrast(-.15) |>
    saturate(-.25)
  fg <- fill_with(premul(239, 205, 173, 10), ncol(nr), nrow(nr))
  blend_over(fg, bg)
}

#' @noRd
apply_rise <- function(nr) {
  bg <- brighten(nr, .05) |>
    sepia(.05) |>
    contrast(-.1) |>
    saturate(-.1)
  fg <- fill_with(premul(236, 205, 169, 240), ncol(nr), nrow(nr))
  bg <- blend_multiply(fg, bg)
  fg <- fill_with(premul(232, 197, 152, 10), ncol(nr), nrow(nr))
  fg <- blend_overlay(fg, bg)
  blend_over(fg, nr)
}

#' @noRd
apply_slumber <- function(nr) {
  bg <- saturate(nr, -.34) |>
    brighten(-.05)
  fg <- fill_with(premul(69, 41, 12, 102), ncol(nr), nrow(nr))
  bg <- blend_lighten(fg, bg)
  fg <- fill_with(premul(125, 105, 24, 128), ncol(nr), nrow(nr))
  blend_softlight(fg, bg)
}

#' @noRd
apply_stinson <- function(nr) {
  bg <- contrast(nr, -.25) |>
    saturate(-.15) |>
    brighten(.15)
  fg <- fill_with(premul(240, 149, 128, 51), ncol(nr), nrow(nr))
  blend_softlight(fg, bg)
}

#' @noRd
apply_toaster <- function(nr) {
  bg <- contrast(nr, .2) |>
    brighten(-.1)
  fg <- fill_with(premul(128, 78, 15, 140), ncol(nr), nrow(nr))
  blend_screen(fg, bg)
}

#' @noRd
apply_valencia <- function(nr) {
  bg <- contrast(nr, .08) |>
    brighten(.08) |>
    sepia(.08)
  fg <- fill_with(premul(58, 3, 57, 128), ncol(nr), nrow(nr))
  blend_exclusion(fg, bg)
}

#' @noRd
apply_walden <- function(nr) {
  bg <- brighten(nr, .1) |>
    hue_rotate(-.1745329) |> # -10 deg
    saturate(.6) |>
    sepia(.05)
  fg <- fill_with(premul(0, 88, 244, 77), ncol(nr), nrow(nr))
  blend_screen(fg, bg)
}
