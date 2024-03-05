================================================================================
Extension: <ROLLOUT_NAME> <ROLLOUT_DATE>
================================================================================

Issue(s): 
<ROLLOUT_ISSUES>

Affected Files:

Removed Files:

Release Notes:
<ROLLOUT_RELEASE_NOTES>

================================================================================
               W I N D O W S   I N S T A L L A T I O N   N O T E S             
================================================================================

    1.  Start a Windows command prompt as an Administrator user

    2.  Set Visual C++ environment variables.

        You will first have to change to the Visual C++ bin directory if it 
        isn't in your search path.

        vcvars32.bat
		
		Note: If you will not be building the binaries on the server you can
		      omit this step.

    3.  Set JDA environment variables.

        cd %LESDIR%\data
        ..\moca\bin\servicemgr /env=<environment name> /dump
        env.bat

        Note: If you know your env.bat file is current you can omit this step,
              if you are not sure then rebuild one.

    4.  Shutdown the JDA instance:  

        NON-CLUSTERED Environment

        *** IMPORTANT ***
        If you are on a production system, make sure the development system 
        whose drive has been mapped to the system being modified has also been 
        shutdown to avoid sharing violations.

        net stop moca.<environment name>

        (Or use the Windows Services snap-in to stop the JDA service.

        CLUSTERED Environment
       
        If you are running under a Windows Server Cluster, you must use the
        Microsoft Cluster Administrator to stop the JDA Service.

    5.  Copy the rollout distribution file into the environment's rollout 
        directory.

        cd -d %LESDIR%\rollouts
        copy <SOURCE_DIR>\<ROLLOUT_NAME>.zip .

    6.  Uncompress the distribution file using your preferred unzip utility  

        Make sure you extract all the files to a folder called <ROLLOUT_NAME>.

    7.  Install the rollout.

        perl -S rollout.pl <ROLLOUT_NAME>
    8.  Start up the JDA instance:

        NON-CLUSTERED Environment
       
        net start moca.<environment name>

        (Or use the Windows Services snap-in to restart the JDA service.

        CLUSTERED Environment

        If you are running under a Windows Server Cluster, you must use the
        Microsoft Cluster Administrator to start the JDA Service.


================================================================================
                 U N I X   I N S T A L L A T I O N   N O T E S             
================================================================================

    1.  Login as the Logistics Suite environment's administrator.

        ssh <user>@<hostname>

    2.  Shutdown the JDA instance:

        rp stop
  
    3.  Copy the rollout distribution file into the environment's rollout 
        directory.

        cd $LESDIR/rollouts
        cp <SOURCE_DIR>/<ROLLOUT_NAME>.tar.gz .

    4.  Uncompress and untar the rollout archive file using tar.

        tar -xvfz <ROLLOUT_NAME>.tar.gz 

    5.  Install the rollout.

        perl -S rollout.pl <ROLLOUT_NAME>
    6.  Start up the JDA instance:

        rp start

================================================================================

