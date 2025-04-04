skip_on_cran()
skip_on_ci()

png <- readBin(
  system.file("images/sample-361x241.png", package = "aznyan"),
  what = "raw",
  n = file.info(system.file("images/sample-361x241.png", package = "aznyan"))$size
)

test_that("diffusion works", {
  vdiffr::expect_doppelganger(
    "diffusion",
    diffusion_filter(png, factor = 5) |>
      as_recordedplot()
  )
})
