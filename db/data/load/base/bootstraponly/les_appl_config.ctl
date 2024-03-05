[ select count(*) row_count from les_appl_config where
    user_id = '@user_id@' and locale_id = '@locale_id@' and appl_id = '@appl_id@' and frm_id = '@frm_id@' and ctl_nam = '@ctl_nam@' and prf_lbl = '@prf_lbl@' ] | if (@row_count > 0) {
       [ update les_appl_config set
          user_id = '@user_id@'
,          locale_id = '@locale_id@'
,          appl_id = '@appl_id@'
,          frm_id = '@frm_id@'
,          ctl_nam = '@ctl_nam@'
,          prf_lbl = '@prf_lbl@'
,          srt_seq = '@srt_seq@'
,          prf_num = to_number('@prf_num@')
,          prf_str = '@prf_str@'
,          grp_nam = '@grp_nam@'
             where  user_id = '@user_id@' and locale_id = '@locale_id@' and appl_id = '@appl_id@' and frm_id = '@frm_id@' and ctl_nam = '@ctl_nam@' and prf_lbl = '@prf_lbl@' ] }
             else { [ insert into les_appl_config
                      (user_id, locale_id, appl_id, frm_id, ctl_nam, prf_lbl, srt_seq, prf_num, prf_str, grp_nam)
                      VALUES
                      ('@user_id@', '@locale_id@', '@appl_id@', '@frm_id@', '@ctl_nam@', '@prf_lbl@', '@srt_seq@', to_number('@prf_num@'), '@prf_str@', '@grp_nam@') ] }
