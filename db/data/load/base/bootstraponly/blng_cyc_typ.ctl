[ select count(*) row_count from blng_cyc_typ where  
    blng_cyc_typ = '@blng_cyc_typ@' ] | if (@row_count > 0) { 
       [ update blng_cyc_typ set 
          blng_cyc_typ = '@blng_cyc_typ@'
,          num_dtl = @num_dtl@
,          dtl_typ = '@dtl_typ@'
             where  blng_cyc_typ = '@blng_cyc_typ@' ] }  
             else { [ insert into blng_cyc_typ 
                      (blng_cyc_typ, num_dtl, dtl_typ) 
                      VALUES 
                      ('@blng_cyc_typ@', @num_dtl@, '@dtl_typ@') ] } 
