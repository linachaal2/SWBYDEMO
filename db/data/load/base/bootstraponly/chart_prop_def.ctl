[ select count(*) row_count from chart_prop_def where
    graph_type = @graph_type@ and var_nam = '@var_nam@' ] 
| 
  if (@row_count > 0) 
  {
       [ update chart_prop_def set
          graph_type = @graph_type@
,          var_nam = '@var_nam@'
,          posn = @posn@
,          category_id = '@category_id@'
,          chart_usage = '@chart_usage@'
,          grp_nam = '@grp_nam@'
             where  graph_type = @graph_type@ and var_nam = '@var_nam@' ] 
  }
  else 
  { 
       [ insert into chart_prop_def
                      (graph_type, var_nam, posn, category_id, chart_usage, grp_nam)
                      VALUES
                      (@graph_type@, '@var_nam@', @posn@, '@category_id@', '@chart_usage@', '@grp_nam@') ] 
  }
