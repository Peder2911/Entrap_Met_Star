devnull <- file('/dev/null','w')
sink(file = devnull,type = 'message')

library(glue)
library(dplyr)

sink(type = 'message')

doStuff <- function(dat){

        print(glue_collapse(c('rows read:',nrow(dat)),sep = ' '))

        print(glue_collapse(c('column names:',names(dat)),sep = '\n'))

	dat
	}
