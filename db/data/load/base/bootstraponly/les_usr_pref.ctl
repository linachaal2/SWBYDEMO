[ select count(*) row_count from les_usr_pref where
    usr_id = '@usr_id@' and pref_id = '@pref_id@' ] | if (@row_count > 0) {
       [ update les_usr_pref set
          usr_id = '@usr_id@'
,          pref_id = '@pref_id@'
,          pref_val = '@pref_val@'
,          grp_nam = '@grp_nam@'
             where  usr_id = '@usr_id@' and pref_id = '@pref_id@' ] }
             else { [ insert into les_usr_pref
                      (usr_id, pref_id, pref_val, grp_nam)
                      VALUES
                      ('@usr_id@', '@pref_id@', '@pref_val@', '@grp_nam@') ] }
