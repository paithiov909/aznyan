skip_on_cran()
skip_on_ci()

png <- read_still(system.file("images/painting.png", package = "aznyan"))

test_that("brigten works", {
  vdiffr::expect_doppelganger(
    "brighten",
    brighten(png, .5) |>
      as_recordedplot()
  )
})

test_that("contrast works", {
  vdiffr::expect_doppelganger(
    "contrast",
    contrast(png, .5) |>
      as_recordedplot()
  )
})

test_that("duotone works", {
  vdiffr::expect_doppelganger(
    "duotone",
    duotone(png) |>
      as_recordedplot()
  )
})

test_that("grayscale works", {
  vdiffr::expect_doppelganger(
    "grayscale",
    grayscale(png) |>
      as_recordedplot()
  )
})

test_that("hue_rotate works", {
  vdiffr::expect_doppelganger(
    "hue_rotate",
    hue_rotate(png, pi / 6) |>
      as_recordedplot()
  )
})

test_that("invert works", {
  vdiffr::expect_doppelganger(
    "invert",
    invert(png) |>
      as_recordedplot()
  )
})

test_that("linocut works", {
  vdiffr::expect_doppelganger(
    "linocut",
    linocut(png) |>
      as_recordedplot()
  )
})

test_that("posterize works", {
  vdiffr::expect_doppelganger(
    "posterize",
    posterize(png) |>
      as_recordedplot()
  )
})

test_that("saturate works", {
  vdiffr::expect_doppelganger(
    "saturate",
    saturate(png, -.5) |>
      as_recordedplot()
  )
})

test_that("sepia works", {
  vdiffr::expect_doppelganger(
    "sepia",
    sepia(png, .5) |>
      as_recordedplot()
  )
})

test_that("solarize works", {
  vdiffr::expect_doppelganger(
    "solarize",
    solarize(png) |>
      as_recordedplot()
  )
})
