[ select count(*) row_count from dash_mod_def
	where module_id = '@module_id@'] | if (@row_count > 0) {
       [ update dash_mod_def set
          module_id = '@module_id@'
,          module_typ = '@module_typ@'
,          module_width = '@module_width@'
,          module_height = to_number('@module_height@')
,          refresh_sec = to_number('@refresh_sec@')
,          dash_dda_id = '@dash_dda_id@'
,          dda_qual = '@dda_qual@'
,          ws_wsdl = '@ws_wsdl@'
,          ws_service = '@ws_service@'
,          ws_port = '@ws_port@'
,          ws_wsml = '@ws_wsml@'
,          ws_function = '@ws_function@'
,          moca_connect_str = '@moca_connect_str@'
,          custom_subscribe = '@custom_subscribe@'
,          custom_unsubscribe = '@custom_unsubscribe@'
,          multi_flg = '@multi_flg@'
,          grp_nam = '@grp_nam@'
             where  module_id = '@module_id@'] }
             else { [ insert into dash_mod_def
                      (module_id, module_typ, module_width, module_height, refresh_sec, dash_dda_id, dda_qual, ws_wsdl, ws_service, ws_port, ws_wsml, ws_function, moca_connect_str, custom_subscribe, custom_unsubscribe, multi_flg, grp_nam)
                      VALUES
                      ('@module_id@', '@module_typ@', '@module_width@', to_number('@module_height@'), to_number('@refresh_sec@'), '@dash_dda_id@', '@dda_qual@', '@ws_wsdl@', '@ws_service@', '@ws_port@', '@ws_wsml@', '@ws_function@', '@moca_connect_str@', '@custom_subscribe@', '@custom_unsubscribe@', '@multi_flg@', '@grp_nam@')]}
