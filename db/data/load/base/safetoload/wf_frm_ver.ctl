[update wf_frm
    set frm_file_nam = '@frm_file_nam@',
        frm_file_ver = '@frm_file_ver@'
  where frm_progid   = '@frm_progid@'
        and cust_lvl     = 0 ]

