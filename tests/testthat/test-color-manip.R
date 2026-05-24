skip_on_cran()
skip_on_ci()

png <- read_still(system.file("images/painting.png", package = "aznyan"))

test_that("apply_lut1d works", {
  ret <- apply_lut1d(png, matrix(runif(256 * 3, 0, 255), ncol = 3))
  expect_s3_class(ret, "nativeRaster")
})

test_that("apply_lut3d works", {
  cubefile <- write_cubelut(
    test_cubelut,
    filename = tempfile(fileext = ".cube")
  )
  vdiffr::expect_doppelganger(
    "apply_lut3d",
    apply_lut3d(png, cubefile) |>
      as_recordedplot()
  )
})

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
