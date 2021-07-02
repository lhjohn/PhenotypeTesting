with 
cte as (
 select distinct subject_id, cohort_definition_id
 from @cohort_database_schema.@cohort_table
 where @limit_criteria
 ),
cte2 as (
 select subject_id, cast(sum(power(cast(2 as bigint), cohort_definition_id)) as bigint) as combo_id
 from cte
 group by subject_id
 )
select combo_id, count(distinct subject_id) as count_persons
from cte2
group by combo_id;