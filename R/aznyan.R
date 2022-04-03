#' aznyan: An 'Utanet' Scraper
#' @docType package
#' @name aznyan
#' @importFrom dplyr %>%
#' @keywords internal
"_PACKAGE"

#' Scrape table of lyrics list
#'
#' @param id String; substring xxx of 'https://www.uta-net.com/:type:/xxx/'.
#' @param type String; one of "artist", "lyricist", or "composer".
#' @return tibble.
#' @export
get_lyrics_list <- function(id,
                            type = c("artist", "lyricist", "composer")) {
  base_url <- "https://www.uta-net.com"
  type <- rlang::arg_match(type, c("artist", "lyricist", "composer"))

  url <- paste(base_url, type, id, "", sep = "/")
  session <-
    polite::bow(base_url, force = FALSE) %>%
    polite::nod(url)

  html <- session %>%
    polite::scrape()

  page_list <- html %>%
    rvest::html_element(".upper_page_list") %>%
    rvest::html_element("span.pa") %>%
    rvest::html_text() %>%
    stringr::str_extract("([:number:]+)")

  purrr::map_dfr(seq.int(as.integer(page_list)), function(i) {
    html <- session %>%
      polite::nod(path = paste(url, "0", as.character(i), "", sep = "/")) %>%
      polite::scrape()
    tables <- html %>%
      rvest::html_elements(".result_table") %>%
      rvest::html_elements("table")
    df <- tables %>%
      rvest::html_table() %>%
      purrr::map_dfr(~.)
    links <- tables %>%
      rvest::html_elements(".td1") %>%
      rvest::html_elements("a") %>%
      rvest::html_attr("href") %>%
      purrr::discard(~ . %in% c("https://www.uta-net.com/user/poplist.html"))
    df %>%
      dplyr::rename(
        title = "\u66f2\u540d",
        artist = "\u6b4c\u624b\u540d",
        lyricist = "\u4f5c\u8a5e\u8005\u540d",
        composer = "\u4f5c\u66f2\u8005\u540d",
        leading = "\u6b4c\u3044\u51fa\u3057"
      ) %>%
      dplyr::bind_cols(
        data.frame(link = links, source_page = i)
      )
  })
}

#' Scrape lyrics from list
#'
#' @param df A tibble that comes of \code{get_lyrics_list}.
#' @param links String; column name of lyrics links.
#' @return tibble.
#' @export
get_lyrics <- function(df, links = "link") {
  base_url <- "https://www.uta-net.com"
  links <- dplyr::pull(df, {{ links }})

  url <- paste(base_url, links, sep = "/")

  session <- polite::bow(base_url, force = FALSE)
  lyrics <-
    purrr::map_dfr(url, function(q) {
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
        lyric = lyric_body,
        released = info[1],
        page_viewed = info[2]
      )
    }) %>%
    dplyr::mutate(
      released = lubridate::as_date(.data$released),
      page_viewed = stringr::str_remove_all(.data$page_viewed, ",") %>%
        unlist() %>%
        as.numeric()
    )
  data.frame(df, lyrics)
}
