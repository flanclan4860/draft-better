# Standardize stas for the projected drafted players
# Essentially, look at the top X rated players at a position who will likely
# be drafted. Standardize their five hitting statistics, and then calculate
# standardized scores for all players of that position using the likely
# drafted players' means and standard deviations.

# Load settings
source('settings.R', local=TRUE)

# Load projected statistics
projections.df <- readRDS('projections.rds')

# Standardize