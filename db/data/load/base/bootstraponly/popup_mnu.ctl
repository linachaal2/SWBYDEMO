[ select count(*) row_count from popup_mnu where
    mnu_id = '@mnu_id@' and item_id = '@item_id@' and par_item_id = '@par_item_id@' ] | if (@row_count > 0) {
       [ update popup_mnu set
          mnu_id = '@mnu_id@'
,          item_id = '@item_id@'
,          par_item_id = '@par_item_id@'
,          mls_id = '@mls_id@'
,          type = @type@
,          posn = @posn@
,          func = '@func@'
,          parms = '@parms@'
,          event = '@event@'
,          pmsns = @pmsns@
,          grp_nam = '@grp_nam@'
             where  mnu_id = '@mnu_id@' and item_id = '@item_id@' and par_item_id = '@par_item_id@' ] }
             else { [ insert into popup_mnu
                      (mnu_id, item_id, par_item_id, mls_id, type, posn, func, parms, event, pmsns, grp_nam)
                      VALUES
                      ('@mnu_id@', '@item_id@', '@par_item_id@', '@mls_id@', @type@, @posn@, '@func@', '@parms@', '@event@', @pmsns@, '@grp_nam@') ] }
