# aznyan

<!-- badges: start -->
<!-- badges: end -->

## Installation

```r
remotes::install_github("paithiov909/aznyan")
```

## Usage

```r
library(aznyan)

csv_file <-
  aznyan::get_lyrics_list("23729") |> 
  aznyan::get_lyrics("23729.csv")
  
tbl <-
  readr::read_csv(csv_file, col_names = F, col_types = "cccc___cDn") |> 
  dplyr::rename(
    title = X1,
    artist = X2,
    lyricist = X3,
    composer = X4,
    text = X8,
    released = X9,
    page_view = X10
  )
```

## License

MIT license.
