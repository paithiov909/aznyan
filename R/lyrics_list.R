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
    rvest::html_element(".songlist-table-block") %>%
    rvest::html_element("tfoot") %>%
    rvest::html_text() %>%
    stringr::str_extract("([:number:]+)")

  purrr::map_dfr(seq.int(as.integer(page_list)), function(i) {
    html <- session %>%
      polite::nod(path = paste(url, "0", as.character(i), "", sep = "/")) %>%
      polite::scrape()
    tables <- html %>%
      rvest::html_elements(".songlist-table-block") %>%
      rvest::html_elements("table")
    df <- tables %>%
      rvest::html_table() %>%
      purrr::map_dfr(~ na.omit(.))
    titles <- html %>%
      rvest::html_elements(".songlist-table-block") %>%
      rvest::html_elements(".songlist-title") %>%
      rvest::html_text()
    links <- tables %>%
      rvest::html_elements(".sp-w-100") %>%
      rvest::html_elements("a") %>%
      rvest::html_attr("href") %>%
      purrr::discard(~ . %in% c("https://www.uta-net.com/ranking/total/"))
    df %>%
      dplyr::slice_head(n = nrow(df) - 1) %>%
      dplyr::rename(
        text_lab = "\u66f2\u540d",
        artist = "\u6b4c\u624b\u540d",
        lyricist = "\u4f5c\u8a5e\u8005\u540d",
        composer = "\u4f5c\u66f2\u8005\u540d",
        leading = "\u6b4c\u3044\u51fa\u3057"
      ) %>%
      dplyr::bind_cols(
        data.frame(title = titles, link = links, source_page = i)
      ) %>%
      dplyr::select(
        .data$title,
        .data$artist,
        .data$lyricist,
        .data$composer,
        .data$leading,
        .data$link,
        .data$source_page
      )
  })
}

#' Search lyrics list by keyword
#'
#' @param keyword String; search phrase.
#' @param sort String; one of "new", "popular", "title", or "artist".
#' @return tibble
#' @export
search_lyrics_list <- function(keyword,
                               sort = c("new", "popular", "title", "artist")) {
  base_url <- "https://www.uta-net.com"
  sort <- rlang::arg_match(sort, c("new", "popular", "title", "artist"))
  sort <- dplyr::case_when(
    sort == "new" ~ 6,
    sort == "popular" ~ 4,
    sort == "title" ~ 1,
    sort == "artist" ~ 7,
    TRUE ~ 1
  )

  url <- paste(base_url, "search", "", sep = "/")
  session <-
    polite::bow(base_url, force = FALSE) %>%
    polite::nod(url)

  html <- session %>%
    polite::scrape(query = list(
      Keyword = stringr::str_trim(keyword),
      Aselect = "2",
      Bselect = "3",
      sort = sort
    ))
  page_list <- html %>%
    rvest::html_element("#songlist-sort-paging") %>%
    rvest::html_text() %>%
    stringr::str_extract("([:number:]+)")

  purrr::map_dfr(seq.int(as.integer(page_list)), function(i) {
    html <- session %>%
      polite::scrape(query = list(
        Keyword = enc2utf8(keyword),
        Aselect = "2",
        Bselect = "3",
        sort = sort,
        pnum = i
      ))
    tables <- html %>%
      rvest::html_elements(".songlist-table-block") %>%
      rvest::html_elements("table")
    df <- tables %>%
      rvest::html_table() %>%
      purrr::map_dfr(~ na.omit(.))
    titles <- html %>%
      rvest::html_elements(".songlist-table-block") %>%
      rvest::html_elements(".songlist-title") %>%
      rvest::html_text()
    links <- tables %>%
      rvest::html_elements(".sp-w-100") %>%
      rvest::html_elements("a") %>%
      rvest::html_attr("href") %>%
      purrr::discard(~ . %in% c("https://www.uta-net.com/ranking/total/"))
    df %>%
      dplyr::slice_head(n = nrow(df) - 1) %>%
      dplyr::rename(
        text_lab = "\u66f2\u540d",
        artist = "\u6b4c\u624b\u540d",
        lyricist = "\u4f5c\u8a5e\u8005\u540d",
        composer = "\u4f5c\u66f2\u8005\u540d",
        leading = "\u6b4c\u3044\u51fa\u3057"
      ) %>%
      dplyr::bind_cols(
        data.frame(title = titles, link = links, source_page = i)
      ) %>%
      dplyr::select(
        .data$title,
        .data$artist,
        .data$lyricist,
        .data$composer,
        .data$leading,
        .data$link,
        .data$source_page
      )
  })
}
