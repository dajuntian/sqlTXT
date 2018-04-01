# TEST CODE, NOT INCLUDED IN BUILD
library("RSQLite")
con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")

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
CREATE TABLE contacts (
 contact_id integer PRIMARY KEY,
first_name text NOT NULL,
last_name text NOT NULL,
email text NOT NULL UNIQUE,
phone text NOT NULL UNIQUE
);
delete from mtcars where gear = 3;
alter table mtcars add snew_column3 char(10);
select * from mtcars;
select * from contacts;
/*end of code*/"

r_r <- commit_sql(con, sqlFromText, is_file = F)

