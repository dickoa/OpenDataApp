require(shiny)

### Define UI for my applications
shinyUI(pageWithSidebar(

  # Application title
  headerPanel("Senegal Open Data visualizer"),
  ## h5("Open data hackathon Senegal made by Ahmadou DICKO"),

### using Side bar
  sidebarPanel(
    selectInput("indicators", "Choisit un indicateur:",
                choices = c("Population Rurale", "Accès à l'eau", "PIB", "Education et genre")),
    numericInput("debut", "date de départ", 1960),
    numericInput("fin", "date de fin", 2012),
    numericInput("nobs", "Nombre d'observation", 11),
    helpText(HTML("<br></br>Code source sur <a href = \"https://github.com/dickoa/OpenDataApp\">Github</a>"))
  ),


  mainPanel(
    tabsetPanel(
    tabPanel("Graphique", plotOutput("graph")),
    tabPanel("Données", tableOutput("view"))
    )
  )
))


