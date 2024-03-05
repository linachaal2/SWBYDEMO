save session variable where name = "skip_it" and value =  0 |
save session variable where name = "err" and value = 0 |
publish data 
    where data = '@prtnum@' || ',' || '@prt_client_id@' || ',' ||
                 '@ftpcod@' || ',' ||
                 '@untcas@' || ',' || '@untpak@' || ',' ||
                 '@invsts@' || ',' || '@untqty@' || ',' || 
                 '@catch_qty@' || ',' || 
                 '@orgcod@' || ',' || '@revlvl@' || ',' || 
                 '@lotnum@' || ',' || '@dstloc@' || ',' || 
                 '@dstlod@' || ',' || '@usr_id@' || ',' || 
                 '@movref@' || ',' || '@mandte@' || ',' ||
                 '@srcloc@' |
if ('@invsts@' = '')
{
    /* Can't create inventory without an inventory status */
    save session variable where name = "skip_it" and value =  1 |
    save session variable 
      where name = "errmsg" 
        and value = 'Missing Inventory Status' |
    save session variable where name = 'err' and value = '2005' 
}
|
if ('@prtnum@' = '')
{
    save session variable where name = "skip_it" and value =  1 |
    save session variable 
      where name = "errmsg" 
        and value = 'Missing Part Number' |
    save session variable where name = 'err' and value = '2005' 
}
|
if ('@untqty@' = '')
{
    save session variable where name = "skip_it" and value =  1 |
    save session variable 
      where name = "errmsg" 
        and value = 'Missing Unit Quantity' |
    save session variable where name = 'err' and value = '2005' 
}
|
if ('@untcas@' = '')
{
    /* Try to get untcas from part since it wasn't specified */

    get installed configuration where config = '3PL' |
    if (@installed = 0)
    {
        [select max(untcas) untcas
           from prtmst
          where prtnum = '@prtnum@' ]
    }
    else
    {
        [select untcas
           from prtmst
        where prtnum = '@prtnum@'
          and prt_client_id = '@prt_client_id@']
    }
    |
    if (@untcas = '')
    {
        save session variable where name = "skip_it" and value =  1 |
        save session variable 
          where name = "errmsg" 
            and value = 'Missing Units Per Case' |
        save session variable where name = 'err' and value = '2005' 
    }
    |
    save session variable where name = 'untcas' and value = @untcas
}
|
/* If untcas wasn't passed, and we got this far, we have it on the stack.*/
get session variable where name = 'untcas' catch (@?) |
publish data where untcas = @value |
/* Determine if we should create the inventory */
get session variable where name = 'skip_it' |
publish data where skip_it = @value |
if (@skip_it = 0)
{
    create inventory
    where prtnum = '@prtnum@'
      and prt_client_id = '@prt_client_id@'
      and ftpcod = '@ftpcod@'
      and untcas = nvl('@untcas@', @untcas)
      and untpak = '@untpak@'
      and invsts = '@invsts@'
      and untqty = '@untqty@'
      and catch_qty = '@catch_qty@'
      and orgcod = '@orgcod@'
      and revlvl = '@revlvl@' 
      and lotnum = '@lotnum@'
      and dstloc = '@dstloc@'
      and lodnum = '@dstlod@'
      and usr_id = '@usr_id@'
      and movref = '@movref@'
      and mandte = @mandte
      and adddte = sysdate
      and srcloc = '@srcloc@' catch(@?) |
    if (@? != 0)
    {
        save session variable where name = 'err' and value = @? 
    }
}
|
get session variable where name = 'err' |
publish data where errid = @value |
if (@errid != 0)
{
    get session variable where name = 'errmsg' catch (@?) |
    publish data where msg = @value |
    if (@msg = '')
    {
        get mls text 
        where mlsid = 'err' || @errid 
          and locale_id = @@locale_id catch (@?) |
        publish data where msg = @mls_text
    }
    |
    write output file 
     where filnam  = 'createInventory.log'
       and data    = '' || @data || @errid || ' ' || @msg
       and newline = 'Y'
       and mode    = 'A'
       and path    = '$LESDIR/log'
}

