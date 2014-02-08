# This file is intended only to be run when you need to update the projections.
# The data is scraped from ESPN and saved into projections.RData

library(XML)
library(reshape2)
library(stringr)
source('settings.R', local=TRUE)

# Function to load ESPN's projected statistics
load_data_ESPN <- function() {
  # Load ESPN's hitting projections.
  # This function is not particularly efficient, but it works.
  
  # Load first page (ranked 1-40) to setup  data frame.
  url <- 'http://games.espn.go.com/flb/tools/projections?&startIndex='
  columns <- c('Rank', 'Player', 'R', 'HR', 'RBI', 'SB', 'AVG')
  classes <- c('numeric', 'character', rep('numeric', 5))
  projections.df <- readHTMLTable(paste0(url, 0), which=2, skip.rows=c(1),
                                  colClasses=classes)
  colnames(projections.df) <- columns
  
  # Load next 440 players. This includes nearly all players, the majority of
  # whom will not be drafted.
  for(i in seq(40, 400, 40)) {
    tmp <- readHTMLTable(paste0(url, i), which=2, skip.rows=c(1),
                         colClasses=classes)
    colnames(tmp) <- columns
    projections.df <- rbind(projections.df, tmp)
  }
  
  
  # Split the player column into useful pieces.
  # This part in particular could be way better; I'm learning.
  
  # Remove injury status
  projections.df[,c('Player')] <- 
    str_split_fixed(projections.df$Player, "  ", 2)[,1]
  
  # Split off player name
  projections.df[,c('Player', 'Team')] <- 
    str_split_fixed(projections.df$Player, ", ", 2)
  
  # Split off team
  projections.df[,c('Team', 'Pos')] <- 
    str_split_fixed(projections.df$Team, " ", 2)
  
  # Split off positions
  projections.df[,c('Pos', 'Pos2', 'Pos3', 'Pos4', 'Pos5')] <- 
    str_split_fixed(projections.df$Pos, ", ", 5)
  
  
  # Convert positions and teams to factors
  projections.df$Team <- as.factor(projections.df$Team)
  projections.df$Pos <- as.factor(projections.df$Pos)
  projections.df$Pos2 <- as.factor(projections.df$Pos2)
  projections.df$Pos3 <- as.factor(projections.df$Pos3)
  projections.df$Pos4 <- as.factor(projections.df$Pos4)
  projections.df$Pos5 <- as.factor(projections.df$Pos5)
  
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

load_data_fantasypros <- function() {
  # Load FantasyPro's hitting projections.
  # This function is not particularly efficient, but it works.
  
  # Load projections
  url <- 'http://www.fantasypros.com/mlb/projections/hitters.php?page=ALL'
  classes <- c('character', rep('numeric', 15))
  projections.df <- readHTMLTable(url, which=2, colClasses=classes)
  
  
  # Split the player column into useful pieces.
  # This part in particular could be way better; I'm learning.
  
  # Rename first column
  colnames(projections.df)[1] <- 'Player'
  
  # TODO: strip end parentheses and white space
  
  # Split player column into name and team/pos
  projections.df <- with(projections.df,
                         cbind(colsplit(projections.df$Player,
                                        pattern='\\(',
                                        names=c('Player', 'Team.Pos')),
                               projections.df[,2:16]))
  
  # Split team/pos column into team and pos
  projections.df <- with(projections.df,
                         cbind(Player,
                               colsplit(projections.df$Team.Pos,
                                        pattern='\\,',
                                        names=c('Team', 'Pos')),
                               projections.df[,3:17]))
  
  # Split positions
  projections.df <- with(projections.df,
                         cbind(Player, Team,
                               colsplit(projections.df$Pos,
                                        pattern='\\/',
                                        names=c('Pos1', 'Pos2')),
                               projections.df[,4:18]))
  projections.df <- with(projections.df,
                         cbind(Player, Team, Pos1, 
                               colsplit(projections.df$Pos2,
                                        pattern='\\/',
                                        names=c('Pos2', 'Pos3')),
                               projections.df[,5:19]))
  projections.df <- with(projections.df,
                         cbind(Player, Team, Pos1, Pos2,
                               colsplit(projections.df$Pos3,
                                        pattern='\\/',
                                        names=c('Pos3', 'Pos4')),
                               projections.df[,6:20]))
  
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
projections.df <- load_data()

# Save data frame to an .rds file
saveRDS(projections.df, file='projections.rds')
