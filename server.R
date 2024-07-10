###########################################################################
# Project           : SampleSize2Binomials
# Program name      : server.R
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
#   - I declare that this program may contain or contain confidential
#     information and that it cannot be shared as it.
#
###########################################################################

shinyServer(function(session, input, output) {
  
  ####################
  ### Miscelaneous ###
  ####################
  
  # initialize helpfiles
  # uses 'helpfiles' directory by default
  observe_helpers(withMathJax = TRUE, 
                  help_dir = "functions")
  
  # initialize then start the guides
  observeEvent(input$cicerone1, {
    guide1$init()$start()
  })
  
  observeEvent(input$cicerone2, {
    guide2$init()$start()
  })
  
  observeEvent(input$cicerone3, {
    guide3$init()$start()
  })
  
  # traceability: Show R session info and loaded packages in tab System info 
  output$system <- renderPrint({
    sessionInfo()
  })
  
  ################
  ### Analysis ###
  ################
  
  # translate user inputs into distributional parameters
  alpha1 <- reactive({unname(beta.Solver(input$theta1_mode, input$ESS1)[1])})
  beta1 <- reactive({unname(beta.Solver(input$theta1_mode, input$ESS1)[2])})
  alpha2 <- reactive({unname(beta.Solver(input$theta2_mode, input$ESS2)[1])})
  beta2 <- reactive({unname(beta.Solver(input$theta2_mode, input$ESS2)[2])})
  
  # Helper for graphic
  output$dynamicUI_plot <- renderUI({
    h5("Plot of prior Beta distributions  L") %>% 
      helper(size = "m",
             type = "inline",
             title = "Prior Beta distributions",
             content = withMathJax(
               paste0(
                 "These Beta distributions are the (informative) design priors that reflect our prior
                 knowledge and will enable us to reduce the trial’s sample size.",
                 " With this plot, the user can judge their appropriateness and revise them as necessary. "
               )
             ))
  })
  
  output$text_beta <- renderUI({
    withMathJax(p("The beta distributions for both treatments are: ",
           "$\\theta_1 \\sim$ Beta(",
           alpha1(), ",", beta1(), "): mean[95%CI] =",
           (alpha1() / (alpha1() + beta1())) %>% round(2),
           "[", qbeta(0.05/2, alpha1(), beta1()) %>% round(2), ";",
           qbeta(1-(0.05/2), alpha1(), beta1()) %>% round(2), "]",
           " and $\\theta_2 \\sim$ Beta(",
           alpha2(), ",", beta2(), "): mean[95%CI] =",
           (alpha2() / (alpha2() + beta2())) %>% round(2),
           "[", qbeta(0.05/2, alpha2(), beta2()) %>% round(2), ";",
           qbeta(1-(0.05/2), alpha2(), beta2()) %>% round(2), "]", "."))
  })
  
  
  output$pElicitedPriorDistribution <- renderPlotly({
      ggplotly(
      drawElicitedPriorDistribution(
        alpha1=alpha1(), 
        alpha2=alpha2(), 
        beta1=beta1(), 
        beta2=beta2()
      )
      )
  })
  
  isTheDrugEffective <- reactive({
    computeIsTheDrugEffective(
      alpha1=alpha1(), 
      alpha2=alpha2(), 
      beta1=beta1(), 
      beta2=beta2(),
      n1=input$n1, 
      n2=input$n2, 
      eta=input$eta, 
      threshold=input$threshold
      )
  })
  
  simulations <- eventReactive(input$runSimulations, {
  powerDraw(
    alpha1=alpha1(), 
    alpha2=alpha2(), 
    beta1=beta1(), 
    beta2=beta2(),
    n1=input$n1, 
    n2=input$n2, 
    eta=input$eta, 
    threshold=input$threshold,
    Nrep=input$Nrep
    )
  })
  
  ########################
  ### Generate outputs ###
  ########################
  
  output$simulations <- renderTable(simulations() %>%
                                      rename("Prior type"     = 1,
                                             "Type I error"   = 3))
  output$SSinfo      <- renderTable(
    data.frame("Information" = c("Elicited prior effective sample size",
                                 "Posterior effective sample size",
                                 "% of total information arising from the prior"),
               Value = c((input$ESS1 + input$ESS2) %>%
                           round(0) %>%
                           format(nsmall = 0),
                         (input$ESS1 + input$ESS2 + input$n1 + input$n2) %>%
                           round(0) %>%
                           format(nsmall = 0),
                         (100 * (input$ESS1 + input$ESS2) /
                           (input$ESS1 + input$ESS2 + input$n1 + input$n2)) %>%
                           round(0) %>%
                           format(nsmall = 0) %>%
                           paste0(., "%")
                           )
               ),
    colnames = FALSE
    ) 
  
  output$textsimtitle <- renderUI({
    if(simulations()[1,2] >= 0){
      em(h6("Conclusions based on the simulations  L")) %>%
        helper(type = "inline",
               title = "Definition of variables",
               content = c("<b>Power</b> is the probability the trial will successfully identify
                                a clinically significant difference when it exists.",
                           "<b>Type I error</b> is the trial's false positive rate, or the probability
                                the trial will mistakenly conclude a significant difference when it does not exist"),
               size = "l")
    }
  })
  
  output$textpower <- renderUI({
    if(simulations()[1,2] >= 0.8){
      p("Your current trial sample sizes are sufficient to deliver a traditional 
        power of 80%, the customary rate.")
    } else{
      p("Your current trial sample sizes are insufficient to deliver a traditional power
        of 80%, the customary rate. To address this, you may want to increase them, or lower
        the probability threshold that determines treatment significance.")
    }
  })
  
  output$texttype1 <- renderUI({
    if(simulations()[1,3] < 0.05){
      p("Your current trial sample sizes are sufficient to control the traditional Type I
        error rate at 5%, the customary value.")
    } else if(simulations()[1,3] > 0.2){
      p("The level of informative content in your prior is high enough that it has inflated 
        Type I error beyond 20%, a common upper bound for informative priors.  
        To address this, you may want to increase your sample sizes, raise the probability
        threshold that determines treatment significance, or lower your prior effective sample sizes.")
    } else {
      p("Your current trial sample sizes are insufficient to control the traditional Type I
        error rate at 5%, the customary value.  To address this, you may want to increase them,
        or raise the probability threshold that determines treatment significance.")
    }
    
  })

})