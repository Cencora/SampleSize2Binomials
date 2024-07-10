###########################################################################
# Project           : SampleSize2Binomials
# Program name      : global.R
# Developed in      : R version 4.1.0 
# Purpose           : Demo app for the website
# Inputs            : NA
# Outputs           : NA
# Revision History  :
#   Version   Date            Author               Revision
#   -------   ---------       ----------           -------------------------
#   1.0       01-Jul-2021     TDE                  Creation
#
# Declaration of Confidentiality (choose the applicable sentence):
#   - I, as an author, certify that this program is free from any client or 
#     client project information whatever the type of information and that 
#     this program can be used without risk of confidentiality issue.
#
###########################################################################

rm(list = ls())

# load useful packages
library(shiny)
library(bs4Dash)
library(shinyhelper)
library(dplyr)
library(ggplot2)
library(plotly)
library(cicerone)
library(fresh)

# source additional R files
source("functions/helperFunctions.R")
source("functions/guidedTour.R")

# to save the inputs
enableBookmarking(store = "url") 

# traceability
title <- "SampleSize2Binomials"
app_version <- "0.1"
last_update <- "August 2021" 

# theme
PLXtheme <- create_theme(
  bs4dash_sidebar_light(
    bg = "#FFF",
  ),
  bs4dash_layout(
    sidebar_width = "300px",
  ),
  bs4dash_status(
    primary = "#009aa8"
  ),
  bs4dash_color(
    gray_900 = "#233c4c"
  )
)
