library(tidyverse)
library(stringr)
library(readr)

cdate <- as.Date("2021-01-01")
edate <- as.Date("2022-01-01")

df <- data.frame()

while (cdate < edate) {
  file <- paste("data/", cdate, ".csv", sep = "")
  if (file.exists(file)) {
    df_temp <- read.csv(file, encoding = "UTF-8")

    # Add date column
    df_temp$date <- cdate

    df <- rbind(df, df_temp)
  }

  cdate <- cdate + 1
}

write_excel_csv(df, "data/data.csv")
