require(shiny)

# Define UI for miles per gallon application
shinyUI(pageWithSidebar(

  # Application title
  headerPanel("Senegal Open Data visualizer"),
  ## h5("Open data hackathon Senegal made by Ahmadou DICKO"),

  # Sidebar with controls to select the variable to plot against mpg
                                        # and to specify whether outliers should be included
  sidebarPanel(
    selectInput("indicators", "Choisit un indicateur:",
                choices = c("Population Rurale", "Accès à l'eau", "PIB", "Education et genre")),
    numericInput("debut", "data de départ", 1960),
    numericInput("fin", "date de fin", 2012),
    numericInput("nobs", "Nombre d'observation", 11),
    helpText(HTML("<br></br>Code source sur <a href = \"https://github.com/dickoa\">Github</a>"))
  ),

  # Show the caption and plot of the requested variable against mpg
  mainPanel(
    tabsetPanel(
    tabPanel("Graphique", plotOutput("graph")),
    tabPanel("Données", tableOutput("view"))
    )
  )
))


