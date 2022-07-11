#1. Wczytaj plik autaSmall.csv i wypisz pierwsze 5 wierszy

#dokumentacja R o metodzie read.csv
?read.csv
#wyświetlenie ścieżki pliku
getwd()

#pobranie pliku .csv z kodowaniem i wyświetlenienie 5 pierwszych wierszy
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

#install.packages("DBI")
#install.packages("RSQLite")
library(DBI)
library(RSQLite)

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

#4.Napisz funkcję znajdującą tydzień obserwacji z największą średnią ceną ofert korzystając z zapytania SQL.

con <- dbConnect(SQLite(),"auta.sqlite")
res<-dbSendQuery(con,"SELECT tydzien FROM (SELECT tydzien, MAX(avg_cena) FROM ((SELECT tydzien, AVG(cena) AS avg_cena FROM auta2 GROUP BY tydzien) AS max_cena))")
fin <- dbFetch(res)
dbClearResult(res)
dbDisconnect(con)

result <- fin[1,1]

cat("Tydzień obserwacji z największą średnią ceną to tydzień nr: ", result)

#5. Podobnie jak w poprzednim zadaniu napisz funkcję znajdującą tydzień obserwacji 
#z największą średnią ceną ofert tym razem wykorzystując REST api.

#install.packages("httr")
require("httr")
#install.packages("jsonlite")
require("jsonlite")
require(tidyverse)


readByAPI<-function(){
  
  #pobranie liczby tygodni z API
  
  pathWeeknNum <- "http://54.37.136.190:8000/nweek"
  rWeekNum <- GET(pathWeeknNum)
  cWeekNum <- content(rWeekNum,"text",encoding = "UTF-8")
  weekNum <- fromJSON(cWeekNum) %>% as.data.frame
  
  counter <- weekNum[1,1]
  
  #typeof(num)
  
  dfFinal <- data.frame()
  
  for( i in 1: (counter) ){
    path <- paste0("http://54.37.136.190:8000/week?t=",i)
    r <- GET(path)
    c <- content(r,"text",encoding = "UTF-8")
    fromJSON(c)
    fromJSON(path)
    autaDFweek <- as.data.frame(fromJSON(path))
    
    dfFinal <- rbind(dfFinal,autaDFweek)
  }
  
  #obliczenie sredniej ceny dla kazdego tygodnia
  
  df_agg <- aggregate(cena~tydzien,data=dfFinal,mean)
  df_res <- df_agg[which.max(df_agg$cena),]
  result <- df_res[1,1]
  
  return(result)
}


res <- readByAPI()
cat("Tydzień obserwacji z największą średnią ceną to tydzień nr: ", res)