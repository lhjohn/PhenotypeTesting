# Load the package
library(covidPhenotypesTest)

# IF you see an Error: database or disk is full error, consider downgrading Andromeda using below:
#remotes::install_github("OHDSI/Andromeda",ref="b3cd1d50605c3344faa0f15f57f930e0666f3519")

options(andromedaTempFolder = "~/tmp")

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
outputFolder <- 
cdmDatabaseSchema <- 
cohortDatabaseSchema <- 
cohortTable <- 

options(sqlRenderTempEmulationSchema = NULL)

databaseId = 
databaseName = 
databaseDescription = 

execute(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  cohortDatabaseSchema = cohortDatabaseSchema,
  cohortTable = cohortTable,
  outputFolder = outputFolder,
  databaseId = databaseId,
  databaseName = databaseName,
  databaseDescription = databaseDescription
)

CohortDiagnostics::preMergeDiagnosticsFiles(dataFolder = outputFolder)
CohortDiagnostics::launchDiagnosticsExplorer(dataFolder = outputFolder)
