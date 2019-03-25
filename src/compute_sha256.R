library(openssl)
library(tidyverse)

mypath <- "data"

hashes <-
    tibble(File = str_c(mypath, "/",
        list.files(path = mypath,
            recursive = TRUE)
      )) %>%
    mutate(Connection = map(File, file),
           SHA256 = map(Connection, function(x) {
                                        sha256(x) %>% str_c(collapse = '')
                                        }) %>% as.character
           ) %>%
    select(File, SHA256)

hashes %>%
    write_csv("hashes.csv")
