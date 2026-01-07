skip_on_cran()
skip_on_ci()

png <- read_still(system.file("images/painting.png", package = "aznyan"))

test_that("morphology works", {
  vdiffr::expect_doppelganger(
    "morphology",
    morphology(png, ksize = 4, use_rgb = FALSE) |>
      as_recordedplot()
  )
  vdiffr::expect_doppelganger(
    "morphology_rgb",
    morphology(png, ksize = c(4, 4, 4), use_rgb = TRUE) |>
      as_recordedplot()
  )
})
