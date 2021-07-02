select cohort_definition_id, 
       DATEFROMPARTS(YEAR(cohort_start_date), MONTH(cohort_start_date), 1) as index_month,
	     count(distinct subject_id) as count_persons
from @cohort_database_schema.@cohort_table
where cohort_start_date >= datefromparts(2016, 12, 01)
and @limit_criteria
group by cohort_definition_id, DATEFROMPARTS(YEAR(cohort_start_date), MONTH(cohort_start_date), 1);