# Load the package
library(covidPhenotypesTest)

# Details for connecting to the server:
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "redshift",
                                                                server = Sys.getenv("FRANCELPD_SERVERDB"),
                                                                user = Sys.getenv("REDSHIFT_USER"),
                                                                password = Sys.getenv("REDSHIFT_PASSWORD"),
                                                                port = 5439)

# For Oracle: define a schema that can be used to emulate temp tables:
oracleTempSchema <- NULL

# Details specific to the database:
outputFolder <- "output1"
cdmDatabaseSchema <- Sys.getenv("FRANCELPD_SCHEMA")
cohortDatabaseSchema <- "study_reference"
cohortTable <- "covid_phenos"

covidPhenotypesTest::runPhenoTest(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  cohortDatabaseSchema = cohortDatabaseSchema,
  cohortTable = cohortTable,
  oracleTempSchema = oracleTempSchema,
  outputFolder = outputFolder,
  databaseId = databaseId,
  databaseName = databaseName,
  databaseDescription = databaseDescription,
  createCohorts = TRUE,
  runSimpleMonthly = TRUE,
  runOverlap = TRUE,
  minCellCount = 5
)
