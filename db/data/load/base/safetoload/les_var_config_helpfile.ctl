[update les_var_config
    set help_fil_id = '@help_fil_id@'
  where help_fil_id != '@help_fil_id@'
     or help_fil_id is null]
