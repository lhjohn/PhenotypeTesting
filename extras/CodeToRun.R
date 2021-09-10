# Load the package
library(covidPhenotypesTest)
library(openxlsx)

# IF you see an Error: database or disk is full error, consider downgrading Andromeda using below:
#remotes::install_github("OHDSI/Andromeda",ref="b3cd1d50605c3344faa0f15f57f930e0666f3519")

options(andromedaTempFolder = "~/tmp")

outputFolder <- 

# Details for connecting to the server:
connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = ,
  server = ,
  user = ,
  password = ,
  port = ,
  pathToDriver = )

# For Oracle: define a schema that can be used to emulate temp tables:
oracleTempSchema <- NULL

# Details specific to the database:
cdmDatabaseSchema <- 
cohortDatabaseSchema <- 
cohortTable <- 

databaseId <- 
databaseName <-
databaseDescription <-

# Run phenotype analysis
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
  createCohorts = T,
  runSimpleMonthly = T,
  runOverlap = T,
  runPhevaluator = T,
  minCellCount = 5
)

## Export summary results to share with Iqvia
#exportPhenoResults(outputFolder)
