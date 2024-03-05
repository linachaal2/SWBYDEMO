[ select count(*) row_count 
    from client_grp 
   where client_grp = '@client_grp@' ] | 
if (@row_count > 0) 
{
    [ update client_grp set
          client_grp = '@client_grp@',
          u_version = to_number('@u_version@'),
          ins_dt = to_date('@ins_dt@','YYYYMMDDHH24MISS'),
          last_upd_dt = to_date('@last_upd_dt@','YYYYMMDDHH24MISS'),
          ins_user_id = '@ins_user_id@',
          last_upd_user_id = '@last_upd_user_id@'
       where  client_grp = '@client_grp@' ] 
}
else 
{ 
    [ insert into client_grp
                      (client_grp, u_version, ins_dt, last_upd_dt, ins_user_id, last_upd_user_id)
                      VALUES
                      ('@client_grp@', to_number('@u_version@'), to_date('@ins_dt@','YYYYMMDDHH24MISS'), to_date('@last_upd_dt@','YYYYMMDDHH24MISS'), '@ins_user_id@', '@last_upd_user_id@') ] 
}
