#################################################################################################################################################
#
# 002: Principal Components Analysis of baseline Metabolites
# author: Ariel Chernofsky
# date created: October 20, 2021
# input data: data/metabs.rds
#
#################################################################################################################################################


# load libraries ----------------------------------------------------------

library(tidyverse)
library(kernlab)
library(elasticnet)


# read in data ------------------------------------------------------------

metabs <- readRDS("data/metabs.rds")

X <- as.matrix(metabs)

# Principal Compenents Analysis -------------------------------------------

pca <- prcomp(metabs[, -1])

pve <- pca$sdev^2 / sum(pca$sdev^2)

kernpca <- kpca(metabs[, -1])
plot(rotated(kernpca))
summary(kernpca)
rotated(kernpca)
kernpca@eig



# sparse pca --------------------------------------------------------------

spca <- spca(X, K = 6, para = rep(0, 6), type = "predictor", sparse = "penalty")
