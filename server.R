library(shiny)

load('projections.RData')

shinyServer(function(input, output) {
  
  
  # Listen for additions to teams
  observe({
    if (input$add < 1){
      return()
    }
    
    # The add button was clicked, so update the player's team and rosters
    isolate({
      projections.df[projections.df$Player == input$playerChosen, 
                     'fantasyTeam'] = input$teamChosen
      save(projections.df, file='projections.RData')
    })
  })
  
  output$team1 <- renderTable({
    subset(projections.df, fantasyTeam == 'Team 1')[,1:7]
  })
  
  output$team2 <- renderTable({
    subset(projections.df, fantasyTeam == 'Team 2')[,1:7]
  })
  
})