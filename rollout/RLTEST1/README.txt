================================================================================
Extension: RLTEST1                                                    2024-05-28
================================================================================

Issue(s):


Affected Files:
	db/ddl/prerun/20_delete_data.msql
	db/ddl/afterrun/80_integrator_sys_comm.msql
	db/ddl/afterrun/90_Rollout_install_insert.msql


Removed Files:


Release Notes:


================================================================================
               W I N D O W S   I N S T A L L A T I O N   N O T E S             
================================================================================

    1.  Start a Windows command prompt as an Administrator user

    2.  Set Visual C++ environment variables.

        You will first have to change to the Visual C++ bin directory if it 
       isn't in your search path.

        vcvars32.bat

    3.  Set RedPrairie environment variables.

        cd %LESDIR%\data
        ..\moca\bin\servicemgr /env=<environment name> /dump
        env.bat

        Note: If you know your env.bat file is current you can omit this step,
              if you are not sure then rebuild one.

    4.  Shutdown the RedPrairie instance:  

        NON-CLUSTERED Environment

        *** IMPORTANT ***
        If you are on a production system, make sure the development system 
        whose drive has been mapped to the system being modified has also been 
        shutdown to avoid sharing violations.

        net stop moca.<environment name>

        (Or use the Windows Services snap-in to stop the RedPrairie service.

        CLUSTERED Environment
       
        If you are running under a Windows Server Cluster, you must use the
        Microsoft Cluster Administrator to stop the RedPrairie Service.

    5.  Copy the rollout distribution file into the environment's rollout 
        directory.

        cd -d %LESDIR%\rollouts
        copy <SOURCE_DIR>\RLTEST1.zip .

    6.  Uncompress the distribution file using your preferred unzip utility  

        Make sure you extract all the files to a folder called RLTEST1.

    7.  Install the rollout.

        perl -S rollout.pl RLTEST1

    8.  Start up the RedPrairie instance:

        NON-CLUSTERED Environment
       
        net start moca.<environment name>

        (Or use the Windows Services snap-in to restart the RedPrairie service.

        CLUSTERED Environment

        If you are running under a Windows Server Cluster, you must use the
        Microsoft Cluster Administrator to start the RedPrairie Service.


================================================================================
                 U N I X   I N S T A L L A T I O N   N O T E S             
================================================================================

    1.  Login as the Logistics Suite environment's administrator.

        ssh <user>@<hostname>

    2.  Shutdown the RedPrairie instance:

        rp stop
  
    3.  Copy the rollout distribution file into the environment's rollout 
        directory.

        cd /y/Docker/MY-GIT/SWBYDEMO/rollouts
        cp <SOURCE_DIR>//RLTEST1.tar .

    4.  Untar the rollout archive file using tar.

        tar -xvfz RLTEST1.tar 

    5.  Install the rollout.

        perl -S rollout.pl RLTEST1

    6.  Start up the RedPrairie instance:

        rp start

================================================================================
