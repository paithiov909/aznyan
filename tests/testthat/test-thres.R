skip_on_cran()
skip_on_ci()

png <- readBin(
  system.file("images/sample-361x241.png", package = "aznyan"),
  what = "raw",
  n = file.info(system.file("images/sample-361x241.png", package = "aznyan"))$size
)

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
