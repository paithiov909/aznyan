skip_on_cran()
skip_on_ci()

png <-
  fastpng::read_png(
    system.file("images/sample-361x241.png", package = "aznyan"),
    type = "nativeraster",
    rgba = TRUE,
    flags = 1L
  )

test_that("other filters work", {
  vdiffr::expect_doppelganger(
    "mean-shift",
    mean_shift(png) |>
      as_recordedplot()
  )
  vdiffr::expect_doppelganger(
    "preserve-edge",
    preserve_edge(png) |>
      as_recordedplot()
  )
})
