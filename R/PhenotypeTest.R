#' # Copyright 2020 Observational Health Data Sciences and Informatics
#' #
#' # This file is part of covidPhenotypesTest
#' #
#' # Licensed under the Apache License, Version 2.0 (the "License");
#' # you may not use this file except in compliance with the License.
#' # You may obtain a copy of the License at
#' #
#' #     http://www.apache.org/licenses/LICENSE-2.0
#' #
#' # Unless required by applicable law or agreed to in writing, software
#' # distributed under the License is distributed on an "AS IS" BASIS,
#' # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#' # See the License for the specific language governing permissions and
#' # limitations under the License.
#' 
#' #' Execute the cohort phenotype test
#' #'
#' #' @details
#' #' This function executes the cohorts phenotype test.
#' #'
#' #' @param connectionDetails    An object of type \code{connectionDetails} as created using the
#' #'                             \code{\link[DatabaseConnector]{createConnectionDetails}} function in the
#' #'                             DatabaseConnector package.
#' #' @param cdmDatabaseSchema    Schema name where your patient-level data in OMOP CDM format resides.
#' #'                             Note that for SQL Server, this should include both the database and
#' #'                             schema name, for example 'cdm_data.dbo'.
#' #' @param cohortDatabaseSchema Schema name where intermediate data can be stored. You will need to have
#' #'                             write priviliges in this schema. Note that for SQL Server, this should
#' #'                             include both the database and schema name, for example 'cdm_data.dbo'.
#' #' @param cohortTable          The name of the table that will be created in the work database schema.
#' #'                             This table will hold the exposure and outcome cohorts used in this
#' #'                             study.
#' #' @param oracleTempSchema     Should be used in Oracle to specify a schema where the user has write
#' #'                             priviliges for storing temporary tables.
#' #' @param outputFolder         Name of local folder to place results; make sure to use forward slashes
#' #'                             (/). Do not use a folder on a network drive since this greatly impacts
#' #'                             performance.
#' #' @param databaseId           A short string for identifying the database (e.g.
#' #'                             'Synpuf').
#' #' @param databaseName         The full name of the database (e.g. 'Medicare Claims
#' #'                             Synthetic Public Use Files (SynPUFs)').
#' #' @param databaseDescription  A short description (several sentences) of the database.
#' #' @param createCohorts        Create the cohortTable table with the exposure and outcome cohorts?
#' #' @param runSimpleMonthly     Pull monthly counts
#' #' @param runOverlap           Pull cohort overlap
#' #' @param minCellCount         The minimum number of subjects contributing to a count before it can be included 
#' #'                             in packaged results.
#' #'

#' runPhenoTest <- function(connectionDetails,
#'                          cdmDatabaseSchema,
#'                          cohortDatabaseSchema = cdmDatabaseSchema,
#'                          cohortTable = "cohort",
#'                          oracleTempSchema = cohortDatabaseSchema,
#'                          outputFolder,
#'                          databaseId = "Unknown",
#'                          databaseName = "Unknown",
#'                          databaseDescription = "Unknown",
#'                          createCohorts = TRUE,
#'                          createBaseCohorts = TRUE,
#'                          runSimpleMonthly = TRUE,
#'                          runOverlap = TRUE,
#'                          runPhevaluator = TRUE,
#'                          minCellCount = 5) {
#'   
#'   if (!file.exists(outputFolder))
#'     dir.create(outputFolder, recursive = TRUE)
#' 
#'   connection <- DatabaseConnector::connect(connectionDetails)
#'   
#'   if (createCohorts) {
#'     ParallelLogger::logInfo("Creating cohorts")
#'     .createCohorts(connection = connection,
#'                    cdmDatabaseSchema = cdmDatabaseSchema,
#'                    cohortDatabaseSchema = cohortDatabaseSchema,
#'                    cohortTable = cohortTable,
#'                    oracleTempSchema = oracleTempSchema,
#'                    outputFolder = outputFolder)
#'   }
#'   
#'   if (createBaseCohorts) {
#'     ParallelLogger::logInfo("Creating base cohorts")
#'     .createBaseCohorts(connection = connection,
#'                    cdmDatabaseSchema = cdmDatabaseSchema,
#'                    cohortDatabaseSchema = cohortDatabaseSchema,
#'                    cohortTable = cohortTable,
#'                    oracleTempSchema = oracleTempSchema,
#'                    outputFolder = outputFolder)
#'   }
#'   
#'   
#'   # Fetch cohort counts:
#'   pathToCsv <- system.file("settings", "CohortsToCreate.csv", package = "covidPhenotypesTest")
#'   cohortsToCreate <- readr::read_csv(pathToCsv, col_types = readr::cols())
#'   sql <- "SELECT cohort_definition_id, COUNT(*) AS count FROM @cohort_database_schema.@cohort_table GROUP BY cohort_definition_id"
#'   sql <- SqlRender::render(sql,
#'                            cohort_database_schema = cohortDatabaseSchema,
#'                            cohort_table = cohortTable)
#'   sql <- SqlRender::translate(sql, targetDialect = attr(connection, "dbms"))
#'   counts <- DatabaseConnector::querySql(connection, sql)
#'   names(counts) <- SqlRender::snakeCaseToCamelCase(names(counts))
#'   counts <- merge(counts, data.frame(cohortDefinitionId = cohortsToCreate$cohortId,
#'                                      cohortName  = cohortsToCreate$name))
#'   write.csv(counts, file.path(outputFolder, "CohortCounts.csv"))
#'   
#'   if(runSimpleMonthly){
#'     
#'     message("Calculating phenotype incidence over time")
#'     sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "MonthlyCounts.sql",
#'                                              packageName = "covidPhenotypesTest",
#'                                              dbms = attr(connection, "dbms"),
#'                                              oracleTempSchema = oracleTempSchema,
#'                                              cohort_database_schema = cohortDatabaseSchema,
#'                                              cohort_table = cohortTable,
#'                                              limit_criteria = 'cohort_definition_id IN (2, 4, 6, 8, 10)')
#'     
#'     counts <- DatabaseConnector::querySql(connection, sql)
#'     names(counts) <- SqlRender::snakeCaseToCamelCase(names(counts))
#'     counts$countPersons[counts$countPersons < minCellCount] <- -minCellCount
#'     write.csv(counts, file.path(outputFolder, "MonthlyCohortCounts.csv"))
#'     
#'         sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "MonthlyDenominators.sql",
#'                                              packageName = "covidPhenotypesTest",
#'                                              dbms = attr(connection, "dbms"),
#'                                              oracleTempSchema = oracleTempSchema,
#'                                              cdm_database_schema = cdmDatabaseSchema)
#'     
#'     counts <- DatabaseConnector::querySql(connection, sql)
#'     names(counts) <- SqlRender::snakeCaseToCamelCase(names(counts))
#'     counts$countPersons[counts$countPersons < minCellCount] <- -minCellCount
#'     write.csv(counts, file.path(outputFolder, "MonthlyDenominators.csv"))
#' 
#'   }
#'   
#'   if(runOverlap){
#'     
#'     message("Calculating phenotype overlap")
#'     sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "OverlapCounts.sql",
#'                                              packageName = "covidPhenotypesTest",
#'                                              dbms = attr(connection, "dbms"),
#'                                              oracleTempSchema = oracleTempSchema,
#'                                              cohort_database_schema = cohortDatabaseSchema,
#'                                              cohort_table = cohortTable,
#'                                              limit_criteria = 'cohort_definition_id IN (1, 3)')
#'     counts <- DatabaseConnector::querySql(connection, sql)
#'     names(counts) <- SqlRender::snakeCaseToCamelCase(names(counts))
#'     counts$countPersons[counts$countPersons < minCellCount] <- -minCellCount
#'     
#'     pathToCsv <- system.file("settings", "CohortsToCreate.csv", package = "covidPhenotypesTest")
#'     cohortsToCreate <- readr::read_csv(pathToCsv, col_types = readr::cols())
#'     
#'     counts <- counts %>% 
#'       mutate(combinationName = map_chr(comboId, ~extract_bitsum(.x, str_remove(cohortsToCreate$name, '_ema_phenos__'))))
#'     
#'    # browser()
#'     final <- counts
#'     
#'     sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "OverlapCounts.sql",
#'                                              packageName = "covidPhenotypesTest",
#'                                              dbms = attr(connection, "dbms"),
#'                                              oracleTempSchema = oracleTempSchema,
#'                                              cohort_database_schema = cohortDatabaseSchema,
#'                                              cohort_table = cohortTable,
#'                                              limit_criteria = 'cohort_definition_id IN (1, 5)')
#'     counts <- DatabaseConnector::querySql(connection, sql)
#'     names(counts) <- SqlRender::snakeCaseToCamelCase(names(counts))
#'     counts$countPersons[counts$countPersons < minCellCount] <- -minCellCount
#' 
#'     counts <- counts %>% 
#'       mutate(combinationName = map_chr(comboId, ~extract_bitsum(.x, str_remove(cohortsToCreate$name, '_ema_phenos__'))))
#'     
#'     final <- rbind(final, counts)
#'     
#'     sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "OverlapCounts.sql",
#'                                              packageName = "covidPhenotypesTest",
#'                                              dbms = attr(connection, "dbms"),
#'                                              oracleTempSchema = oracleTempSchema,
#'                                              cohort_database_schema = cohortDatabaseSchema,
#'                                              cohort_table = cohortTable,
#'                                              limit_criteria = 'cohort_definition_id IN (1, 7)')
#'     counts <- DatabaseConnector::querySql(connection, sql)
#'     names(counts) <- SqlRender::snakeCaseToCamelCase(names(counts))
#'     counts$countPersons[counts$countPersons < minCellCount] <- -minCellCount
#'     
#'     counts <- counts %>% 
#'       mutate(combinationName = map_chr(comboId, ~extract_bitsum(.x, str_remove(cohortsToCreate$name, '_ema_phenos__'))))
#'     
#'     final <- rbind(final, counts)
#'     
#'     sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "OverlapCounts.sql",
#'                                              packageName = "covidPhenotypesTest",
#'                                              dbms = attr(connection, "dbms"),
#'                                              oracleTempSchema = oracleTempSchema,
#'                                              cohort_database_schema = cohortDatabaseSchema,
#'                                              cohort_table = cohortTable,
#'                                              limit_criteria = 'cohort_definition_id IN (1, 9)')
#'     counts <- DatabaseConnector::querySql(connection, sql)
#'     names(counts) <- SqlRender::snakeCaseToCamelCase(names(counts))
#'     counts$countPersons[counts$countPersons < minCellCount] <- -minCellCount
#'     
#'     counts <- counts %>% 
#'       mutate(combinationName = map_chr(comboId, ~extract_bitsum(.x, str_remove(cohortsToCreate$name, '_ema_phenos__'))))
#'     
#'     final <- rbind(final, counts)
#'     
#'     write.csv(final, file.path(outputFolder, "CohortOverlap.csv"))
#' 
#'   }
#'   
#'   if(runPhevaluator){
#'     
#'     prevalence <- estimate_prevalence_2020(connection, cohortDatabaseSchema, cohortTable)
#'     
#'     prevalence <- round(max(c(prevalence,0.05),na.rm=T),3)
#'     
#'     run_phevaluator_covid(connection = connection, prevalence, cdmDatabaseSchema = cdmDatabaseSchema, cohortDatabaseSchema = cohortDatabaseSchema, cohortTable = cohortTable, outputFolder = outputFolder)
#'     
#'   }
#' 
#'     DatabaseConnector::disconnect(connection)
#'   
#' }
