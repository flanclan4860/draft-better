# This file is intended only to be run when you need to update the projections.
# The data is scraped from FantasyPros and saved into projections.RData

library(XML)
library(reshape2)
library(stringr)
source('settings.R', local=TRUE)


load_data_fantasypros <- function() {
  # Load FantasyPro's hitting projections.
  # This function is not particularly efficient, but it works.
  
  # Load projections
  url <- 'http://www.fantasypros.com/mlb/projections/hitters.php?page=ALL'
  classes <- c('character', rep('numeric', 15))
  projections.df <- readHTMLTable(url, which=2, colClasses=classes)
  
  
  # Split the player column into useful pieces.
  
  # Rename first column
  colnames(projections.df)[1] <- 'Player'
  
  # TODO: strip white space
  
  # Split player column into name and team/pos
  projections.df <- with(projections.df,
                         cbind(colsplit(projections.df$Player,
                                        pattern='\\(',
                                        names=c('Player', 'Team.Pos')),
                               projections.df[,2:16]))
  
  # Remove )'s
  projections.df$Team.Pos <- str_replace_all(projections.df$Team.Pos, '\\)', '')
  
  # Split team/pos column into team and pos
  projections.df <- with(projections.df,
                         cbind(Player,
                               colsplit(projections.df$Team.Pos,
                                        pattern=',',
                                        names=c('Team', 'Pos')),
                               projections.df[,3:17]))
  
  # Take care of players that don't have a team
  to.fix <- projections.df$Pos == ''
  projections.df[to.fix, 3] <- projections.df[to.fix, 2]
  projections.df[to.fix, 2] <- ''
  
  # Split positions, delimited by either / or ,
  projections.df <- with(projections.df,
                         cbind(Player, Team,
                               colsplit(projections.df$Pos,
                                        pattern='*[/,]',
                                        names=c('Pos1', 'Pos2', 'Pos3', 'Pos4')),
                               projections.df[,4:18]))
  
  # Convert positions and teams to factors
  projections.df$Team <- as.factor(projections.df$Team)
  projections.df$Pos <- as.factor(projections.df$Pos1)
  projections.df$Pos2 <- as.factor(projections.df$Pos2)
  projections.df$Pos3 <- as.factor(projections.df$Pos3)
  projections.df$Pos4 <- as.factor(projections.df$Pos4)
  
  # Add columns for drafted and fantasyTeam
  n <- dim(projections.df)[1]
  projections.df <- cbind(projections.df,
                          drafted=rep(NA, n),
                          fantasyTeam=rep('', n))
  
  # Set fantasy teams as factors
  # NOT WORKING. I need to learn more about factors...
  # projections.df$fantasyTeam <- as.factor(projections.df$fantasyTeam,
  #                                        levels=teams)
  
  # Set draft pick as integer
  projections.df$drafted <- as.integer(projections.df$drafted)
  
  projections.df
}

# Load data
projections.df <- load_data_fantasypros()

# Save data frame to an .rds file
saveRDS(projections.df, file='projections.rds')
