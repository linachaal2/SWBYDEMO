[ select count(*) row_count from cst_billto_acct where
    cstnum = '@cstnum@' and client_id = '@client_id@' and carcod = '@carcod@' ] | if (@row_count > 0) {
       [ update cst_billto_acct set
          cstnum = '@cstnum@'
,          client_id = '@client_id@'
,          carcod = '@carcod@'
,          accnum = '@accnum@'
,          ins_dt = to_date('@ins_dt@','YYYYMMDDHH24MISS')
,          last_upd_dt = to_date('@last_upd_dt@','YYYYMMDDHH24MISS')
,          ins_user_id = '@ins_user_id@'
,          last_upd_user_id = '@last_upd_user_id@'
             where  cstnum = '@cstnum@' and client_id = '@client_id@' and carcod = '@carcod@' ] }
             else { [ insert into cst_billto_acct
                      (cstnum, client_id, carcod, accnum, ins_dt, last_upd_dt, ins_user_id, last_upd_user_id)
                      VALUES
                      ('@cstnum@', '@client_id@', '@carcod@', '@accnum@', to_date('@ins_dt@','YYYYMMDDHH24MISS'), to_date('@last_upd_dt@','YYYYMMDDHH24MISS'), '@ins_user_id@', '@last_upd_user_id@') ] }
