library(openssl)
library(tidyverse)

mypath <- "data"

hashes <-
    tibble(filepath = str_c(mypath, "/",
        list.files(path = mypath,
            recursive = TRUE)
      )) %>%
    mutate(filename = str_match(filepath, "(.+\\/)*(.+)")[,3],
           Connection = map(filepath, file),
           SHA256 = map(Connection, function(x) {
                                        sha256(x) %>% str_c(collapse = '')
                                        }) %>% as.character
           ) %>%
    select(filepath,
           filename,
           SHA256)

hashes %>%
    write_csv("hashes.csv")
