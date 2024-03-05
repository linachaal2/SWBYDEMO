[ select count(*) row_count from dash_tabs
	where tab_id = '@tab_id@'] 
| 
if (@row_count > 0) 
{
       [ update dash_tabs set
           template_flg = to_number('@template_flg@'),
           grp_nam = '@grp_nam@'
          where tab_id = '@tab_id@'] 
}
else
{ 
	[ insert into dash_tabs (tab_id, template_flg, grp_nam)
                      VALUES    ('@tab_id@', to_number('@template_flg@'), '@grp_nam@')]
}
