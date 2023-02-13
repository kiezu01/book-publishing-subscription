library(rvest)
library(stringr)
library(tidyverse)

nodata <- "Không tìm thấy dữ liệu"

# NOTE: DATE 2021-11-12 CAN'T GET
cdate <- as.Date("2021-11-13")
edate <- as.Date("2022-01-01")

while (cdate < edate) {
  strDate <- format(cdate, format = "%d/%m/%Y")
  url <- paste("https://ppdvn.gov.vn/web/guest/ke-hoach-xuat-ban?query=&id_nxb=-1&bat_dau=", strDate, "&ket_thuc=", strDate, "&p=1", sep = "")

  # Get the HTML
  html <- read_html(url, encoding = "UTF-8")

  print(paste("Crawling date: ", strDate))
  print(paste("URL: ", url))
  if (html %>% html_element(xpath = '//*[@id="list_data_return"]/table/tbody/tr/td') %>% html_text() == nodata) {
    print("No data")
  } else {
    page <- 0
    nextpage <- "Trang sau"

    df <- data.frame()

    while (str_detect(nextpage, "Trang sau")) {
      page <- page + 1

      cat(paste("\rPage: ", page))
      if (page != 1) {
        url <- paste("https://ppdvn.gov.vn/web/guest/ke-hoach-xuat-ban?query=&id_nxb=-1&bat_dau=", strDate, "&ket_thuc=", strDate, "&p=", page, sep = "")
        html <- read_html(url, encoding = "UTF-8")
      }

      table <- html %>%
        html_element(xpath = '//*[@id="list_data_return"]/table') %>%
        html_table(fill = TRUE) %>%
        as.data.frame() %>%
        select(-1)

      df <- rbind(df, table)

      nextpage <- html %>%
        html_element(xpath = '//*[@id="portlet_tracuuxuatban_WAR_gopy6111"]/div/div/div/div[1]/div[2]/ul') %>%
        html_text()
    }
    cat("\n")

    df <- df %>%
      setNames(c("isbn", "name", "author", "translator", "quantity", "self", "partner", "verification")) %>%
      as.data.frame()

    write_excel_csv(df, paste("data/", cdate, ".csv", sep = ""))
  }

  cdate <- cdate + 1
}
