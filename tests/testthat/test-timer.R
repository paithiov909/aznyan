test_that("timer works", {
  res <-
    NULL %timer% {
      1:3
    }
  expect_equal(res, 1:3)

  res <-
    (1:3) |>
    rlang::as_function(
      ~ NULL %timer% {
        . * 3
      }
    )()
  expect_equal(res, c(3, 6, 9))
})

test_that("timer warns when lhs fails to evaluate", {
  expect_warning(
    stop("oops") %timer% NULL
  )
})
