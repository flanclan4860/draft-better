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
    str_split_fixed(projections.df$Player, "  ", 2)[,1]
  
  # Split off player name
  projections.df[,c('Player', 'Team')] <- 
    str_split_fixed(projections.df$Player, ", ", 2)
  
  # Split off team
  projections.df[,c('Team', 'Pos')] <- 
    str_split_fixed(projections.df$Team, " ", 2)
  
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

# Load data
projections.df <- load_data_ESPN()

# Save data frame to an .rds file
saveRDS(projections.df, file='projections.rds')