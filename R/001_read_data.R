#################################################################################################################################################
#
# 001: read in data
# author: Ariel Chernofsky
# date created: October 20, 2021
# input data: data/project3_data.sas7bdat
#
#################################################################################################################################################


# load libraries ----------------------------------------------------------

library(tidyverse)
library(haven)


# read in data ------------------------------------------------------------

p3 <- read_sas("data/project3_data.sas7bdat") %>%
  rename_with(tolower) %>%
  mutate(across(starts_with("nbl_"), ~ifelse(.x == "", NA, as.numeric(.x))))

metabs <- p3 %>%
  select(idnum, starts_with("nbl_")) %>%
  filter(across(everything(), ~ !is.na(.x)))

p3_final <- p3 %>%
  dplyr::filter(!is.na(peak_vo2_rel_ex),
                !is.na(mv_day3),
                metab_base == 1,
                is.na(exclude1),
                is.na(exclude2),
                is.na(exclude3),
                is.na(exclude4),
                is.na(exclude5),
                is.na(exclude6)) %>%
  select(-starts_with("nch_"))


# output data -------------------------------------------------------------

saveRDS(p3_final, "data/project3.rds")
saveRDS(metabs, "data/metabs.rds")
