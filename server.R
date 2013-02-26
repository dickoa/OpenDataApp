require(shiny)
require(sp)
require(rgdal)
require(XML)
require(RCurl)
require(RColorBrewer)
require(ggplot2)
require(WDI)

setwd("~/ShinyApps/OpenDataApp")

baseurl <- "http://www.pepam.gouv.sn/acces.php?rubr=serv&idreg=%s"
nregion <- 11
regionName <- c("Dakar", "Ziguinchor", "Diourbel", "Saint-Louis", "Tambacounda", "Kaolack", "Thiès", "Louga", "Fatick", "Kolda", "Matam")
urls <- sprintf(baseurl, formatC(seq_len(nregion), digits = 1, flag = "0"))

### example avec Dakar
webpage <- getURLContent(urls[1])
tables <- readHTMLTable(webpage)

### avec les autres voyons voir
webpages <- lapply(urls, getURLContent)
names(webpages) <- regionName
tables <- lapply(webpages, readHTMLTable)

data <- sapply(tables, function(x) cbind(as.numeric(gsub(" ", "",as.character(x[[1]]$V2[1]))),
                                         as.numeric(as.character(x[[2]]$V2[1])))
               )

data <- data.frame(t(data))
data$region <- regionName
names(data) <- c("PopRur", "AccesEau", "region")

#### download map just once
if( ! file.exists("SEN_adm1.shp") ) {
    mapurl <- "http://gadm.org/data/shp/SEN_adm.zip"
    download.file(mapurl, destfile = "SEN_adm")
    unzip("SEN_adm")
}

torem <- file.path(".", c(grep("[0|2|3]", list.files("."), value = TRUE)))
file.remove(torem)


senreg <- readOGR(dsn = ".", layer = "SEN_adm1", encoding = "latin1")

names(senreg@data)[5] <- "region"
datafin <- merge(senreg@data, data)
senreg@data <- datafin
col_eau <- brewer.pal(9,"Blues")
col_eau <- colorRampPalette(col_eau, space = "Lab")
col_pop <- brewer.pal(9, "YlOrRd")
col_pop <- colorRampPalette(col_pop, space = "Lab")



### Define server logic :
### plot various indicators from WB web site
shinyServer(function(input, output) {

    indicator <- reactive({
        switch(input$indicators,
               "Population Rurale" = "PopRur",
               "Accès à l'eau" = "AccesEau",
               "PIB" = "NY.GDP.MKTP.CD",
               "Education et genre" = "SE.ENR.PRSC.FM.ZS")

    })

    colchoice <- reactive({
         switch(input$indicators,
                "Population Rurale" = col_pop(50),
                "Accès à l'eau" = col_eau(50))
     })


      wbdata <- reactive({
      if (indicator() %in% c("NY.GDP.MKTP.CD", "SE.ENR.PRSC.FM.ZS")) {
      dat1 <- WDI(country = "SN", indicator = "NY.GDP.MKTP.CD", start = input$debut, end = input$fin)[,2:4]
names(dat1)[c(1, 3)] <- c("Pays", "Année")

     dat2 <- WDI(country = "SN", indicator = "SE.ENR.PRSC.FM.ZS", start = input$debut, end = input$fin)[,2:4]
     names(dat2)[c(1, 3)] <- c("Pays", "Année")
      dat <- merge(dat1, dat2)
      dat
      } else {
       senreg
      }
        })

   output$graph <- renderPlot({
       if (indicator() %in% c("PopRur", "AccesEau")) {
       print(spplot(wbdata(), indicator(), col.regions = colchoice()))
       } else {
          p <- ggplot(wbdata(), aes_string(x = "Année", y = indicator())) +
          geom_line() +
          theme_bw()
     print(p)
      }
   })


  output$view <- renderTable({
        if (indicator() %in% c("PopRur", "AccesEau")) {
        head(senreg@data[,c("region", indicator())], n = input$nobs)
    } else {
        head(wbdata(), n = input$nobs)
    }
  })

})

