library(shiny)

# Globally define reactive data.
vars <- reactiveValues()
vars$projections.df <- readRDS('projections.rds')
vars$draft <- 1

# Load the draft settings
source('settings.R', local=TRUE)

shinyServer(function(input, output) {
  
  # Reactive expression to trigger changes when a player is drafted
  draftPlayer <- reactive({
    if (input$add == 0) {
      return()
    }
    
    isolate({
      # Save changes to data frame, save data frame to .rds file
      # I think there is a better way to do this...
      vars$projections.df[vars$projections.df$Player == 
                    input$draftPlayer, 9] <- input$team
      vars$projections.df[vars$projections.df$Player == 
                    input$draftPlayer, 8] <- vars$draft
      saveRDS(vars$projections.df,file='projections.rds')
      
      # Increment draft counter
      vars$draft <- vars$draft + 1
    })
  })
  
  # Render table of all players
  output$players <- renderTable({
    draftPlayer()
    vars$projections.df
  })
  
  # Render roster of current chosen team
  output$team <- renderDataTable({
    draftPlayer()
    subset(vars$projections.df, fantasyTeam == input$team)
  })
  
  # Render UI for the list of undrafted players
  output$undraftedPlayers <- renderUI({
    draftPlayer()
    
    # Update
    undrafted <- sort(subset(vars$projections.df, fantasyTeam == '')[,2])
    selectInput('draftPlayer',
                label='Undrafted players',
                choices=undrafted)
  })
  
})