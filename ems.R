
# Shut the imports up!
devnull <- file('/dev/null','w')

sink(file = devnull,type = 'message')

require(stringr)
require(glue)

require(tools)

require(jsonlite)
require(redux)

# Utility stuff ####################

scriptpath <- ComfyInTurns::myPath()

config <- readLines('stdin')%>%
	fromJSON()

sink(type = 'message')

# Read my functions ################

dirname(scriptpath)%>%
	paste('lib/funcs.R',sep = '/')%>%
	source()
dirname(scriptpath)%>%
	paste('lib/extRegex.R',sep ='/')%>%
	source()

# Redis stuff ######################

sink(devnull)
redis_config(host = config$redis$hostname,
	     port = config$redis$port,
	     db = config$redis$db)
sink()

r <- hiredis()

# Read data ########################

ln <- ''
indata <- character()

while(!is.null(ln)){
	ln <- r$LPOP(config$redis$listkey)
	indata <- c(indata,ln)
	}

if(length(indata) > 1){

	# text to csv ##############

	indata <- glue_collapse(indata,sep = '\n')
	dat <- read.csv(text = indata,stringsAsFactors = FALSE)
	rm(indata)
	
	# Do stuff to the data #####

	# doStuff(dat)

	field <- config[['field to search']]%>%
			unlist()
	regex <- config[['regex pattern']]
	scriptpath <- scriptpath%>%
		dirname()%>%
		paste('lib/pyRegex.py',sep = '/')
	coldat <- dat[field]%>%
			unlist()

	keep <- coldat%>% 
			extRegex(regex,scriptpath)

	dat <- dat[keep,]


	fauxfile <- textConnection('fauxfile','w')
	write.csv(dat,fauxfile)
	rm(dat)
	
	# shut it up
	sink(devnull)
	write(fauxfile,'tee.txt')

	sapply(fauxfile,FUN = function(x){
	     		r$RPUSH(config$redis$listkey,x)
	     		})
	sink()

	}else{

	# Or else? #################

	warning('no data read')
	}


