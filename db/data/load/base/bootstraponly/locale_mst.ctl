[ select count(*) row_count 
    from locale_mst 
   where locale_id = '@locale_id@' 
] 
| 
if (@row_count > 0) 
{
    [ update locale_mst 
         set locale_id = '@locale_id@',          
             ctry_name = '@ctry_name@',          
             ora_lang = '@ora_lang@',          
             ora_terr = '@ora_terr@',          
             ora_nls_sort = '@ora_nls_sort@',          
             win_cli_lcid = to_number('@win_cli_lcid@'),          
             win_srv_lcid = to_number('@win_srv_lcid@'),          
             unix_srv_locale_nam = '@unix_srv_locale_nam@',          
             rf_locale_nam = '@rf_locale_nam@',  
	     mu_sys = '@mu_sys@',        
             grp_nam = '@grp_nam@'
       where locale_id = '@locale_id@' 
     ]
}
else 
{ 
    [ insert into locale_mst 
         (locale_id, ctry_name, ora_lang, 
          ora_terr, ora_nls_sort, win_cli_lcid, 
          win_srv_lcid, unix_srv_locale_nam, 
          rf_locale_nam,mu_sys,grp_nam)
        VALUES
          ('@locale_id@', '@ctry_name@', '@ora_lang@', 
           '@ora_terr@', '@ora_nls_sort@', to_number('@win_cli_lcid@'), 
           to_number('@win_srv_lcid@'), '@unix_srv_locale_nam@', 
           '@rf_locale_nam@', '@mu_sys@', '@grp_nam@') 
    ] 
}
