#' Commit sql from file or character variable
#' 
#' @param conn DBIConnection to sql server
#' @param code Character of code or path to sql code
#' @param is_file Logical variable indicates the code parameter refers to file name, defaults to TRUE
#' 
#' @return List of data frames from all select statement, empty if no select statment
#' @examples 
#' \dontrun{
#' jcc <- RJDBC::JDBC("com.ibm.db2.jcc.DB2Driver", "C:/db2jcc4.jar")
#' conn <- RJDBC::dbConnect(jcc, "jdbc:db2://hostname:12345/dbname", "user", "pwd")
#' commit_sql(conn, "/home/user/bearhunt.sql")
#' commit_sql(conn, "select * from session.ca", is_file = F)
#' }
#' @export 
#' @seealso \url{https://github.com/dajuntian/sqlTXT}
commit_sql <- function(conn, code, is_file = TRUE) {
  if (is_file) {code <- readChar(code, file.info(code)$size)}
  
  #separate into a list for code
  pattern <- "((?:[^;\"']|\"[^\"]*\"|'[^']*')+)"
  m <- gregexpr(pattern, code)
  code_list <- unlist(regmatches(code, m))
  
  #initialize empty list 
  result <- list()
  
  #remove comments
  code_list <- gsub("(--.*)|(((/\\*)+?[\\w\\W]+?(\\*/)+))", " ", 
                    code_list, perl = T)
  
  #loop through each statement in sql
  for (sql_statement in code_list) {
    sql_statement <- trimws(gsub("\\s+", " ", sql_statement, perl = T))
    
    if (sql_statement == "" | is.na(sql_statement)) {break}
    
    if (grepl("^select", sql_statement, ignore.case = T, perl = T)) {
      #return data frame for select statement
      result[[length(result) + 1]] <- DBI::dbGetQuery(conn, sql_statement)
    } else {
      #submit and release resources for non-select clauses
      #check if it is RJDBC
      if (attr(class(conn), "package") == "RJDBC"){
        RJDBC::dbSendUpdate(conn, sql_statement)
      }
      else {
        DBI::dbClearResult(DBI::dbSendStatement(conn, sql_statement))
      }
     
    }
  }
  result
} 


