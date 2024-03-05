if ('@allw_ovrd_flg@' != '')
{
    publish data where allw_ovrd_flg = '@allw_ovrd_flg@'
}
else
{
    publish data where allw_ovrd_flg = '1'
}
|
[select count(*) cnt
  from pol_inf 
 where pol_id = '@pol_id@' ]
|
if (@cnt > 0)
{
    change policy information 
     where pol_id = '@pol_id@'
       and polcod = '@polcod@'
       and polvar = '@polvar@'
       and polval = '@polval@' 
       and srtseq=  '@srtseq@'
       and alw_mult =  '@alw_mult@'
       and alw_del=  '@alw_del@'
       and ena_flg=  '@ena_flg@'
       and cmnt = "@cmnt@"
       and help_id = '@help_id@'
       and help_fil_id = '@help_fil_id@'
       and grp_nam = '@grp_nam@' 
       and allw_ovrd_flg = @allw_ovrd_flg
}
else
{
    create policy information 
     where pol_id = '@pol_id@'
       and polcod = '@polcod@'
       and polvar = '@polvar@'
       and polval = '@polval@' 
       and srtseq=  '@srtseq@'
       and alw_mult =  '@alw_mult@'
       and alw_del=  '@alw_del@'
       and ena_flg=  '@ena_flg@'
       and cmnt = "@cmnt@"
       and help_id = '@help_id@'
       and help_fil_id = '@help_fil_id@'
       and grp_nam = '@grp_nam@'
       and allw_ovrd_flg = @allw_ovrd_flg
}
|
If (!'@srtseq@')
{
    change policy information
     where pol_id = '@pol_id@'
       and clr_srtseq = 1
}
