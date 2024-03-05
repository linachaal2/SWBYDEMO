[ select count(*) row_count from chart_prop where
    chart_id = '@chart_id@' and cust_lvl = @cust_lvl@ and var_nam = '@var_nam@' ] 
| 
  if (@row_count > 0) 
  {
       [ update chart_prop set
          chart_id = '@chart_id@'
,          cust_lvl = @cust_lvl@
,          var_nam = '@var_nam@'
,          chart_prop_val = '@chart_prop_val@'
,          grp_nam = '@grp_nam@'
             where  chart_id = '@chart_id@' and cust_lvl = @cust_lvl@ and var_nam = '@var_nam@' ] 
  }
  else 
  { 
        [ insert into chart_prop
                      (chart_id, cust_lvl, var_nam, chart_prop_val, grp_nam)
                      VALUES
                      ('@chart_id@', @cust_lvl@, '@var_nam@', '@chart_prop_val@', '@grp_nam@') ] 
  }
