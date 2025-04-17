skip_on_cran()
skip_on_ci()

png <- readBin(
  system.file("images/sample-361x241.png", package = "aznyan"),
  what = "raw",
  n = file.info(system.file("images/sample-361x241.png", package = "aznyan"))$size
)

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
