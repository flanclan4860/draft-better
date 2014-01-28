library(shiny)

# Define UI
shinyUI(pageWithSidebar(
  
  headerPanel('The Draft (v.2)'),
  sidebarPanel(
    selectInput('team',
                label='Team:',
                choices=teams),
    wellPanel(
      h4('Add Player'),
      uiOutput('undraftedPlayers'),
      actionButton(inputId='add', label='Add')
    )
  ),
  
  mainPanel(
    tabsetPanel(
      
      # rosters
      source('ui_rosters.R', local=TRUE)$value,
      
      tabPanel(
        'Players',
        tableOutput('players'))
    )
  )
))