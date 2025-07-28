skip_on_cran()
skip_on_ci()

png <-
  fastpng::read_png(
    system.file("images/sample-361x241.png", package = "aznyan"),
    type = "nativeraster",
    rgba = TRUE,
    flags = 1L
  )

test_that("morphology works", {
  vdiffr::expect_doppelganger(
    "morphology",
    morphology(png, ksize = 4, use_rgb = FALSE) |>
      as_recordedplot2()
  )
  vdiffr::expect_doppelganger(
    "morphology_rgb",
    morphology(png, ksize = c(4, 4, 4), use_rgb = TRUE) |>
      as_recordedplot2()
  )
})
