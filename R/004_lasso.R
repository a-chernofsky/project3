#################################################################################################################################################
#
# 002: read in data
# author: Ariel Chernofsky
# date created: December 30, 2021
# input data: data/project3.rds
#
#################################################################################################################################################

set.seed(3521)

# load libraries ----------------------------------------------------------

library(tidyverse)
library(haven)
library(gtsummary)
library(xtable)
library(kableExtra)
library(glmnet)
library(tidymodels)


# read in data ------------------------------------------------------------

p3 <- read_rds("data/project3.rds") %>%
  mutate(smstat3 = factor(smstat3, 
                          labels = c("never", "former", "current")),
         season3 = factor(season3,
                          labels = c(1, 2, 3, 4)),
         log_peak_vo2_rel_ex = log(peak_vo2_rel_ex)) %>%
  select(log_peak_vo2_rel_ex, starts_with("nbl_"),
         met_guide, age3, female, bmi, sbp,
         dm, smstat3, htn, cvd, 
         hrs_day3, season3)


# split the data into train and valid -------------------------------------

p3_split <- initial_split(p3)

train <- training(p3_split)

tune_spec <- 
  linear_reg(penalty = tune(),
             mixture = tune()) %>%
  set_engine("glmnet")

grid <- grid_regular(penalty(),
                     mixture(),
                     levels = 5)

grid %>%
  count(mixture)

folds <- vfold_cv(train, v = 5)

wf <- workflow() %>%
  add_model(tune_spec) %>%
  add_formula(log_peak_vo2_rel_ex ~ .)

res <- wf %>%
  tune_grid(
    resamples = folds,
    grid = grid
  )

linreg_reg_fit <- linear_reg(penalty = 0.1,
                             mixture = 0) %>%
  set_engine("glmnet") %>% fit(log_peak_vo2_rel_ex ~ ., data = p3)
