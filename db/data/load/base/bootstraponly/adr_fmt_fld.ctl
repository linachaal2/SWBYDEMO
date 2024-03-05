[ select count(*) row_count from adr_fmt_fld where
    adr_fmt = '@adr_fmt@' and adr_line_num = @adr_line_num@ and adr_fld_num = @adr_fld_num@ ] | if (@row_count > 0) {
       [ update adr_fmt_fld set
          adr_fmt = '@adr_fmt@'
,          adr_line_num = @adr_line_num@
,          adr_fld_num = @adr_fld_num@
,          adr_colnam = '@adr_colnam@'
,          adr_const_val = '@adr_const_val@'
,          delta_pos = @delta_pos@
,          grp_nam = '@grp_nam@'
             where  adr_fmt = '@adr_fmt@' and adr_line_num = @adr_line_num@ and adr_fld_num = @adr_fld_num@ ] }
             else { [ insert into adr_fmt_fld
                      (adr_fmt, adr_line_num, adr_fld_num, adr_colnam, adr_const_val, delta_pos, grp_nam)
                      VALUES
                      ('@adr_fmt@', @adr_line_num@, @adr_fld_num@, '@adr_colnam@', '@adr_const_val@', @delta_pos@, '@grp_nam@') ] }
