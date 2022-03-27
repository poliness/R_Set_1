#1. Wczytaj plik autaSmall.csv i wypisz pierwsze 5 wierszy

?read.csv
getwd()

df1 <- read.csv("autaSmall.csv", encoding = "UTF-8")
head(df1,5)

#2. Pobierz dane pogodowe z REST API

install.packages("jsonlite")
install.packages("httr")

library(jsonlite)
require(httr)

endpoint <- "https://api.openweathermap.org/data/2.5/weather?q=Warszawa&appid=1765994b51ed366c506d5dc0d0b07b77"
response <- GET(endpoint)
content <- content(response,"text")
fromJSON(content)
fromJSON(endpoint)

weatherDF <- as.data.frame(fromJSON(endpoint))
View(weatherDF)

#3.Napisz funkcję zapisującą porcjami danych plik csv do tabeli  w SQLite
#Mały przykład - autaSmall.csv



readToBase<-function(filepath,con,tablename,size,sep=",",header=TRUE,delete=TRUE,encoding="UTF-8"){
  ap=!delete
  ov=delete
  
  fileCon <- file(description = filepath, open = "r",encoding = encoding)
  
  df1 <- read.table(fileCon, header=TRUE, 
                    sep=sep,fill=TRUE,fileEncoding = encoding, 
                    nrows=size)
  if(nrow(df1)==0)
    return(0)
  myColNames <- names(df1)
  #zapis do bazy
  dbWriteTable(con,tablename,df1, append=ap, overwrite=ov)
  print(df1)
  repeat{
    if(nrow(df1)==0){
      close(fileCon)
      dbDisconnect(con)
      break;
    }
    df1 <- read.table(fileCon, col.names = myColNames, 
                      sep=sep,fill=TRUE,fileEncoding = encoding, 
                      nrows=size)
    dbWriteTable(con,tablename,df1, append=TRUE, overwrite=FALSE)
    
    #zapis do bazy
    print(nrow(df1))
  }
  
}

con <- dbConnect(SQLite(),"auta.sqlite")
readToBase("autaSmall.csv",con,"auta2",1000)

install.packages("DBI")
install.packages("RSQLite")
# library(DBI)
# library(RSQLite)

?file



# i<-1
# repeat{
#   if(i>5){
#     break
#   }
#   print(i)
#   i<-i+1
# }

#close(fileCon)

View(df1)
View(df2)

#4.Napisz funkcję znajdującą tydzień obserwacji z największą średnią ceną ofert korzystając z zapytania SQL.

con <- dbConnect(SQLite(),"auta.sqlite")
res<-dbSendQuery(con,"SELECT * FROM auta2")
dbFetch(res)
dbClearResult(res)
close(con)

#5. Podobnie jak w poprzednim zadaniu napisz funkcję znajdującą tydzień obserwacji z największą średnią ceną ofert  tym razem wykorzystując REST api.