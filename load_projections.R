library(XML)
library(reshape2)

# Load ESPN's hitting projections.

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

original.df <- projections.df

# Split the name column into name, team, & position
# BUG: team column isn't splitting into team/position like I want it to
projections.df[,c('Player', 'Team')] <- 
  str_split_fixed(projections.df$Player, ", ", 2)
projections.df[,c('Team', 'Pos')] <- 
  str_split_fixed(projections.df$Team, " ", 2)
