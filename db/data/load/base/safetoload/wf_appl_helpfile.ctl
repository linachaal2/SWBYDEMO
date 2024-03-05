[update wf_appl
    set help_fil_id = '@help_fil_id@'
  where help_fil_id != '@help_fil_id@'
     or help_fil_id is null]
