

library(PheValuator)

runPhenoTest <- function(connectionDetails,
                         cdmDatabaseSchema,
                         cohortDatabaseSchema = cdmDatabaseSchema,
                         cohortTable = "cohort",
                         oracleTempSchema = cohortDatabaseSchema,
                         outputFolder,
                         databaseId = "Unknown",
                         databaseName = "Unknown",
                         databaseDescription = "Unknown",
                         createCohorts = TRUE,
                         runSimpleMonthly = TRUE,
                         runOverlap = TRUE,
                         runPhevaluator = TRUE,
                         minCellCount = 5) {
  
  if (!file.exists(outputFolder))
    dir.create(outputFolder, recursive = TRUE)
  
  connection <- DatabaseConnector::connect(connectionDetails)
  
  if (createCohorts) {
    ParallelLogger::logInfo("Creating cohorts")
    .createCohorts(connection = connection,
                   cdmDatabaseSchema = cdmDatabaseSchema,
                   cohortDatabaseSchema = cohortDatabaseSchema,
                   cohortTable = cohortTable,
                   oracleTempSchema = oracleTempSchema,
                   outputFolder = outputFolder)
  }

  xSpecCohort <- 4886 #replace with generated xSpec cohort ID
  xSensCohort <- 4902 #replace with generated xSens cohort ID
  prevalenceCohort <- 4873  #replace with generated prevalence cohort ID
  evaluationPopulationCohortId <- 4874 #replace with generated evaluation population cohort ID
  
  # Create analysis settings ----------------------------------------------------------------------------------------
  CovSettings <- createDefaultAcuteCovariateSettings(excludedCovariateConceptIds = c(), #add excluded concept ids if needed
                                                     addDescendantsToExclude = TRUE,
                                                     startDayWindow1 = 0, #change the feature windows if needed
                                                     endDayWindow1 = 10,
                                                     startDayWindow2 = 11,
                                                     endDayWindow2 = 20,
                                                     startDayWindow3 = 21,
                                                     endDayWindow3 = 30)
  
  CohortArgs <- createCreateEvaluationCohortArgs(xSpecCohortId = xSpecCohort,
                                                 xSensCohortId = xSensCohort,
                                                 prevalenceCohortId = prevalenceCohort,
                                                 evaluationPopulationCohortId = evaluationPopulationCohortId,
                                                 covariateSettings = CovSettings,
                                                 #  modelPopulationCohortId = evaluationPopulationCohortId,
                                                 # modelType = "acute",
                                                 lowerAgeLimit = 18,
                                                 upperAgeLimit = 120,
                                                 visitType = c(9201,9202,9203,581477),
                                                 startDate = "20191201",
                                                 endDate = "21000101")
  
  #################################
  AlgTestArgs1 <- createTestPhenotypeAlgorithmArgs(phenotypeCohortId = xSpecCohort)
  
  analysis1 <- createPheValuatorAnalysis(analysisId = 1,
                                         description = "xSpec",
                                         createEvaluationCohortArgs = CohortArgs,
                                         testPhenotypeAlgorithmArgs = AlgTestArgs1)
  
  #################################
  AlgTestArgs2 <- createTestPhenotypeAlgorithmArgs(phenotypeCohortId = prevalenceCohort)
  
  analysis2 <- createPheValuatorAnalysis(analysisId = 2,
                                         description = "Prevalence",
                                         createEvaluationCohortArgs = CohortArgs,
                                         testPhenotypeAlgorithmArgs = AlgTestArgs2)
  
  #################################
  AlgTestArgs3 <- createTestPhenotypeAlgorithmArgs(phenotypeCohortId = 3519) #change to first phenotype algorithm cohort ID to test
  
  analysis3 <- createPheValuatorAnalysis(analysisId = 3,
                                         description = "[3519] 1. Catch all", #change to name of phenotype algorithm cohort
                                         createEvaluationCohortArgs = CohortArgs,
                                         testPhenotypeAlgorithmArgs = AlgTestArgs3)
  
  #################################
  AlgTestArgs4 <- createTestPhenotypeAlgorithmArgs(phenotypeCohortId = 4703) #change to first phenotype algorithm cohort ID to test
  
  analysis4 <- createPheValuatorAnalysis(analysisId = 4,
                                         description = "[4703] 2. Diagnosis Confirmed", #change to name of phenotype algorithm cohort
                                         createEvaluationCohortArgs = CohortArgs,
                                         testPhenotypeAlgorithmArgs = AlgTestArgs3)
  # 
  # #################################
  AlgTestArgs5 <- createTestPhenotypeAlgorithmArgs(phenotypeCohortId = 4704) #change to second phenotype algorithm cohort ID to test
  
  analysis5 <- createPheValuatorAnalysis(analysisId = 5,
                                         description = "[4704] 3. Laboratory Confirmed", #change to name as above
                                         createEvaluationCohortArgs = CohortArgs,
                                         testPhenotypeAlgorithmArgs = AlgTestArgs4)
  # 
  # #################################
  AlgTestArgs <- createTestPhenotypeAlgorithmArgs(phenotypeCohortId = 3522) #change to second phenotype algorithm cohort ID to test
  
  analysis6 <- createPheValuatorAnalysis(analysisId = 6,
                                         description = "[3522] 4. Syptomatic", #change to name as above
                                         createEvaluationCohortArgs = CohortArgs,
                                         testPhenotypeAlgorithmArgs = AlgTestArgs)
  
  # #################################
  AlgTestArgs <- createTestPhenotypeAlgorithmArgs(phenotypeCohortId = 3523) #change to second phenotype algorithm cohort ID to test
  
  analysis7 <- createPheValuatorAnalysis(analysisId = 7,
                                         description = "[3523] 5. Suspected", #change to name as above
                                         createEvaluationCohortArgs = CohortArgs,
                                         testPhenotypeAlgorithmArgs = AlgTestArgs)
 
  pheValuatorAnalysisList <- list(analysis1, analysis2, analysis3, analysis4, analysis5, analysis6, analysis7) #add/remove analyses
  
  
  
  CCAE_OHDA_RSSpec <- list(databaseId = databaseId,
                           cdmDatabaseSchema = cdmDatabaseSchema,
                           cohortDatabaseSchema = cohortDatabaseSchema,
                           cohortTable = cohortTable,
                           workDatabaseSchema = "scratch_cflach",
                           connectionDetails = connectionDetails) #change to your password
  
  # CCAE_OHDA_RSSpec <- list(databaseId = "FRANCELPD", #change to your CDM of choice
  #                          cdmDatabaseSchema = "cdm_truven_ccae_v1479",
  #                          cohortDatabaseSchema = "results_truven_ccae_v1479",
  #                          cohortTable = "cohort",
  #                          workDatabaseSchema = "scratch_jswerdel",
  #                          connectionDetails = createConnectionDetails(dbms = "redshift",
  #                                                                      pathToDriver = "C:/Users/cflach/Documents/drivers",
  #                                                                      connectionString =  paste("jdbc:redshift://ohda-prod-1.cldcoxyrkflo.us-east-1.redshift.amazonaws.com:5439/truven_ccae?ssl=true&sslfactory=com.amazon.redshift.ssl.NonValidatingFactory", sep=""),
  #                                                                      user = "cflach@uk.imshealth.com", #change to your user name
  #                                                                      password = "ChangeMe2020")) #change to your password
  
  
  referenceTable <- runPheValuatorAnalyses(connectionDetails = CCAE_OHDA_RSSpec$connectionDetails,
                                           cdmDatabaseSchema = CCAE_OHDA_RSSpec$cdmDatabaseSchema,
                                           cohortDatabaseSchema = CCAE_OHDA_RSSpec$cohortDatabaseSchema,
                                           cohortTable = CCAE_OHDA_RSSpec$cohortTable,
                                           workDatabaseSchema = CCAE_OHDA_RSSpec$cohortDatabaseSchema,
                                           outputFolder = outFolder,
                                           pheValuatorAnalysisList = pheValuatorAnalysisList)
  
  savePheValuatorAnalysisList(pheValuatorAnalysisList, file.path(outFolder, "pheValuatorAnalysisSettings.json"))
  
  View(summarizePheValuatorAnalyses(referenceTable, outFolder), paste0("Results", CCAE_OHDA_RSSpec$databaseId))
  
  results<-(summarizePheValuatorAnalyses(referenceTable, outFolder))
  write.xlsx(results, file=paste0(outFolder, "/results_summary.xlsx"))
  
  DatabaseConnector::disconnect(connection)
}

