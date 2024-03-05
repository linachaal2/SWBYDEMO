[ select count(*) row_count from les_ath_pmsn where
    pmsn_id = '@pmsn_id@' ] | if (@row_count > 0) {
       [ update les_ath_pmsn set
          pmsn_id = '@pmsn_id@'
,          bit_pos = @bit_pos@
,          grp_nam = '@grp_nam@'
             where  pmsn_id = '@pmsn_id@' ] }
             else { [ insert into les_ath_pmsn
                      (pmsn_id, bit_pos, grp_nam)
                      VALUES
                      ('@pmsn_id@', @bit_pos@, '@grp_nam@') ] }
