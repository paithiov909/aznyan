test_that("read and write doesn't change data", {
  test_cube_file <- write_cube(test_lut_dat, title = "test data")
  expect_equal(
    read_cube(test_cube_file, verbose = FALSE),
    test_lut_dat
  )

  test_smcube_file <-
    write_smcube(
      test_lut_dat,
      tempfile(fileext = ".smcube"),
      title = "test data"
    )
  expect_equal(
    read_cube(test_smcube_file, verbose = FALSE),
    test_lut_dat
  )
})
