#################################################################################################################################################
#
# 002: read in data
# author: Ariel Chernofsky
# date created: December 30, 2021
# input data: data/project3.rds
#
#################################################################################################################################################


# load libraries ----------------------------------------------------------

library(tidyverse)
library(haven)
library(gtsummary)
library(xtable)
library(kableExtra)


# read in data ------------------------------------------------------------

p3 <- read_rds("data/project3.rds")


# table 1 -----------------------------------------------------------------

tab1 <- p3 %>%
  select(met_guide, age3, female, bmi, sbp,
         dm, smstat3, htn, cvd, 
         hrs_day3, season3, peak_vo2_rel_ex) %>%
  mutate(smstat3 = factor(smstat3, 
                          labels = c("never", "former", "current")),
         season3 = factor(season3,
                          labels = c("Sep - Dec", "Jan - Mar", 
                                     "Apr - May", "Jun - Aug"))) %>%
  tbl_summary(by = met_guide,
              statistic = list(all_continuous() ~ "{mean} ({sd})"),
              digits = all_continuous() ~ 2,
              label = list(age3 ~ "age",
                           smstat3 ~ "smoking status",
                           dm ~ "diabetes mellitus",
                           hrs_day3 ~ "wear time (hrs/day)",
                           season3 ~ "season actical was worn",
                           cvd ~ "CVD",
                           htn ~ "hypertension",
                           sbp ~ "Systolic blood pressure",
                           peak_vo2_rel_ex ~ "Peak VO$_2$")) %>%
  modify_header(all_stat_cols() ~ "**{level}**<br>N =  {n} ({style_percent(p)}%)") %>%
  add_overall() %>%
  modify_spanning_header(all_stat_cols() ~ "**Met PA guidelines**") %>%
  as_tibble() 

print(xtable(tab1), include.rownames = F)
