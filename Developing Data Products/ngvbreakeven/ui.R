library(shiny)
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Natural Gas Vehicle (NGV) Invesment Breakeven Calculator"),
  sidebarLayout(
    # sidebar panel with input sliders
    sidebarPanel(
      tags$h4("CNG Vehicle Assumption"),
      
      sliderInput("vehprice", 
                  label="Vehicle Price ($)", 
                  min = 100000,  max = 200000, value = 185000),
      br(),
      sliderInput("annmileage", 
                  label="Annual Mileage (mi)", 
                  min = 5000,  max = 250000,  value = 150000),
      br(),
      sliderInput("dieselmpg", 
                  label="Fuel Economy (Diesel MPG)", 
                  min = 5.0,  max = 10.0,  value = 7.5, round = FALSE, step = 0.25),
      br(),
      sliderInput("cngmpg", 
                  label="Fuel Economy (CNG Miles/DGE)", 
                  min = 5.0,  max = 10.0,  value = 5.5, round = FALSE, step = 0.25),
      tags$h4("CNG Pricing Assumption"),
      numericInput("cngtrans", 
                   label = "Pipeline/Gas Acq/Marketer Services ($/GGE)", 
                   value = 0.20),
      numericInput("cngelectric", 
                   label = "Electric COmpression Costs ($/GGE)", 
                   value = 0.10),
      numericInput("cngmaintenance", 
                   label = "Maintenance Costs ($/GGE)", 
                   value = 0.40),
      numericInput("cngamort", 
                   label = "Capital Amortization (filling station) ($/GGE)", 
                   value = 0.35)
    ),
    mainPanel(
      tabsetPanel(type = "tabs", 
                  tabPanel("Results", plotOutput("fuelprcPlot"),br(),plotOutput("breakevenPlot")), 
                  tabPanel('Data Table', dataTableOutput('datatable')),
                  tabPanel("User Manual", includeHTML("usermanual.html"))               
      )
    )
  )
)
)