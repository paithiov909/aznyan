skip_on_cran()
skip_on_ci()

png <-
  fastpng::read_png(
    system.file("images/vespa.png", package = "aznyan"),
    type = "nativeraster",
    rgba = TRUE,
    flags = 1L
  )

test_that("fade works", {
  vdiffr::expect_doppelganger(
    "fade",
    fade_with(png, png, with = "saturation", range = c(.66, 1.0), invert = TRUE) |>
      set_matte("green") |>
      reset_alpha(1) |>
      as_recordedplot()
  )
})
