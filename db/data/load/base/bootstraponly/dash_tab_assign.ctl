[ select count(*) row_count from dash_tab_assign
	where tab_id = '@tab_id@'
	  and ath_id = '@ath_id@'
	  and ath_typ = '@ath_typ@'] 
| 
if (@row_count > 0) 
{
       [ update dash_tab_assign set
	   srtseq = to_number('@srtseq@'),
	   description = '@description@',
           grp_nam = '@grp_nam@'
          
	  where tab_id = '@tab_id@'
	  and ath_id = '@ath_id@'
	  and ath_typ = '@ath_typ@'] 
}
else
{ 
	[ insert into dash_tab_assign (tab_id, ath_id, ath_typ, srtseq, description, grp_nam)
                      VALUES    ('@tab_id@', '@ath_id@', '@ath_typ@', to_number('@srtseq@'), '@description@', '@grp_nam@')]
}
