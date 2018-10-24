devnull <- file('/dev/null','w')

sink(file = devnull,type = 'message')
library(glue)
library(dplyr)
sink(type = 'message')

extRegex <- function(string,pattern,scriptpath){

	string <- gsub('\n',' ',string)

        call <- paste('python3',scriptpath)
        string <- glue_collapse(string,sep = '\n')
        stringAndRegex <- glue_collapse(c(pattern,string),sep = '\n')

        res <- system(call,
                      intern = TRUE,
                      input = stringAndRegex)

        res <- res%>%
                str_split('\n')%>%
                unlist()%>%
                sapply(FUN = function(x) x == 'True')

        }

