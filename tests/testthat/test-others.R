skip_on_cran()
skip_on_ci()

png <- read_still(system.file("images/painting.png", package = "aznyan"))

test_that("other filters work", {
  vdiffr::expect_doppelganger(
    "mean-shift",
    mean_shift(png) |>
      as_recordedplot()
  )
  vdiffr::expect_doppelganger(
    "preserve-edge",
    preserve_edge(png, 200, 1) |>
      as_recordedplot()
  )
  vdiffr::expect_doppelganger(
    "blurhash",
    blurhash(png, 1, 1) |>
      as_recordedplot()
  )
})
