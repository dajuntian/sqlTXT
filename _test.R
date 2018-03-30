# TEST CODE, NOT INCLUDED IN BUILD
library("RSQLite")
con <- dbConnect(RSQLite::SQLite(), ":memory:")

dbWriteTable(con, "mtcars", mtcars)
dbListTables(con)

res <- DBI::dbSendQuery(con, "select * from mtcars")
DBI::dbFetch(res)
DBI::dbClearResult(res)

rs <- DBI::dbExecute(con, "delete from mtcars where gear = 3")

rs <- DBI::dbSendStatement(con, "delete from mtcars where gear = 3")
DBI::dbClearResult(rs)

sqlFromText <- "
--some comments
select * from mtcars;
delete from mtcars where gear = 3;
alter table mtcars add new_column2 char(10);
select * from mtcars;
/*new comments*/"

commit_sql(con, sqlFromText, is_file = F)

