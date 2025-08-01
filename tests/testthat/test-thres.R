skip_on_cran()
skip_on_ci()

png <-
  fastpng::read_png(
    system.file("images/painting.png", package = "aznyan"),
    type = "nativeraster",
    rgba = TRUE,
    flags = 1L
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
