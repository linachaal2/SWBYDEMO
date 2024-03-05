[ select count(*) row_count 
  from blng_serv_typ 
  where blng_serv_typ = '@blng_serv_typ@' ] 
    | if (@row_count > 0) 
      { 
          [ update blng_serv_typ 
            set blng_serv_typ = '@blng_serv_typ@',
                blng_chrg_typ = '@blng_chrg_typ@'
            where  blng_serv_typ = '@blng_serv_typ@' ] 
      }  
      else 
      {
        [ insert into blng_serv_typ 
                      (blng_serv_typ, blng_chrg_typ) 
                VALUES 
                      ('@blng_serv_typ@', '@blng_chrg_typ@')]
      } 
