#!/bin/sh
# run as su - starware
# execute for 4 db's

for databaseName in AMRWMSMD22 NLWWMSMD22 RBGWMSMD22 EELWMSMD22; do
    # do something like: echo $databaseName
    echo "set db $databaseName"
    # or do whatever with individual element of the array
    sed -i 's/databaseName=.*/'databaseName=$databaseName'/g' /by/STWWMSMD/les/data/registry
    echo "executing CCP db actions for $databaseName"
    cd /by/STWWMSMD/les/dtbs/database/
    # db actions for BY2022 RFH CCP 2-5 (1 is included in 2)
    dbupgrade -d moca
    dbupgrade -d reporting
    dbupgrade -d mcs
    # LOADSAFEDATA reporting
    mload_all -US $REPORTINGDIR/db/data/load/base/safetoload/
    mload -H -c $MOCADIR/db/data/load/base/safetoload/moca_dbversion.ctl -D $MOCADIR/db/data/load/base/safetoload/moca_dbversion
    mload -H -c $DCSDIR/db/data/load/base/safetoload/comp_ver.ctl -D $DCSDIR/db/data/load/base/safetoload/comp_ver
    mload -H -c $DCSDIR/db/data/load/base/safetoload/dcs_dbversion.ctl -D $DCSDIR/db/data/load/base/safetoload/dcs_dbversion
    mload -H -c %MCSDIR%/db/data/load/base/safetoload/comp_ver.ctl -D %MCSDIR%/db/data/load/base/safetoload/comp_ver
    mload -H -c %MCSDIR%/db/data/load/base/safetoload/poldat.ctl -D %MCSDIR%/db/data/load/base/safetoload/poldat 
    mload -H -c %MCSDIR%/db/data/load/base/safetoload/mcs_dbversion.ctl -D %MCSDIR%/db/data/load/base/safetoload/mcs_dbversion
    # RELOADVIEWS moca
    # RELOADVIEWS reporting
    # RELOADVIEWS dcs
    # RELOADVIEWS mcs 
    echo "Done for $databaseName"
done

# file needs to be executable
# chmod +x /data/scripts/patches_to_other_dbs.sh