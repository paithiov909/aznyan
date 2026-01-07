skip_on_cran()
skip_on_ci()

png <- read_still(system.file("images/vespa.png", package = "aznyan"))

test_that("fade works", {
  vdiffr::expect_doppelganger(
    "fade",
    fade_with(png, png, with = "saturation", range = c(.66, 1.0), invert = TRUE) |>
      set_matte("green") |>
      reset_alpha(1) |>
      as_recordedplot()
  )
})
