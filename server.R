library(shiny)

# Globally define reactive data.
vars <- reactiveValues()

# Load the projection data.
vars$projections.df <- readRDS('projections.rds')

shinyServer(function(input, output) {
  
  # Reactive expression to trigger changes when a player is drafted
  draftPlayer <- reactive({
    if (input$add == 0) {
      return()
    }

    vars$projections.df[vars$projections.df$Player == 
                  isolate(input$draftPlayer), 8] <- isolate(input$team)
    saveRDS(vars$projections.df,file='projections.rds')
  })
  
  # Render table of all players
  output$players <- renderTable({
    draftPlayer()
    vars$projections.df
  })
  
  # Render roster of current chosen team
  output$team <- renderTable({
    draftPlayer()
    subset(vars$projections.df, fantasyTeam == input$team)
  })
  
  output$undraftedPlayers <- renderUI({
    draftPlayer()
    
    # Update
    undrafted <- sort(subset(vars$projections.df, is.na(fantasyTeam))[,1])
    selectInput('draftPlayer',
                label='Undrafted players',
                choices=undrafted)
  })
  
})