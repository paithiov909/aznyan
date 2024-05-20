#' Scrape lyrics from list
#'
#' @param df A tibble that comes of \code{get_lyrics_list}.
#' @param file String; file name to append lyrircs.
#' @param links String; column name of lyrics links.
#' @returns `file` is returned invisibly.
#' @export
#' @examples
#' \dontrun{
#' csv_file <-
#'  aznyan::get_lyrics_list("23729") |>
#'  aznyan::get_lyrics("23729.csv")
#' tbl <-
#'  readr::read_csv(csv_file, col_names = F, col_types = "cccc___cDn") |>
#'  dplyr::rename(
#'    title = X1,
#'    artist = X2,
#'    lyricist = X3,
#'    composer = X4,
#'    text = X8,
#'    released = X9,
#'    page_view = X10
#'  )
#' }
get_lyrics <- function(df, file, links = "link") {
  base_url <- "https://www.uta-net.com"
  links <- dplyr::pull(df, {{ links }})

  url <- paste(base_url, links, sep = "/")

  session <- polite::bow(base_url, force = FALSE)
  purrr::iwalk(url, function(q, itr) {
    html <- session %>%
      polite::nod(q) %>%
      polite::scrape()
    lyric_body <- html %>%
      rvest::html_element("#kashi_area") %>%
      rvest::html_text2()
    info <- html %>%
      rvest::html_element(".song-infoboard") %>%
      rvest::html_element(".detail") %>%
      rvest::html_text() %>%
      stringr::str_split("\\n") %>%
      unlist() %>%
      purrr::pluck(4) %>%
      stringr::str_extract_all(pattern = "[\\d,/]+") %>%
      unlist()

    data.frame(
      df[itr, ],
      lyric = lyric_body,
      released = info[1],
      page_viewed = info[2]
    ) %>%
      dplyr::mutate(
        released = lubridate::as_date(.data$released),
        page_viewed = stringr::str_remove_all(.data$page_viewed, ",") %>%
          unlist() %>%
          as.numeric()
      ) %>%
      readr::write_csv(file, append = TRUE, progress = FALSE)
  })
  invisible(file)
}
