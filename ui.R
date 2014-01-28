library(shiny)

load('projections.RData')
players <- projections.df[order(projections.df$Player,
                                decreasing=FALSE),'Player']


# Define UI
shinyUI(pageWithSidebar(
  
  headerPanel('The Draft (v.2)'),
  
  sidebarPanel(
    
    selectInput('teamChosen',
                label='Team:',
                choices=teams),
    
    wellPanel(
      h4('Add Player'),
      selectInput('addPlayer',
                  label='Remaining players:',
                  choices=players,
                  selected=''),
      actionButton(inputId='add', label='Add')
    ),
    
    wellPanel(
      h4('Remove Player'),
      selectInput('removePlayer',
                  label='Drafted players:',
                  choices=c('none'),
                  selected=''),
      actionButton(inputId='remove', label='Remove')
    )
    
    
    
    
  ),
  
  mainPanel(
    tabsetPanel(
      
      # rosters
      source('ui_rosters.R', local=TRUE)$value,
      
      tabPanel(
        'Projected totals'
      )
    )
  )
  )
  
)