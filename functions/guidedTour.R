###########################################################################
# Project           : SampleSize2Binomials
# Program name      : guidedTour.R
# Developed in      : R version 4.1.0 
# Purpose           : Demo app for the website
# Inputs            : NA
# Outputs           : NA
# Revision History  :
#   Version   Date            Author               Revision
#   -------   ---------       ----------           -------------------------
#   1.0       14-Sep-2021     TDE                  Creation
#
# Declaration of Confidentiality (choose the applicable sentence):
#   - I, as an author, certify that this program is free from any client or 
#     client project information whatever the type of information and that 
#     this program can be used without risk of confidentiality issue.
#
###########################################################################

guide1 <- Cicerone$
  new()$ 
  step(
    el = "[data-value='priorElicitation']",
    title = "Set prior",
    description = "This is where you generate prior distributions that reflect your current knowledge.",
    is_id = FALSE
  )$
  step(
    el = "[data-value='design']",
    title = "Calculate Type I error and power",
    description = "This is where you specify the study&#39s characteristics and compute the power and Type I error.",
    is_id = FALSE
  )$
  step(
    el = "saveState",
    title = "Save state for later",
    description = "You can save the state of the application (the values you entered) any time by clicking on this button."
  )

guide2 <- Cicerone$
  new()$ 
  step(
    el = "col_theta1_mode",
    title = "Reference treatment",
    description = "Enter the complete response rate for the reference treatment."
  )$
  step(
    el = "col_ESS1",
    title = "Reference treatment",
    description = "Enter the prior effective sample size (hypothetical study participants) for the reference treatment."
  )$
  step(
    el = "col_theta2_mode",
    title = "Novel therapy",
    description = "Enter the complete response rate for the novel therapy."
  )$
  step(
    el = "col_ESS2",
    title = "Novel therapy",
    description = "Enter the prior effective sample size (hypothetical study participants) for the novel therapy."
  )$
  step(
    el = "pElicitedPriorDistribution",
    title = "Prior distribution",
    description = "These distributions are the design priors that reflect your prior knowledge."
  )

guide3 <- Cicerone$
  new()$ 
  step(
    el = "col_n1",
    title = "Reference treatment",
    description = "Enter the expected sample size for the reference treatment."
  )$
  step(
    el = "col_n2",
    title = "Novel therapy",
    description = "Enter the expected sample size for the novel therapy."
  )$
  step(
    el = "col_eta",
    title = "Expected clinical significant difference",
    description = "Enter the expected clinical significant difference between the reference treatment and the novel therapy."
  )$
  step(
    el = "col_threshold",
    title = "Posterior probability threshold",
    description = "Enter the threshold that the probability of success must exceed to conclude the superiority of the novel therapy."
  )$
  step(
    el = "runSimulations",
    title = "Simulate your clinical trial",
    description = "Click on this button to simulate your clinical trial and report the trial&#39s average Type I error rate and power."
  )