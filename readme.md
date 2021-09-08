covidPhenotypesTest
=========
  
This is version 2 of the pheValuator package for the eCore covid project

The main function of the package is to assess the above phenotypes by calculating their incidence over time (monthly), overlap and by running [PheValuator](https://github.com/OHDSI/PheValuator). These analysis can be executed using the runscript found in `extras/CodeToRun.R`. For a preliminary assessment of the phenotypes on your database,  [CohortDiagnostics](https://github.com/OHDSI/CohortDiagnostics) can be run using the runscript found in `extras/CodeToRunCohortDiagnostics.R`.

Steps to run
==================

1. After downloading this repository and opening the .Rproj file in RStudio, you should be prompted to build a local library using the `renv` package.  Running `renv::restore()` will build a local library containing all dependencies and versions. 
2. Make sure you have installed at least the following packages:
remotes::install_github("OHDSI/PheValuator")
remotes::install_github("OHDSI/CohortDiagnostics")
remotes::install_github("OHDSI/OhdsiRTools")
install.packages("xlsx")

3. Build the package using Build-->Install and restart. 

4. Open `extras/CodeToRun.R` and complete. The parameters should be similar to those used in other OHDSI studies: 

- <b>outputFolder</b>:  a directory which output files can be written to 
- <b>andromedaTempFolder</b>: a directory where temporary files can be written  
- <b>connectionDetails</b>: These are the connection details for the OHDSI DatabaseConnector package   
- <b>cdmDatabaseSchema</b>: This is the name of the schema that contains the OMOP CDM with patient-level data 
- <b>cohortDatabaseSchema</b>: This is the name of the schema where a results table will be created  
- <b>cohortTable</b>: a table that will be created in the results schema (any existing table will be overwritten) 

4. Run covidPhenotypesTest::runPhenoTest


