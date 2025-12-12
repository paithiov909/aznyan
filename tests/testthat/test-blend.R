skip_on_cran()
skip_on_ci()

vespa <- fastpng::read_png(
  system.file("images/vespa.png", package = "aznyan"),
  type = "nativeraster",
  rgba = TRUE
)
city <- fastpng::read_png(
  system.file("images/city.png", package = "aznyan"),
  type = "nativeraster",
  rgba = TRUE
)
street <- fastpng::read_png(
  system.file("images/street.png", package = "aznyan"),
  type = "nativeraster",
  rgba = TRUE
)

test_that("blend modes look good", {
  ## Darker
  vdiffr::expect_doppelganger(
    "darken",
    blend_darken(vespa, city) |>
      as_recordedplot()
  )
  vdiffr::expect_doppelganger(
    "multiply",
    blend_multiply(vespa, city) |>
      as_recordedplot()
  )
  vdiffr::expect_doppelganger(
    "colorburn",
    blend_colorburn(vespa, city) |>
      as_recordedplot()
  )
  ## Brighter
  vdiffr::expect_doppelganger(
    "lighten",
    blend_lighten(vespa, street) |>
      as_recordedplot()
  )
  vdiffr::expect_doppelganger(
    "screen",
    blend_screen(vespa, street) |>
      as_recordedplot()
  )
  vdiffr::expect_doppelganger(
    "add",
    blend_add(vespa, street) |>
      as_recordedplot()
  )
  vdiffr::expect_doppelganger(
    "colordodge",
    blend_colordodge(vespa, street) |>
      as_recordedplot()
  )
  ## Contrast
  vdiffr::expect_doppelganger(
    "hardlight",
    blend_hardlight(street, city) |>
      as_recordedplot()
  )
  vdiffr::expect_doppelganger(
    "softlight",
    blend_softlight(street, city) |>
      as_recordedplot()
  )
  vdiffr::expect_doppelganger(
    "overlay",
    blend_overlay(street, city) |>
      as_recordedplot()
  )
  vdiffr::expect_doppelganger(
    "hardmix",
    blend_hardmix(street, city) |>
      as_recordedplot()
  )
  vdiffr::expect_doppelganger(
    "linearlight",
    blend_linearlight(street, city) |>
      as_recordedplot()
  )
  vdiffr::expect_doppelganger(
    "vividlight",
    blend_vividlight(street, city) |>
      as_recordedplot()
  )
  vdiffr::expect_doppelganger(
    "pinlight",
    blend_pinlight(street, city) |>
      as_recordedplot()
  )
  vdiffr::expect_doppelganger(
    "average",
    blend_average(street, city) |>
      as_recordedplot()
  )
  ## Inversion
  vdiffr::expect_doppelganger(
    "exclusion",
    blend_exclusion(street, city) |>
      as_recordedplot()
  )
  vdiffr::expect_doppelganger(
    "difference",
    blend_difference(street, city) |>
      as_recordedplot()
  )
  ## Cancelation
  vdiffr::expect_doppelganger(
    "divide",
    blend_divide(street, city) |>
      as_recordedplot()
  )
  vdiffr::expect_doppelganger(
    "subtract",
    blend_subtract(street, city) |>
      as_recordedplot()
  )
  ## Component
  vdiffr::expect_doppelganger(
    "luminosity",
    blend_luminosity(street, city) |>
      as_recordedplot()
  )
  ## Component contrast
  vdiffr::expect_doppelganger(
    "ghosting",
    blend_ghosting(street, city) |>
      as_recordedplot()
  )
})
