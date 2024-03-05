[ select count(*) row_count from prop_frm where
    frm_id = '@frm_id@' and var_nam = '@var_nam@' ] | if (@row_count > 0) {
       [ update prop_frm set
          frm_id = '@frm_id@'
,          var_nam = '@var_nam@'
,          grp_nam = '@grp_nam@'
             where  frm_id = '@frm_id@' and var_nam = '@var_nam@' ] }
             else { [ insert into prop_frm
                      (frm_id, var_nam, grp_nam)
                      VALUES
                      ('@frm_id@', '@var_nam@', '@grp_nam@') ] }
