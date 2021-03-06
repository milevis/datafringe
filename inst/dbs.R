

# https://nhorton.people.amherst.edu/precursors/files/meetupsql2.pdf

library(tidyverse)


###
db <- src_sqlite("~/Desktop/fringe/db.sqlite3", create = T)
src_tbls(db)
tbl(db,"hola_data")


###
db <- src_sqlite("db.sqlite3", create = T)

copy_to(db,cars)
db_drop_table(db$con,table='cars')
src_tbls(db)

copy_to(db,cars, temporary=FALSE)
src_tbls(db)

dbmtcars <- copy_to(db,mtcars)

src_tbls(db)

tbl(dbmtcars,"mtcars")

dfdb <- tbl(db, sql("SELECT * FROM mtcars"))
df <- tbl(db, sql("SELECT * FROM mtcars")) %>% collect(n=Inf)

x <- df %>% filter(gear == 4) %>% collect(n=Inf)


my_db <- src_sqlite( "my_db.sqlite3", create = TRUE)                 # create src
copy_to( my_db, iris, "my_table", temporary = FALSE)                 # create table
db_insert_into( con = my_db$con, table = "my_table", values = newdf) # insert into


