select DATEFROMPARTS(YEAR(visit_start_date), MONTH(visit_start_date), 1) as index_month,
	     count(distinct person_id) as count_persons
from @cdm_database_schema.visit_occurrence
where visit_start_date >= datefromparts(2016, 12, 01)
group by DATEFROMPARTS(YEAR(visit_start_date), MONTH(visit_start_date), 1);