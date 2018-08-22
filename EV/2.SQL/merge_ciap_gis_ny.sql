-- Run this after you run 'by_zip_acxiom_ny_v1'
-- This merges the GIS data (EV numbers, pop density, population) with the chosen customer demographic data
--      from ACXIOM

create table propensity_input_ny as
select * from ZIP_ACXIOM_DATA_NY t;

select t.key_zip, t.est_income, t.num_adults, t.num_child, t.vehicle_purchase_intent, t.education, t.asn, t.blk, t.wht, t.hisp,
       t.amerind, t.num_cars, t.solar, t.homeval , ny.population/10000, ny.pop_sqmi/1000, ny.tot_ev
       -- population in 10,000 and pop_sqmi in 1000 
       
from ZIP_ACXIOM_DATA_NY t
left join ny_zip_ev ny
on t.key_zip = ny.zip;
