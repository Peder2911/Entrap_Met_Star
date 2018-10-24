
# Shut the imports up!
devnull <- file('/dev/null','w')

sink(file = devnull,type = 'message')

require(stringr)
require(glue)

require(jsonlite)
require(redux)

scriptpath <- ComfyInTurns::myPath()

# Read config from stdin (dfi) #####

config <- readLines('stdin')%>%
	fromJSON()

sink(type = 'message')

# Assign config values #############
# slims down the code ##############

col <- config[['field to search']]%>%
	unlist()

pattern <- config[['regex pattern']]%>%
	unlist()

chunksize <- config[['chunksize']]%>%
	unlist()

keepdiscard <- config[['keep or discard']]%>%
	unlist()

# path stuff #######################

pyregex <- dirname(scriptpath)%>%
	paste('lib/pyRegex.py',sep = '/')

key <- config$redis$listkey

# Read my functions ################

dirname(scriptpath)%>%
	paste('lib/extRegex.R',sep ='/')%>%
	source()

# Redis stuff ######################
# the config might be useless ######

sink(devnull)
redis_config(host = config$redis$hostname,
	     port = config$redis$port,
	     db = config$redis$db)
sink()

redis <- hiredis()

# Process data #####################

# See functions in lib/ ############

extRegexDf <- function(df,col,pattern,pyregex,keepdiscard){
	matches <- df[col]%>%
		      unlist()%>%
		      extRegex(pattern,pyregex)
	if(keepdiscard == 'keep'){
		df <- df[matches,]
		}
		else {
		df <- df[!matches,]	
		}
	}


DBgratia::redisChunkApply(redis,
                          key,
                          FUN = extRegexDf, 
                          chunksize = chunksize,
                          verbose = TRUE,
			  col = col,
			  pattern = pattern,
			  pyregex = pyregex,
			  keepdiscard = keepdiscard)



