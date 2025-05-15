pkgload::load_all()

test_lut_dat <- read_cube("tools/lut/test.cube")

usethis::use_data(
  test_lut_dat,
  internal = TRUE,
  overwrite = TRUE
)
