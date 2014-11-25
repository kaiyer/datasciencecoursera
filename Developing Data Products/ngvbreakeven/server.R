library(shiny)
source("eia_data.r")
# Define server logic required to summarize and view the selected
# dataset
shinyServer(function(input, output) {
  
  # Return the breakeven mpg
  datasetInput <- reactive({
    # compute the cng price in $/DGE
    GGEperMMBTU <- 7.74
    GGEperDGE <- 1.136
    
    df <- eiadata()
    ngprice <- df[df$variable=="ngprice",]
    cngdge <- (ngprice$value/GGEperMMBTU + input$cngtrans + input$cngelectric + input$cngmaintenance + input$cngamort) * GGEperDGE
    cngdge.df <- data.frame(caldate=ngprice$caldate, variable="cngprice", value=cngdge)  
    dflist <- list(df,cngdge.df)
    fuelprc.df <- rbind.fill(dflist)
    fuelprc.df
  })
  
  data1 = reactive({
    fuelprc.df<- datasetInput()
    prcdiesel <- fuelprc.df[fuelprc.df$variable=="dieselprice",]$value
    prccng <- fuelprc.df[fuelprc.df$variable=="cngprice",]$value
    dieselgal <- input$annmileage/input$dieselmpg
    cnggal <- input$annmileage/input$cngmpg
    dieselcost <- prcdiesel * dieselgal
    cngcost <- prccng * cnggal
    annsavings <- dieselcost  - cngcost
    breakeven <-  rep(input$vehprice, length(prcdiesel)) %/% annsavings
    
    breakeven.df <- data.frame(caldate=fuelprc.df[fuelprc.df$variable=="dieselprice",]$caldate, variable=rep("breakeven", length(prcdiesel)), value=breakeven)
    dflist <- list(fuelprc.df, breakeven.df)
    final.df <- rbind.fill(dflist)
    final.df
  })
  
  # Generate a plot of the fuel price
  output$fuelprcPlot <- renderPlot({
    fuelprc.df<- datasetInput()
    ggplot(fuelprc.df, aes(caldate, value)) + ggtitle("Fuel Price Graph") +
      geom_line(aes(color=variable)) + xlab("Date") + ylab("$/(MMBTU,Gal,DGE)") +
      coord_cartesian(ylim=c(0, 14)) + scale_y_continuous(breaks=seq(0, 14, 0.5)) 
  })
  output$breakevenPlot <- renderPlot({
    fuelprc.df<- datasetInput()
    prcdiesel <- fuelprc.df[fuelprc.df$variable=="dieselprice",]$value
    prccng <- fuelprc.df[fuelprc.df$variable=="cngprice",]$value
    dieselgal <- input$annmileage/input$dieselmpg
    cnggal <- input$annmileage/input$cngmpg
    dieselcost <- prcdiesel * dieselgal
    cngcost <- prccng * cnggal
    annsavings <- dieselcost  - cngcost
    breakeven <-  rep(input$vehprice, length(prcdiesel)) %/% annsavings
    
    breakeven.df <- data.frame(caldate=fuelprc.df[fuelprc.df$variable=="dieselprice",]$caldate, variable=rep("breakeven", length(prcdiesel)), value=breakeven)
    ggplot(breakeven.df, aes(caldate, value)) + ggtitle("Investment Breakeven Graph") +
      geom_line(aes(color=variable)) + xlab("Date") + ylab("Years") +
      coord_cartesian(ylim=c(-15, 15)) + scale_y_continuous(breaks=seq(-15, 15, 1)) 
  })
  
  output$datatable <-renderDataTable(function(){
    if(!is.null(data1())){
      d<-data1()
      print(d)
    }
  }, options = list(pageLength = 10)) 
  
})