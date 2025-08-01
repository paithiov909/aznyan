nr <- fastpng::read_png(
  system.file("images/vespa.png", package = "aznyan"),
  type = "nativeraster",
  rgba = TRUE
)
nr2 <- fastpng::read_png(
  system.file("images/street.png", package = "aznyan"),
  type = "nativeraster",
  rgba = TRUE
)

devtools::document()

grid::grid.newpage()
apply_nashville(nr2) |>
  # restore_transparency() |>
  grid::grid.raster(interpolate = FALSE)
