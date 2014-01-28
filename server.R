library(shiny)

# Load the projection data.
load('projections.RData')

shinyServer(function(input, output) {
  
  # Reactive expression to trigger changes when a player is drafted
  draftPlayer <- reactive({
    if (input$add == 0) {
      return()
    }
    projections.df[projections.df$Player == isolate(input$draftPlayer),
                   8] <- input$team
    save(projections.df, file='projections.RData')
  })
  
  # Render table of all players
  output$players <- renderTable({
    draftPlayer()
    projections.df
  })
  
  # Render roster of current chosen team
  # TODO: fix this so it isn't team specific
  output$team1 <- renderTable({
    draftPlayer()
    subset(projections.df, fantasyTeam == 'Team 1')
  })
  
  output$undraftedPlayers <- renderUI({
    draftPlayer()
    
    # Update
    undrafted <- sort(subset(projections.df, is.na(fantasyTeam))[,1])
    selectInput('draftPlayer',
                label='Undrafted players',
                choices=undrafted)
  })
  
})