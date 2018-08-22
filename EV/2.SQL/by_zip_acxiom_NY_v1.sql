-- Pull relevant data from AXCIOM to find relationship between customer data and EV Growth
-- Currently only a single state has been hardcoded in --> NY

-- pull general income data from axciom_2 and create view
--         1 = Less than $15,000
--         2 = $15,000 - $19,999
--         3 = $20,000 - $29,999
--         4 = $30,000 - $39,999
--				 5 = $40,000 - $49,999
--				 6 = $50,000 - $74,999
--				 7 = $75,000 - $99,999
--				 8 = $100,000 - $124,999
--				 9 = Greater than $124,999
drop view temp_income;
create view temp_income as
select key_zip, avg(V8641) as est_income 
from acxiom_a_b
where adr_std_state = 'NY'
group by  key_zip ;

-- pull number of adults in the household and create view
drop view temp_adults;
create view temp_adults as
   select key_zip, avg(V8628) as num_adults
   from acxiom_a_b
   where adr_std_state = 'NY'
   group by  key_zip ;

-- pull number of children in the household and create view
drop view temp_child;
create view temp_child as
select key_zip, avg(v8602) as num_child
from acxiom_a_b
where adr_std_state = 'NY'
group by  key_zip ;

-- pull the technology adopton propensity score and create view
--          Y = 1
--          N = 0
drop view temp_intent;
create view temp_intent as
select key_zip, avg(case when V7475 = 'Y' then 1 else 0 end) as vehicle_purchase_intent
from acxiom_a_b
where adr_std_state = 'NY'
group by key_zip;

-- pull the education level of the individual's name appearing on the customer's input file
--          1=Completed HS                    Changed to:
--          2=Completed College -->               3
--          3=Completed Grad School -->           4
--          4=Attended Vocational/Technical -->   2

drop view temp_education_revised;
create view temp_education_revised as
select key_individual_id, key_zip, adr_std_state,
       case when V9514 = 1 then 1 else
         case when V9514 = 2 then 3 else
           case when V9514 = 3 then 4 else
             case when V9514 =4 then 2
             end
           end
         end
       end as education
from acxiom_a_b   
group by key_individual_id, key_zip,adr_std_state, V9514;   


drop view temp_education;
create view temp_education as
select key_zip, avg(education) as education
from temp_education_revised
where adr_std_state = 'NY'
group by key_zip;

-- pull the ethnicity
--          A=Asian B=African American C=Chinese H=Hispanic I=American Indian J=Japanese P=Portugese W=White
--          The numbers are in thousands
drop view temp_ethnicity;
create view temp_ethnicity as
select key_zip, sum(case when V2100= 'A' or V2100='C' or V2100='J' then 1 else 0 end)/1000 as asn, sum(case when V2100= 'B' then 1 else 0 end)/1000 as BLK,
sum(case when V2100= 'H' then 1 else 0 end)/1000 as HISP, sum(case when V2100= 'W' then 1 else 0 end)/1000 as WHT,
sum(case when V2100= 'I' then 1 else 0 end)/1000 as AmerInd
from acxiom_a_b
where adr_std_state = 'NY'
group by key_zip;

-- pull number of existing cars
--            1 = 1 car, 2 = 2 cars, 3 = 3 or more cars
drop view temp_numcars;
create view temp_numcars as
select key_zip, avg(V8647) as num_cars
from acxiom_a_b
where adr_std_state = 'NY'
group by key_zip;

-- pull existence of solar heating panels
--            value = 6 indicates solar
drop view temp_solar;
create view temp_solar as
select key_zip, sum(case when V8560 = 6 then 1 else 0 end) as solar
from acxiom_a_b
where adr_std_state = 'NY'
group by key_zip;

-- pull home values
--           actual home prices in 100 thousand dollars, i.e., $200,000 --> 2
drop view temp_homeval;
create view temp_homeval as
select key_zip, avg(V8713)/100000 as homeval
from acxiom_a_b
where adr_std_state = 'NY'
group by key_zip;

-- combine all the views created and join to a single view: temp_all
--drop view temp_all;
create view temp_all_ny as
select ti.key_zip, ti.est_income, ta.num_adults, tc.num_child, tint.vehicle_purchase_intent, ted.education, eth.asn,
       eth.blk, eth.hisp, eth.wht, eth.amerind, car.num_cars, sol.solar, hval.homeval
from temp_income ti
inner join temp_adults ta
on ti.key_zip = ta.key_zip
inner join temp_child tc
on ti.key_zip = tc.key_zip
inner join temp_intent tint
on ti.key_zip = tint.key_zip 
inner join temp_education ted
on ti.key_zip = ted.key_zip
inner join temp_ethnicity eth
on ti.key_zip = eth.key_zip
inner join temp_numcars car
on ti.key_zip = car.key_zip
inner join temp_solar sol
on ti.key_zip = sol.key_zip
inner join temp_homeval hval
on ti.key_zip = hval.key_zip
;

-- print the combined view
select * from temp_all_ny;

-- store temp_all to a table
drop zip_acxiom_data_ny;
create table zip_acxiom_data_NY as
select * from temp_all_ny;

-- drop all the tables
drop view temp_income;
drop view temp_adults;
drop view temp_child;
drop view temp_intent;
drop view temp_education;
drop view temp_ethnicity;
drop view temp_numcars;
drop view temp_solar;
drop view temp_homeval;
drop view temp_all;
