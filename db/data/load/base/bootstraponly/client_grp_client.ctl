[ select count(*) row_count 
    from client_grp_client 
   where client_grp = '@client_grp@' 
     and client_id = '@client_id@' ] | 
if (@row_count > 0) 
{
    [ update client_grp_client set
          client_grp = '@client_grp@',
          client_id = '@client_id@',
          u_version = to_number('@u_version@'),
          ins_dt = to_date('@ins_dt@','YYYYMMDDHH24MISS'),
          last_upd_dt = to_date('@last_upd_dt@','YYYYMMDDHH24MISS'),
          ins_user_id = '@ins_user_id@',
          last_upd_user_id = '@last_upd_user_id@'
       where  client_grp = '@client_grp@' and client_id = '@client_id@' ] 
}
else 
{ 
    [ insert into client_grp_client
                      (client_grp, client_id, u_version, ins_dt, last_upd_dt, ins_user_id, last_upd_user_id)
                      VALUES
                      ('@client_grp@', '@client_id@', to_number('@u_version@'), to_date('@ins_dt@','YYYYMMDDHH24MISS'), to_date('@last_upd_dt@','YYYYMMDDHH24MISS'), '@ins_user_id@', '@last_upd_user_id@') ] 
}
