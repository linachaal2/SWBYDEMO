[ select count(*) row_count from chart_mst where
    chart_id = '@chart_id@' and cust_lvl = @cust_lvl@ ] 
| 
  if (@row_count > 0) 
  {
       [ update chart_mst set
          chart_id = '@chart_id@'
,          cust_lvl = @cust_lvl@
,          graph_type = @graph_type@
,          x_axis = '@x_axis@'
,          y_series = '@y_series@'
,          title_pos = @title_pos@
,          legend_pos = @legend_pos@
,          grp_nam = '@grp_nam@'
             where  chart_id = '@chart_id@' and cust_lvl = @cust_lvl@ ] 
  }
  else 
  { 
      [ insert into chart_mst
                      (chart_id, cust_lvl, graph_type, x_axis, y_series, title_pos, legend_pos, grp_nam)
                      VALUES
                      ('@chart_id@', @cust_lvl@, @graph_type@, '@x_axis@', '@y_series@', @title_pos@, @legend_pos@, '@grp_nam@') ] 
  }
