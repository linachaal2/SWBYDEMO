[ select count(*) row_count from dash_tab_mod_config
	where mod_config_id = '@mod_config_id@'
	  and tab_id = '@tab_id@']
| 
if (@row_count > 0) 
{
       [ update dash_tab_mod_config set
	   module_id = '@module_id@',
	   srtseq = to_number('@srtseq@'),
	   dda_qual = '@dda_qual@',
	   refresh_sec = to_number('@refresh_sec@'),
	   description = '@description@',
	   ctrl_dt = sysdate,
           grp_nam = '@grp_nam@'
          
	  where mod_config_id = '@mod_config_id@'
	  and tab_id = '@tab_id@']
}
else
{ 
	[ insert into dash_tab_mod_config 
		       (
			mod_config_id, 
			tab_id, 
			module_id,
			srtseq,
			dda_qual,
			refresh_sec,
			description,
			ctrl_dt,
			grp_nam
		       )
            VALUES    (
			'@mod_config_id@',
			'@tab_id@',
			'@module_id@',
			to_number('@srtseq@'),
			'@dda_qual@',
			to_number('@refresh_sec@'),
			'@description@', 
			sysdate,
			'@grp_nam@'
			)
	]
}
