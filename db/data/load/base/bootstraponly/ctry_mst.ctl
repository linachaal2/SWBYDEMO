[ select count(*) row_count 
    from ctry_mst 
   where ctry_name = '@ctry_name@' 
] 
| 
if (@row_count > 0) 
{
    [ update ctry_mst 
         set ctry_name = '@ctry_name@',          
             iso_2_ctry_name = '@iso_2_ctry_name@',          
             iso_3_ctry_name = '@iso_3_ctry_name@',          
             iso_ctry_num = '@iso_ctry_num@',          
             adr_fmt = '@adr_fmt@',          
             dom_ld_acc_cd = '@dom_ld_acc_cd@',          
             intl_acc_cd = '@intl_acc_cd@',          
             ctry_phone_cd = '@ctry_phone_cd@',
             cs_ctry_name = '@cs_ctry_name@',
             zip_cod_len = '@zip_cod_len@',
             dty_ctry_typ = '@dty_ctry_typ@',
             grp_nam = '@grp_nam@'
       where ctry_name = '@ctry_name@' 
     ] 
}
else 
{ 
     [ insert into ctry_mst
              (ctry_name, iso_2_ctry_name, iso_3_ctry_name, 
               iso_ctry_num, adr_fmt, dom_ld_acc_cd, 
               intl_acc_cd, ctry_phone_cd, cs_ctry_name,
               zip_cod_len, dty_ctry_typ, grp_nam)
        VALUES
              ('@ctry_name@', '@iso_2_ctry_name@', '@iso_3_ctry_name@', 
               '@iso_ctry_num@', '@adr_fmt@', '@dom_ld_acc_cd@', 
               '@intl_acc_cd@', '@ctry_phone_cd@', '@cs_ctry_name@', 
               '@zip_cod_len@', '@dty_ctry_typ@', '@grp_nam@') 
     ]
}
