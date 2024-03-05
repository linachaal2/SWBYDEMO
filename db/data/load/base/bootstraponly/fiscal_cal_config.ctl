[Select count(*) row_count from fiscal_cal_config
   where fiscal_year = '@fiscal_year@' and fiscal_month = '@fiscal_month@' and fiscal_week = '@fiscal_week@'] 
|
if(@row_count > 0)
{
   [ update fiscal_cal_config 
           set
	     fiscal_year = '@fiscal_year@',          
	     fiscal_month = '@fiscal_month@',        
	     fiscal_week = '@fiscal_week@',
	     start_dt = to_date('@start_dt@'),
	     end_dt = to_date('@end_dt@')
           where fiscal_year = '@fiscal_year@' and fiscal_month = '@fiscal_month@' and fiscal_week = '@fiscal_week@'] 
}
else
{
   [ insert into fiscal_cal_config
               (fiscal_year, fiscal_month, fiscal_week,start_dt,end_dt)
            VALUES
               ('@fiscal_year@','@fiscal_month@' , '@fiscal_week@',to_date('@start_dt@'),to_date('@end_dt@')) 
       ] 
}
|
if (@fiscal_week@ >= 52)
{
   generate fiscal calendar where fiscal_year = '@fiscal_year@'
}

   
