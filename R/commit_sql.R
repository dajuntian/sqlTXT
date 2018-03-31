#' Commit sql from file or character variable
#' 
#' Read code file or character variable, separate into single sql statements
#' commit to sql connection and catch results from last select
#' 
#' @param conn DBIConnection to sql server
#' @param code Character to file or could be sql it self
#' @param is_file Logical indicate the code parameter refers to file name
#' 
#' @return Data frame from the last select statement, NA if no select statment
#' 
#' @export

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
      #submit and release resources
      DBI::dbClearResult(DBI::dbSendStatement(conn, sql_statement))
    }
  }
  result
} # end of commit_sql