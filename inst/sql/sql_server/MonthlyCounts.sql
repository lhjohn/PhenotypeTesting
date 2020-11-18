select cohort_definition_id, 
       cast(dateadd(month,datediff(month,datefromparts(2016, 12, 01),cohort_start_date),datefromparts(2016, 12, 01)) as date) as index_month,
	     count(distinct subject_id) as count_persons
 from @cohort_database_schema.@cohort_table
where cohort_start_date >= datefromparts(2016, 12, 01)
group by cohort_definition_id, cast(dateadd(month,datediff(month,datefromparts(2016, 12, 01),cohort_start_date),datefromparts(2016, 12, 01)) as date);