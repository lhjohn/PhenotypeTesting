# Load the package
library(covidPhenotypesTest)

# IF you see an Error: database or disk is full error, consider downgrading Andromeda using below:
#remotes::install_github("OHDSI/Andromeda",ref="b3cd1d50605c3344faa0f15f57f930e0666f3519")

options(andromedaTempFolder = "~/tmp")

# Details for connecting to the server:
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "redshift",
                                                                server = Sys.getenv(str_c(i,"_SERVERDB")),
                                                                user = Sys.getenv("REDSHIFT_USER"),
                                                                password = Sys.getenv("REDSHIFT_PASSWORD"),
                                                                port = 5439,
                                                                pathToDriver = "~/drivers")

# For Oracle: define a schema that can be used to emulate temp tables:
oracleTempSchema <- NULL

# Details specific to the database:
outputFolder <- file.path(getwd(),str_c("output_",i))
cdmDatabaseSchema <- Sys.getenv(str_c(i,"_SCHEMA"))
cohortDatabaseSchema <- "study_reference"
cohortTable <- "covid_phenos_test"

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
  createBaseCohorts = T,
  runSimpleMonthly = T,
  runOverlap = T,
  runPhevaluator = T,
  minCellCount = 5
)
