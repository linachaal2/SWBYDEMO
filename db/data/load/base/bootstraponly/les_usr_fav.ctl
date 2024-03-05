[ select count(*) row_count from les_usr_fav where
    usr_id = '@usr_id@' and opt_nam = '@opt_nam@' ] | if (@row_count > 0) {
       [ update les_usr_fav set
          usr_id = '@usr_id@'
,          opt_nam = '@opt_nam@'
,          mnu_seq = @mnu_seq@
,          grp_nam = '@grp_nam@'
             where  usr_id = '@usr_id@' and opt_nam = '@opt_nam@' ] }
             else { [ insert into les_usr_fav
                      (usr_id, opt_nam, mnu_seq, grp_nam)
                      VALUES
                      ('@usr_id@', '@opt_nam@', @mnu_seq@, '@grp_nam@') ] }
