[ select count(*) row_count
    from wh 
   where wh_id = '@wh_id@' ] 
   
  | 
  
  if (@row_count > 0) 
  { 
      [ update wh 
           set wh_id = '@wh_id@',
               adr_id = '@adr_id@',
               def_wh_flg = to_number('@def_wh_flg@'),
               wh_typ_cd = '@wh_typ_cd@',
               lens_sitnam = '@lens_sitnam@',
               lens_customer_id = '@lens_customer_id@',
               lens_cust_client_id = '@lens_cust_client_id@',
               lens_ena_flg = to_number('@lens_ena_flg@'),
               mod_usr_id = '@mod_usr_id@',
               moddte = to_date('@moddte@','YYYYMMDDHH24MISS')
         where wh_id = '@wh_id@' ] 
  }  
  else 
  { 
      [ insert into wh 
          (wh_id, adr_id, def_wh_flg, wh_typ_cd, lens_sitnam, lens_customer_id, lens_cust_client_id, lens_ena_flg, mod_usr_id, moddte) 
        values 
          ('@wh_id@', '@adr_id@', to_number('@def_wh_flg@'), '@wh_typ_cd@', '@lens_sitnam@', '@lens_customer_id@','@lens_cust_client_id@', to_number('@lens_ena_flg@'), '@mod_usr_id@',  to_date('@moddte@','YYYYMMDDHH24MISS'))  ]
  } 
