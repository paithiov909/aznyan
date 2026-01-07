skip_on_cran()
skip_on_ci()

png <- read_still(system.file("images/painting.png", package = "aznyan"))

test_that("thresholding works", {
  vdiffr::expect_doppelganger(
    "thres",
    thres(png, 60) |>
      as_recordedplot()
  )
  vdiffr::expect_doppelganger(
    "adpthres",
    adpthres(png, bsize = 2) |>
      as_recordedplot()
  )
})
