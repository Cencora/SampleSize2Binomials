###########################################################################
# Project           : SampleSize2Binomials
# Program name      : ui.R
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



ui <- function(request) { 
  
  dashboardPage(### content ###
    title = "SampleSize2Binomials",
    
    header=dashboardHeader(
      title = dashboardBrand(
        title = title, 
        color = "primary",
        href = "https://www.pharmalex.com",
        image = "logoPharmalex3.png"
      ),
      bookmarkButton(label = "Save state",
                     id = "saveState")
    ),
    
    sidebar=dashboardSidebar(
      id = "tabs",
      skin = "light",
      sidebarMenu(
        menuItem("Introduction", tabName = "introduction", icon = icon("question")),
        menuItem("Prior elicitation", tabName = "priorElicitation", icon = icon("puzzle-piece")),
        menuItem("Design", tabName = "design", icon = icon("cubes")),
        menuItem("About", tabName = "about", icon = icon("th"))
      )
    ),
    
    body = dashboardBody(
      
      # Add latex formulas and custom CSS
      withMathJax(),
      tagList(
        tags$head(
          tags$link(rel = "stylesheet", type = "text/css", href = "style.css"),
          includeHTML(("www/google-analytics.html"))
        ),
        tags$div(HTML("<script type='text/x-mathjax-config' >
            MathJax.Hub.Config({
            tex2jax: {inlineMath: [[ '$','$' ]]}
            });
            </script >
            "))),
      
      use_cicerone(), # guided tour
      use_theme(PLXtheme),
      
      tabItems(
        
        # Analysis tab
        tabItem(
          tabName = "introduction",
          box(
            width = NULL,
            title = "Introduction",
            p("This app enables you to specify your prior feelings about the effectiveness of
                two competing treatments (standard and novel), and subsequently find the sample size
                you would need to test whether the two are significantly different."),
            p("First, click the “Prior elicitation tab” and select values that generate prior distributions that
              reflect your current knowledge (which may result from past data).  Once you are satisfied
              with these distributions, click the “Design” tab to specify the study’s characteristics, 
              which includes the sample size in each group, the minimum clinically significant difference
              between the two response rates you desire, and the probability threshold that defines
              treatment significance.  The app will then simulate clinical trials under these conditions,
              and report the trial’s average Type I error (false positive) rate and power (probability of
              success assuming the treatment benefit is clinically significant).  The app will also suggest
              changes you might make to your design in order to increase power or reduce type I error. 
              Click on the buttons \"start tour\" in each tab to be guided through the application."),
            actionButton(inputId = "cicerone1", label = "Start tour"),
            br(),
            br(),
            p("We offer the following flow chart of the basic approach, followed by the
              technical details underlying the app in the next box."
            ),
            fluidRow(column(12, align = "center", img(src = 'workflow.png', width='1000')))
          ),
          box(
            width = NULL,
            collapsed = TRUE,
            title = "Technical details",
            p("Suppose we let $\\theta_1$ be the complete response (CR) rate under a reference standard cancer treatment,
              while $\\theta_2$ is the CR rate under a novel therapy. We wish to design a Bayesian clinical trial 
              to test whether the response rate for the novel therapy is significantly better than that on
              the standard therapy. Define $\\delta$ to be the difference between the two rates, i.e.,
              $\\delta$ = $\\theta_2$ - $\\theta_1$."),
            p("The Bayesian paradigm allows us to do this using direct probability statements about whether
              or not the difference between the two rates, $\\delta$, exceeds some “clinically significant difference”,
              which we can denote by $\\eta$.  For instance, if we set $\\eta$=0.2, we’d be saying that 
              a clinician would not be impressed with the new treatment unless its CR rate was at least 20% higher than standard.
              This means we are indifferent between the use of the new and standard treatments if 
              $\\delta \\in (0,\\eta)$;
              this interval is sometimes called the indifference zone."),
            p("A Bayesian would operationalize the decision by computing the probability of success (PoS),",
              div("PoS= P($\\delta > \\eta/2 \\mid data$),", align = "center"),
              "which is the chance of a treatment difference greater than the midpoint of the indifference zone.
              If this PoS exceeds some threshold $\\gamma$ (say, 0.90 or 0.95), we conclude the novel treatment is effective.
              Note that we could use other cutpoints (say, $\\eta$, the upper bound of the indifference zone), but then
              we’d need to dramatically reduce the confidence threshold (say, to 0.50, since a posterior centered
              at $\\eta$ would by definition not have most of its mass above $\\eta$)."
            ),
            p(em("Data:"),
              "Suppose we randomize $n_1$ patients to standard therapy and $n_2$ patients to the novel therapy.
              Assuming no missing data for the moment, each patient then delivers a success-failure (0-1) outcome.
              Let $X_1$ and $X_2$ be the total number of CRs in the standard and novel treatment groups, respectively.
              Assuming the patients are independent, $X_1$ and $X_2$ are both distributed as binomial random variables,
              i.e., $X_1 \\sim Bin(n_1,\\theta_1)$ and $X_2 \\sim Bin(n_2,\\theta_1)$."),
            p(em("Priors:"),
              "It is likely that the user has some idea of what $\\theta_1$ should be, based on published data or
              perhaps their own past experience with the standard treatment.
              Reliable information about $\\theta_2$ is perhaps less likely to exist (since this treatment is novel),
              but the user may still be able to rule out certain values (e.g., they might be fairly certain that $\\theta_2$
              is not less than 0.10 nor bigger than 0.50).  A convenient functional form for representing prior opinions
              is the beta distribution, i.e., $\\theta_1 \\sim Beta(\\alpha_1,\\beta_1)$ 
              and $\\theta_2 \\sim Beta(\\alpha_2,\\beta_2)$.
              This distribution can be bell-shaped ($\\alpha$ and $\\beta$ > 1), one-tailed ($\\alpha$ or $\\beta$=1),
              or uniform ($\\alpha$=$\\beta$=1), the so-called “flat prior” often used when the user has absolutely 
              no prior knowledge about a treatment’s success rate.  The two parameters $\\alpha$ and $\\beta$ can be
              determined by asking the user to specify two quantities:  the most likely values for the two CR rates,
              $\\theta_1^*$ and $\\theta_2^*$, and the “the prior effective sample size” for these two CR rates,
              $\\theta_1^{ESS}$ and $\\theta_2^{ESS}$.  These ESS quantities capture the number of patients the prior is “worth”;
              if $\\theta_1^{ESS} = 20$ and we also expect to enroll $n_1=20$ standard treatment patients in the trial,
              we would be saying that our prior and the new data would contribute equally to our final answer.  
              A regulator might prefer that $\\theta_1^{ESS}$ be much less than $n_1$.
              The resulting beta distributions can then be plotted to the screen, and the user can then be asked
              to judge their appropriateness (say, in terms of relative location and overlap) 
              and perhaps revise them as necessary."),
            p(h5("References:"),
              "Berry, S.M., Carlin, B.P., Lee, J.J. and Muller, P., 2010. Bayesian adaptive methods for clinical trials. CRC press.", br(),
              "Carlin, B.P. and Louis, T.A., 2008. Bayesian methods for data analysis. CRC Press.", br(),
              "Chen, N., Carlin, B.P. and Hobbs, B.P., 2018. Web-based statistical tools for the analysis and design of clinical trials that incorporate historical controls. Computational Statistics & Data Analysis, 127, pp.50-68.", br(),
              "Fouarge, E., Monseur, A., Boulanger, B., Annoussamy, M., Seferian, A.M., De Lucia, S., Lilien, C., Thielemans, L., Paradis, K., Cowling, B.S. and Freitag, C., 2021. Hierarchical Bayesian modelling of disease progression to inform clinical trial design in centronuclear myopathy. Orphanet journal of rare diseases, 16(1), pp.1-11.", br(),
              "Lewis, C.J., Sarkar, S., Zhu, J. and Carlin, B.P., 2019. Borrowing from historical control data in cancer drug development: a cautionary tale and practical guidelines. Statistics in biopharmaceutical research, 11(1), pp.67-78.", br(),
              "Monseur, A., Carlin, B.P., Boulanger, B., Seferian, A., Servais, L., Freitag, C. and Thielemans, L., 2021. Leveraging Natural History Data in One-and Two-Arm Hierarchical Bayesian Studies of Rare Disease Progression. Statistics in Biosciences, pp.1-22.", br(),
              "Lesaffre, E., Baio, G. and Boulanger, B. eds., 2020. Bayesian Methods in Pharmaceutical Research. CRC Press.")
          )
        ),
        # prior elicitation tab
        tabItem(
          tabName = "priorElicitation",
          
          column(12,
                 box(
                   width = NULL,
                   title="Elicited prior distribution",
                   actionButton(inputId = "cicerone2", label = "Start tour"),
                   br(),
                   br(),
                   fluidRow("STEP 1: Most likely (mode) values for $\\; \\theta_1 \\;$ (reference treatment) and $\\; \\theta_2 \\;$ (novel therapy) best guesses, i.e. typical value"),
                   br(),
                   fluidRow(
                     column(6,
                            id = "col_theta1_mode",
                            sliderInput('theta1_mode', '$\\theta_1^*$ (reference)  L' %>% 
                                          helper(type = "inline",
                                                 title = "",
                                                 content = withMathJax("Most likely value for $\\theta_1$, the reference treatment. 
                                                    It is assumed to be the mode of the beta distribution."),
                                                 size = "m"), 0.1, min=0, max=1)),
                     column(6,
                            id = "col_theta2_mode",
                            sliderInput('theta2_mode', '$\\theta_2^*$ (novel therapy)  L' %>%
                                          helper(type = "inline",
                                                 title = "",
                                                 content = withMathJax("Most likely value for $\\theta_2$, the novel therapy. 
                                                    It is assumed to be the mode of the beta distribution."),
                                                 size = "m"), 0.4, min=0, max=1))),
                   
                   fluidRow("STEP 2: Prior effective sample size, i.e., the “worth” of your prior feelings
                              about the CR rate expressed as a number of hypothetical study participants in each group"),
                   br(),
                   fluidRow(
                     column(6,
                            id = "col_ESS1",
                            sliderInput('ESS1', '$\\theta_1^{ESS}$ (reference)  L' %>%
                                          helper(type = "inline",
                                                 title = "",
                                                 content = withMathJax("Effective sample size in the prior for $\\theta_1$, the reference treatment."),
                                                 size = "m"), 15, min=2, max=100)),
                     column(6,
                            id = "col_ESS2",
                            sliderInput('ESS2', '$\\theta_2^{ESS}$ (novel therapy)  L' %>%
                                          helper(type = "inline",
                                                 title = "",
                                                 content = withMathJax("Effective sample size in the prior for $\\theta_2$, the novel therapy."),
                                                 size = "m"), 15, min=2, max=100))),
                   fluidRow(uiOutput(outputId = "dynamicUI_plot")),
                   uiOutput(outputId = "text_beta"),
                   plotlyOutput('pElicitedPriorDistribution')
                   
                 ))), 
        
        # design tab
        tabItem(
          tabName = "design",
          column(12,
                 box(
                   width = NULL,
                   title="Sample sizes and other trial design parameters",
                   actionButton(inputId = "cicerone3", label = "Start tour"),
                   br(),
                   br(),
                   fluidRow("User input feasible sample size n1 and n2, clinical significant difference eta and user-defined threshold"),
                   fluidRow(
                     column(6,
                            id = "col_n1",
                            sliderInput('n1', 'sample size reference ($n_1$)  L' %>%
                                          helper(type = "inline",
                                                 title = "",
                                                 content = "Expected sample size for the reference treatment.",
                                                 size = "m"),
                                        45, min=3, max=200)),
                     column(6,
                            id = "col_eta",
                            sliderInput('eta', 'clinically significant difference  L'  %>%
                                          helper(type = "inline",
                                                 title = "",
                                                 content = "Expected clinical significant difference between
                              the reference treatment and the novel therapy.",
                                                 size = "m"), 0.2, min=0, max=1)
                     )),
                   fluidRow(
                     column(6,
                            id = "col_n2",
                            sliderInput('n2', 'sample size novel therapy ($n_2$)   L' %>%
                                          helper(type = "inline",
                                                 title = "",
                                                 content = "Expected sample size for the novel therapy.",
                                                 size = "m"), 
                                        45, min=3, max=200)
                     ),
                     column(6,
                            id = "col_threshold",
                            sliderInput('threshold', 'posterior probability threshold  L' %>%
                                          helper(type = "inline",
                                                 title = "",
                                                 content = "Threshold that the probability of success must exceed
                                        to conclude the superiority of the novel therapy. This is the level of 
                                        confidence the trial needs to conclude the existence of a clinically 
                                        significant difference between the treatment and control response probabilities.",
                                                 size = "m"), 0.6, min=0, max=1)))
                 ),
                 box(
                   width = NULL,
                   title="Simulations  z" %>% # trick to not have the ? on the end of simulations
                     helper(type = "markdown",
                            content = "Simulations",
                            size = "l"),
                   fluidRow(column(6,
                                   align = "center",
                                   h6(strong("Number of simulations")),
                                   br(),
                                   fluidRow(
                                     column(8,
                                            numericInput("Nrep", NULL, 100, min = 100),
                                            align = "center"),
                                     column(4,
                                            actionButton("runSimulations",
                                                         "Simulate"),
                                            align = "center")
                                   )),
                            column(6,
                                   align = "center",
                                   h6("Sample size summary") %>%
                                     helper(type = "markdown",
                                            title = "Formulas",
                                            content = "Sample Size",
                                            size = "l"),
                                   tableOutput('SSinfo'))),
                   br(), 
                   fluidRow(
                     column(12, align="center",
                            tableOutput('simulations')
                     )
                   ),
                   fluidRow(uiOutput("textsimtitle")), # Use fluidRow here to ensure ? is next to the title
                   uiOutput("textpower"),
                   uiOutput("texttype1")
                 ) 
          ) 
        ),
        
        # system info tab
        tabItem(
          tabName = "about",
          
          column(12,
                 box(
                   width = NULL,
                   title="About",
                   a(h6("Need more? pharmalex.com"), href="https://www.pharmalex.com", target="_blank"),
                   a(h6("Support"), href="mailto:stat-plxstat@pharmalex.com"),
                   h6(paste0("Release: ", app_version, " (", last_update, ")"))
                 ),
                 box(
                   width = NULL,
                   title = "System Information",
                   verbatimTextOutput("system")
                 )
                 
          )
        )
      )
    ),
    
    footer = dashboardFooter(
      left = a("pharmalex.com", href="https://www.pharmalex.com", target="_blank"),
      right = paste0("©", format(Sys.Date(), "%Y"), " PHARMALEX GMBH. ALL RIGHTS RESERVED.")
    )
    
  )
}
