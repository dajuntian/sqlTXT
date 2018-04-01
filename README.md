
<!-- README.md is generated from README.Rmd. Please edit that file -->
sqlTXT
======

The goal of sqlTXT is to submit multiple SQL statements through a single function call and to get results as a list of data frames.

How does it work?
=================

It first separates the code into segments by ';' and then removes comments. Loop through all the segments, it will send the query into the DBI connection and add data frame to the result for select. What it returns is a list and element in the list is the data frame from select statements.

Installation
------------

You can install sqlTXT from github with:

``` r
# install.packages("devtools")
devtools::install_github("dajuntian/sqlTXT")
#> Downloading GitHub repo dajuntian/sqlTXT@master
#> from URL https://api.github.com/repos/dajuntian/sqlTXT/zipball/master
#> Installing sqlTXT
#> "C:/PROGRA~1/R/R-34~1.3/bin/x64/R" --no-site-file --no-environ --no-save  \
#>   --no-restore --quiet CMD INSTALL  \
#>   "C:/Users/David/AppData/Local/Temp/RtmpAd6DnB/devtools24442894fb3/dajuntian-sqlTXT-c2ff38b"  \
#>   --library="C:/Users/David/Documents/R/win-library/3.4" --install-tests
#> 
```

Example
-------

This is a basic example to show you how to use the package

``` r
## basic example

# generate DBI Connection
con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
DBI::dbWriteTable(con, "mtcars", mtcars)
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


result_from_sql <- sqlTXT::commit_sql(con, sqlFromText, is_file = F)

for (item in result_from_sql) {
  cat("Date frame returned from SQL\n")
  print(head(item))
  cat("\n")
}
#> Date frame returned from SQL
#>    mpg cyl disp  hp drat    wt  qsec vs am gear carb
#> 1 21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
#> 2 21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
#> 3 22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
#> 4 21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
#> 5 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2
#> 6 18.1   6  225 105 2.76 3.460 20.22  1  0    3    1
#> 
#> Date frame returned from SQL
#>    mpg cyl  disp  hp drat    wt  qsec vs am gear carb snew_column3
#> 1 21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4         <NA>
#> 2 21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4         <NA>
#> 3 22.8   4 108.0  93 3.85 2.320 18.61  1  1    4    1         <NA>
#> 4 24.4   4 146.7  62 3.69 3.190 20.00  1  0    4    2         <NA>
#> 5 22.8   4 140.8  95 3.92 3.150 22.90  1  0    4    2         <NA>
#> 6 19.2   6 167.6 123 3.92 3.440 18.30  1  0    4    4         <NA>
#> 
#> Date frame returned from SQL
#> [1] contact_id first_name last_name  email      phone     
#> <0 rows> (or 0-length row.names)
```
