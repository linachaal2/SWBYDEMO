#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper qw(Dumper);
use Getopt::Std;
use lib "./scripts";
use Cwd;
use File::Path;
use Text::ParseWords;
use IPC::Open2;
use File::Basename;
use File::Copy;
use File::Find;
use Time::localtime;

my %opts = ();
my $lesdir =  "/y/Docker/MY-GIT/SWBYDEMO";
my $ro_dir;
my $ro;
my $logfile;
my $detailed_output;
my $ro_name;
my $force_delete;
my $ro_dir_parm;
my $logfile_parm;
my $detailed_output_parm ="";
my $ro_name_parm;
my $pack;
my $build_script;
my $orig_dir;
my $warning_text = "WARNINGS EXIST:\n";
my $warnings_exist = 0;
my $error_text = "ERRORS EXIST:\n";
my $errors_exist = 0;
my $readme;
my $build_readme;
my $readme_parm;
my $issue_text = "Issue(s):\n";
my $notes_text = "Release Notes:\n";
my $component_text = "Affected Files:\n";
my $remove_text = "Removed Files:\n";
my $remove_ro_text = "# Removing files removed by extension.\n";
my $log = "";
my $vOutputFile;
#####################################################################
# show usage()
#####################################################################
#perl createRolloutPackage.pl -n RLTEST1 -d rollout -r inputFile.txt -f -l test1.log
sub show_usage {
  die "Correct usage for $0 is as follows:\n"   
        . "$0\n"
        . "\t-n <Rollout Name>\n"
        . "\t-d <Rollout Directory - path from \$lesdir where the rollout package will be created>\n"
        . "\t-r <Rollout Input File>\n"
        . "\t-f <Force delete of package if it already exists>\n"
        . "\t-p <create the rollout script and package this to a tar file after pulling all components>\n"
        . "\t-b <create the rollout script>\n"
        . "\t-m <create a readme file>\n"
        . "\t-l <Log File - file will be written to LESDIR/log directory>\n"
        . "\t-o show detailed output\n"
        . "\t-h <Help - this screen>\n";
}#show_usage
#####################################################################
# write_log()
#
# simply writes the $log parameter that we have been writing to during 
# processing to the $logfile file
#####################################################################
sub write_log{
	if($logfile)
	{
		if($detailed_output){printf("Writing to log file $lesdir/log/$logfile\n\n");}
		$log = $log . "Writing to log file $lesdir/log/$logfile\n\n";

		open(OUTLOG, ">>$lesdir/log/$logfile");
		print OUTLOG $log;
		close(OUTLOG);
		$log = "";
	}
}#write_log
#####################################################################
# create_ro_dir($fulldir)
#	$fulldir - this is the full directory path for the directory to
#				be created.
#
# this function will create the lowest level directory, and any missing
# parent directories defined in the $fulldir parameter
#####################################################################
sub create_ro_dir
{
	my($fulldir) = @_;
	my $done = 0;
	my $curdir = $fulldir;
	
	if($detailed_output){printf( "Create RO directory - $fulldir\n\n");}
	$log = $log . "Create RO directory - $fulldir\n";
	
	while(!$done)
	{
		if(-d $fulldir)
		{
			$done = 1;
		}
		else
		{
			if(-d dirname($curdir))
			{
				mkdir($curdir);
				$curdir = $fulldir;
			}
			else
			{
				$curdir = dirname($curdir);
			}
		}
	}
}#create_ro_dir
#####################################################################
# copy_ro_file($filedir, $filename, $new_filedir, $new_filename)
#	$filedir - current path of file to be copied
#	$filename - current filename of file to be copied
#	$new_filedir - new path to copy to
#	$new_filename - new filename to copy to
#
# this will copy an existing file from one location to another
#####################################################################
sub copy_ro_file
{
	# takes arguments
		# filedir - directory the file will be copied from
		# filename - filename to be copied from
		# new_filedir - directory to copy to
		# new_filename - filename to copy to - if this argument is not included, we will use the original filename
	my($filedir,$filename,$new_filedir,$new_filename) = @_;
	if(!$new_filename)
	{
		$new_filename = $filename
	}
	
    my $full_path = $filedir . "/". $filename;
    
    
	if(!-e $full_path)
	{
		if($detailed_output){printf( "Cannot find file\n\t$filedir/$filename\n  File will not be copied \n\n");}
		$log = $log .  "Cannot find file\n\t$filedir/$filename\n  File will not be copied \n\n";
		$error_text = $error_text .  "- Cannot find file $filedir/$filename.  File will not be copied!\n";
		$errors_exist = 1;
	}
	if(!-e $new_filedir )
	{
		if($detailed_output){printf( "Directory to copy file to ($new_filedir) does not exist.  File will not be copied \n\n");}
		$log = $log . "Directory to copy file to ($new_filedir) does not exist.  File will not be copied \n\n";
		$error_text = $error_text .  "- Directory to copy file to ($new_filedir) does not exist.  File will not be copied!\n";
		$errors_exist = 1;
	}
	else
	{
		copy($full_path, $new_filedir . "/" . $new_filename)
	}
	
}#copy_ro_file
#####################################################################
# get_load_directory($table)
#	$table - table name
#
# this will take a table as a parameter and determine if the load directory should be 
# safetoload or bootstraponly and return that value
#####################################################################
sub get_load_directory
{
    my ($table) = @_;
	my $loaddir;
    
	if(-d $lesdir . "/db/data/load/base/safetoload/$table")
	{
		$loaddir = 'safetoload';
	}
	elsif(-d $lesdir . "/db/data/load/base/bootstraponly/$table")
	{
		$loaddir = 'bootstraponly';
	}
	else
	{
		if($detailed_output){printf( "No control file for table $table, this table will not be included\n\n");}
		$log = $log .  "No control file for table $table, this table will not be included\n\n";
		$warning_text = $warning_text .  "- No control file for table $table, this table will not be included!\n";
		$warnings_exist = 1;
	}
	return $loaddir;
}#get_load_directory
#####################################################################
# pull_files($cmd_string)
#	$cmd_string - command line parameters from the ro input file
#
# this will take a line of parameters from the rollout input file and pull files/data as needed
# 
# this initially started as a separate perl script, so it is expecting
# parameters as -a, -b, etc. in a string
#####################################################################
sub pull_files{

	my %opts = ();
	my $lesdir = "/y/Docker/MY-GIT/SWBYDEMO";
	my $ro_dir;
	my $logfile;
	my $detailed_output;
	my $force_delete;
	my $data_type;
	my $table;
	my $sql_text;
	my $component_dir;
	my $file;
	my $grp_nam;
	my $ro_name;
	my $replacetext;
	my $ifd_list;
	my $event_list;
	my $unload;
	
	
	printf "--------------------PULL FILES----------------------\n\n\n"; 
	#first we will reset the arguments parameter to be the string passed in so we can pull the parameters
	#using the standard logic
	my $cmd_string = shift;
	if(substr($cmd_string,0,5) ne "ISSUE" && substr($cmd_string,0,5) ne "NOTES")
	{
		$cmd_string =~ s/\\/\//g;
	}
	else
	{
		$cmd_string =~ s/\\n/*LINEFEED*/g;
		$cmd_string =~ s/\\t/*TAB*/g;
	}
	
	local @ARGV = shellwords($cmd_string);
	
	#get options
	getopts('r:i:l:on:c:s:d:t:f:e:p:uh', \%opts);

	# get the arguments
	$ro_name = $opts{r} if defined($opts{r});
	$ro_dir = $opts{p} if defined($opts{p});
	$logfile = $opts{l} if defined($opts{l});
	$detailed_output = $opts{o} if defined($opts{o});
	$grp_nam = $opts{n} if defined($opts{n});
	$data_type = $opts{c} if defined($opts{c});
	$sql_text = $opts{s} if defined($opts{s});
	$component_dir = $opts{d} if defined($opts{d});
	$table = $opts{t} if defined($opts{t});
	$file = $opts{f} if defined($opts{f});
	$ifd_list = $opts{i} if defined($opts{i});
	$event_list = $opts{e} if defined($opts{e});
	$unload = $opts{u} if defined($opts{u});
	my $help = $opts{h} if defined($opts{h});
				
	if($detailed_output){printf( "uc_pull_files.pl: Pulling Components\n\n");}
	$log = $log . "uc_pull_files.pl: Pulling Components\n\n";
	printf "--------------------table:$table----------------------\n\n\n"; 
	printf "--------------------Pulling Components----------------------\n\n\n"; 
	# create RO directory if it doesn't exist
	if(!-d $ro_dir.$ro_name)
	{
		if($detailed_output){printf( "$ro_name folder does not exist - creating it\n");}
		$log = $log . "$ro_name folder does not exist - creating it\n";
		mkdir($ro_dir . $ro_name);
	}


	#####################################################################
	# SQL
	#####################################################################
	# if this is for an SQL statement, we will pull the data from the
	# sql statement and write to csv
	if(uc($data_type) eq "SQL")
	{
		printf "--------------------Handling a CSV FILE----------------------\n\n\n"; 
		$component_dir =get_load_directory($table);
		#if(uc($table) eq "POLDAT"){$component_dir = "bootstraponly";}
		if($detailed_output){printf( "MOCA\nPulling Moca file: $file\n");}
		$log = $log . "MOCA\nPulling Moca file: $file\n";
		create_ro_dir($ro_dir.$ro_name . "/pkg/db/data/load/base/$component_dir/$table");
		copy_ro_file($lesdir . "/db/data/load/base/$component_dir/$table",$file,$ro_dir.$ro_name . "/pkg/db/data/load/base/$component_dir/$table");
	}

	#####################################################################
	# MOCA
	#####################################################################
	# if this is for a moca command, copy file
	elsif(uc($data_type) eq "MOCA")
	{
		
		if(!$component_dir){$component_dir = "usrint";}
		if($detailed_output){printf( "MOCA\nPulling Moca file: $file\n");}
		$log = $log . "MOCA\nPulling Moca file: $file\n";
		create_ro_dir($ro_dir.$ro_name . "/pkg/src/cmdsrc/$component_dir");
		copy_ro_file($lesdir . "/src/cmdsrc/$component_dir",$file,$ro_dir.$ro_name . "/pkg/src/cmdsrc/$component_dir");
	}

	#####################################################################
	# REPORT
	#####################################################################
	# if this is for a report, copy file
	elsif(uc($data_type) eq "REPORT")
	{
		if($detailed_output){printf( "REPORT\nPulling Report file: $file\n");}
		$log = $log . "REPORT\nPulling Report file: $file\n";
		create_ro_dir($ro_dir.$ro_name . "/pkg/reports/$component_dir");
		copy_ro_file($lesdir . "/reports/$component_dir",$file,$ro_dir.$ro_name . "/pkg/reports/$component_dir");
	}

	#####################################################################
	# LABEL
	#####################################################################
	# if this is for a report, copy file
	elsif(uc($data_type) eq "LABEL")
	{
		if($detailed_output){printf( "LABEL\nPulling Label file: $file\n");}
		$log = $log . "LABEL\nPulling Label file: $file\n";
		create_ro_dir($ro_dir.$ro_name . "/pkg/labels/$component_dir");
		copy_ro_file($lesdir . "/labels/$component_dir",$file,$ro_dir.$ro_name . "/pkg/labels/$component_dir");
	}

	#####################################################################
	# DDL
	#####################################################################
	# if this is for a report, copy file
	elsif(uc($data_type) eq "DDL")
	{
		if($detailed_output){printf( "DDL\nPulling DDL file: $file\n");}
		$log = $log . "DDL\nPulling DDL file: $file\n";
		create_ro_dir($ro_dir.$ro_name . "/pkg/db/ddl/$component_dir");
		copy_ro_file($lesdir . "/db/ddl/$component_dir",$file,$ro_dir.$ro_name . "/pkg/db/ddl/$component_dir");
	}

	#####################################################################
	# INT
	#####################################################################
	# if this is for an integrator file, copy file
	elsif(uc($data_type) eq "INT")
	{
		if($detailed_output){printf( "INT\nPulling Integration file: $file\n");}
		$log = $log . "INT\nPulling Integration file: $file\n";
		create_ro_dir($ro_dir.$ro_name . "/pkg/db/data/integrator");
		copy_ro_file($lesdir . "/db/data/integrator",$file,$ro_dir.$ro_name . "/pkg/db/data/integrator");
	}

	#####################################################################
	# README
	#####################################################################
	# if this is for a README file copy the file
	elsif(uc($data_type) eq "README")
	{
		if($detailed_output){printf( "README\nPulling README file: $file\n");}
		$log = $log ."README\nPulling README file: $file\n";
		
		copy_ro_file($ro_dir,$file,$ro_dir.$ro_name);

	}

	#####################################################################
	# FILE
	#####################################################################
	# if this is for a file, copy file
	elsif(uc($data_type) eq "FILE")
	{
		if($detailed_output){printf( "FILE\nPulling File: $file\n");}
		$log = $log . "FILE\nPulling File: $file\n";
		create_ro_dir($ro_dir.$ro_name . "/pkg/$component_dir");
		copy_ro_file($lesdir . "/$component_dir",$file,$ro_dir.$ro_name . "/pkg/$component_dir");
		
		
		#write rollout script
		if($detailed_output){printf("Creating line for rollout script for adding file\n");}
		$log = $log . "Creating line for rollout script for adding file\n";

		$replacetext = $replacetext . "REPLACE pkg/$component_dir/$file \$lesdir/$component_dir\n";
		
		$component_text = $component_text . "\t$component_dir/$file\n";

	}

	#####################################################################
	# REMOVE
	#####################################################################
	# if this is to remove a file, write the line
	elsif(uc($data_type) eq "REMOVE")
	{
		if($detailed_output){printf( "REMOVE\nWriting line to remove file: $file\n");}
		$log = $log . "REMOVE\nWriting line to remove file: $file\n";
		
		#write rollout script
		if($detailed_output){printf("Creating line for rollout script for removing file\n");}
		$log = $log . "Creating line for rollout script for removing file\n";

		$remove_ro_text = $remove_ro_text . "REMOVE \$lesdir/$component_dir/$file\n";
		
		$remove_text = $remove_text . "\t$component_dir/$file\n";

	}
	
	#####################################################################
	# MTF
	#####################################################################
	# if this is for an MTF file, copy file
	elsif(uc($data_type) eq "MTF")
	{
		$component_dir = "mtfclient/src/java/com/redprairie/les/formlogic";
		if($detailed_output){printf( "MTF\nPulling MTF File: $file\n");}
		$log = $log . "MTF\nPulling MTF File: $file\n";
		create_ro_dir($ro_dir.$ro_name . "/pkg/$component_dir");
		copy_ro_file($lesdir . "/$component_dir",$file,$ro_dir.$ro_name . "/pkg/$component_dir");
		
	}

	#####################################################################
	# ISSUE
	#####################################################################
	# if this is for Issue text, set the text to the issue_text variable
	
	elsif(uc($data_type) eq "ISSUE")
	{
		if($detailed_output){printf( "ISSUE\nSetting Issue text for README file: $table\n");}
		$log = $log . "ISSUE\nSetting Issue text for README file: $table\n";
		$table =~ s/\*LINEFEED\*/\n/g;
		$table =~ s/\*TAB\*/\t/g;
		$issue_text = $issue_text . $table;
	}
	
	#####################################################################
	# NOTES
	#####################################################################
	# if this is for release notes text, set the text to the notes_text variable
	
	elsif(uc($data_type) eq "NOTES")
	{
		if($detailed_output){printf( "NOTES\nSetting Release Notes text for README file: $table\n");}
		$log = $log . "NOTES\nSetting Release Notes text for README file: $table\n";
		$table =~ s/\*LINEFEED\*/\n/g;
		$table =~ s/\*TAB\*/\t/g;
		$notes_text = $notes_text . $table;		
	}
	
	#####################################################################
	# DIR
	#####################################################################
	# if this is for a directory, copy directory
	elsif(uc($data_type) eq "DIR")
	{
		if($detailed_output){printf( "DIR\nCreating Directory: $component_dir\n");}
		$log = $log . "DIR\nCreating Directory: $component_dir\n";
		create_ro_dir($ro_dir.$ro_name . "/pkg/$component_dir");
		
		
		#write rollout script
		if($detailed_output){printf("Creating line for rollout script for adding directory\n");}
		$log = $log . "Creating line for rollout script for directory file\n";

		$replacetext = $replacetext . "CREATEDIR \$lesdir/$component_dir\n";

	}

	#####################################################################
	# IU - Integrator Unload
	#####################################################################
	# if this is for a directory, copy directory
	elsif(uc($data_type) eq "IU")
	{

		my $status;
		my @result;
		my $unload_statement;
		my $src_system = $sql_text;
		my $dest_system = $component_dir;
		
		if(!$ifd_list && !$event_list)
		{
			if($detailed_output){printf( "Error!  No ifds or events specified to unload.  No integrator unloads will be performed.\n");}
			$log = $log . "Error!  No ifds or events specified to unload.  No integrator unloads will be performed.\n";
			$error_text = $error_text .  "- Error!  No ifds or events specified to unload.  No integrator unloads will be performed!\n";
			$errors_exist = 1;
		}
		else
		{
			if($detailed_output){printf( "IU\nUnloading Integrator Transaction(s)\n\tIFD List $ifd_list\n\tEvent List: $event_list\n");}
			$log = $log . "IU\nUnloading Integrator Transaction(s)\n\tIFD List $ifd_list\n\tEvent List: $event_list\n";
		
			if(!$ifd_list)
			{
				$ifd_list = "NULL";
			}
			if(!$event_list)
			{
				$event_list = "NULL"
			
			}
			
			if(!$file)
			{
				if($detailed_output){printf( "No filename specified for integrator unload.  Using default: $ro_name.slexp\n");}
				$log = $log . "No filename specified for integrator unload.  Using default: $ro_name.slexp\n";
				$file = $ro_name . ".slexp";
			}
			else
			{
				if($detailed_output){printf( "Unloading to file: $file\n");}
				$log = $log . "Unloading to file: $file\n";
			}
			my $full_path = $lesdir . "/db/data/integrator/". $file;
			
			if(-e $full_path)
			{
				if($detailed_output){printf( "Unload already exists: $file\nDeleting...\n");}
				$log = $log . "Unload already exists: $file\nDeleting...\n";
				unlink($full_path);
			}
			
			my $unload_statement = "sl_list dependencies where evt_list = \"$event_list\" and ifd_list = \"$ifd_list\" and unload_filename = '$full_path'";
			if($src_system)
			{
				$unload_statement = $unload_statement . " and TRG_SYS_ID = '$src_system'";
			}
			if($dest_system)
			{
				$unload_statement = $unload_statement . " and DEST_SYS_ID = '$dest_system'";
			}
			
			if($detailed_output){printf( "Unload statement: $unload_statement\n");}
			$log = $log . "Unload statement: $unload_statement\n";
			($status, @result) = &MSQLExec($unload_statement);
			if($detailed_output){printf( "status: $status\nresult: @result\n");}
			if($status)
			{
				if($detailed_output){printf( "Error unloading integrator transaction(s)\n\tIFD List $ifd_list\n\tEvent List: $event_list\n");}
				$log = $log . "Error unloading integrator transaction(s)\n\tIFD List $ifd_list\n\tEvent List: $event_list\n";
				$error_text = $error_text .  "- Error unloading integrator transaction(s)\n\t- IFD List $ifd_list\n\t- Event List: $event_list\n";
				$errors_exist = 1;
			}
			else
			{
				if($detailed_output){printf( "Succesfully unloaded integrator transaction(s)\n\tIFD List $ifd_list\n\tEvent List: $event_list\n");}
				$log = $log . "Succesfully unloaded integrator transaction(s)\n\tIFD List $ifd_list\n\tEvent List: $event_list\n";
				
				create_ro_dir($ro_dir.$ro_name . "/pkg/db/data/integrator");
				copy_ro_file($lesdir . "/db/data/integrator",$file,$ro_dir.$ro_name . "/pkg/db/data/integrator");
			
			}

		}
	}
	else
	{
		if($detailed_output){printf( "Invalid option for component type: $data_type\n\n");}
		$log = $log . "Invalid option for component type: $data_type\n\n";	
		$error_text = $error_text .  "- Invalid option for component type: $data_type. No components will be pulled for this line.\n";
		$errors_exist = 1;
	}

	write_log();

	# write rollout script
	open(OUTF, ">>$ro_dir$ro_name/$ro_name");
	print OUTF  $replacetext;
	close(OUTF);
	
}#pull_files



#####################################################################
#####################################################################
# MAIN uc_build_rollout
#####################################################################
#####################################################################

#get options
getopts('d:r:l:ohn:fpbm', \%opts);
#perl createRolloutPackage.pl -n RLTEST1 -d rollout -r inputFile.txt -f -l test1.log 
# get the arguments
#$ro = $opts{r} if defined($opts{r}); #-r - required - rollout input file
# Destination File 
my $SrcInputFile = 'inputFile.txt'; 
$ro = $SrcInputFile ;
$ro_dir = $opts{d} if defined($opts{d}); #-d - required - directory where the rollout input file is located
$logfile = $opts{l} if defined($opts{l});
$detailed_output = $opts{o} if defined($opts{o});
$ro_name = $opts{n} if defined($opts{n}); #-n - required - Rollout name
$force_delete = $opts{f} if defined($opts{f});
$pack = $opts{p} if defined($opts{p});
$build_script = $opts{b} if defined($opts{b});
$build_readme = $opts{m} if defined($opts{m});
my $help = $opts{h} if defined($opts{h});

if($help)
{
	show_usage();
}

# to be replaced after by an input parameter

my $s = 'A db/data/load/base/bootstraponly/poldat/lc_be03_otm_poldat_swiftlex-2715.csv M src/cmdsrc/usrint/send_lc_be03_otm_transport_plan.mcmd';
print "Original files:",$s,"\n\n";


my @addModFiles = split /((?:A|M)\s\S*\s)/, $s;
#print Dumper \@addModFiles;
# open destination file for writing 
open my $vInputFile, '>', $SrcInputFile;
# EX. A db/data/load/base/bootstraponly/poldat/lc_be03_otm_poldat
foreach my $file (@addModFiles)  
{ 
	if($file){
		print "Looking into $file\n\n\n"; 
		
		my $pointPos = rindex($file, "."); 
		print "Position of point: $pointPos\n"; 
		my $slashPos = rindex($file, "/"); 
		my $fileExt = substr($file,$pointPos+1); 
		my $fileFullName = substr($file,$slashPos+1); 
		$fileFullName=~ s/\s+$//;
		$fileExt=~ s/\s+$//;
		print "File Name: *$fileFullName*\n"; 
		print "File extension: *$fileExt*\n"; 
		if ($fileExt eq "mcmd" || $fileExt eq "mtrg") {
			#MOCA -d usrint -f "list_usr_1234.mcmd"
			my $fullFileSyntax = "MOCA -d usrint -f \"".$fileFullName."\"";
			print "File syntax: $fullFileSyntax\n"; 		
			print {$vInputFile} $fullFileSyntax . "\n";
		}
		elsif ($fileExt eq "csv"){
			##SQL -t poldat  -s "select * from poldat where polcod = 'UC_1234'"
			my $table_name = substr(substr($file,0,$slashPos),rindex(substr($file,0,$slashPos), "/")+1);
			#print "table_name: $table_name\n";
			my $fullFileSyntax = "SQL -t ".$table_name." -f \"".$fileFullName."\"";
			print "File syntax: $fullFileSyntax\n"; 
			#my $slashPos = rindex($file, "/");
			
			print {$vInputFile} $fullFileSyntax . "\n";
			
		}
		print "------------------------------------------\n\n\n"; 
	}
} 
close($vInputFile); 
move($SrcInputFile, "./rollout/") or die "Move failed: $!";

# Opening a file and reading content  
#if(open($vOutputFile, '<', $SrcInputFile))  
#{  
#    while($vOutputFile)  
#    {  
#        print $_;  
#    }  
#}  
  
# Executes if file not found  
#else
#{  
#  warn "Couldn't Open a file $filename";  
#}  

#close(vOutputFile); 
printf("Input file had been created!\n\n");
#validate ro argument passed in
if(!$ro)
{
	#if a name was specified, we'll try to use ro_name.ro
	if(!$ro_name)
	{
		printf("ERROR! -r rollout file must be defined!\n\n");
		$log = "ERROR! -r rollout file must be defined!\n\n";
		if($logfile)
		{
			open(OUTF, ">>$lesdir/log/$logfile");
			print OUTF $log;
		}
		show_usage();
        exit 0;
	}
	else
	{
		$ro = $ro_name . ".ro";
	}
}

# rollout directory
if($ro_dir)
{
	$orig_dir = $ro_dir;
	$ro_dir = $lesdir . "/" . $ro_dir . "/";
}
else
{
	if(!-d $lesdir . "/" . "rollout")
	{
		$orig_dir = "rollouts";
		$ro_dir = $lesdir . "/rollouts/";
	}
	else
	{
		$orig_dir = "rollout";
		$ro_dir = $lesdir . "/rollout/";
	}
}

# rollout directory parameter -  to be passed to pull_files
$ro_dir_parm = "-p " . $ro_dir ;

# logfile parameter -  to be passed to pull_files
if($logfile)
{
	$logfile_parm = "-l " . $logfile;
}

# detailed_output parameter -  to be passed to pull_files
if($detailed_output)
{
	$detailed_output_parm = "-o ";
}

# readme parameter -  to be passed to package_rollout
if($build_readme)
{
	$readme_parm = "-m ";
}

#validate ro file exist
if (!-e "$ro_dir$ro")
{
	printf("ERROR! rollout file ($ro_dir$ro) does not exist\n\n");
	$log = "ERROR! rollout file ($ro_dir$ro) does not exist\n\n";
	if($logfile)
	{
		open(OUTF, ">>$lesdir/log/$logfile");
		print OUTF $log;
	}
	show_usage();
	
	exit 0;
}

#validate ro_name argument passed in
if(!$ro_name)
{
	#if we 
	if($ro)
	{
		$ro_name = $ro;
		$ro_name =~ s/\.ro//;
	}
	else
	{
		printf("ERROR! -n rollout name must be defined!\n\n");
		$log = "ERROR! -n rollout name must be defined!\n\n";
		if($logfile)
		{
			open(OUTF, ">>$lesdir/log/$logfile");
			print OUTF $log;
		}
		show_usage();
		exit 0;
	}
}

# logging
if($detailed_output){printf( "Creating Rollout Directory \n\nCurrent Time: " . localtime() . "\n\nOptions\nRollout Directory = $ro_dir$ro_name\nlogfile = $logfile\n\nEnvironment:\nLESDIR = $lesdir\nLog directory=$lesdir\log\nRollout Name = $ro_name\n\n");}
$log = $log . "Creating Rollout Directory \n\nCurrent Time: " . localtime() . "\n\nOptions\nRollout Directory = $ro_dir$ro_name\nlogfile = $logfile\n\nEnvironment:\nLESDIR = $lesdir\nLog directory=$lesdir\log\nRollout Name = $ro_name\n\n";


#if ro directory already exists, stop - need to delete directory first
#we don't want to do this automatically in case it is the wrong ro name
#UNLESS they pass in -f argument to force delete of existing directory
if(-d $ro_dir . $ro_name && !$force_delete)
{
	printf("ERROR! directory $ro_dir$ro_name already exists!  Manually delete the directory or use -f option to force delete.\n\n");
	$log = $log . "ERROR! directory $ro_dir$ro_name already exists!  Manually delete the directory or use -f option to force delete.\n\n";
	$error_text = $error_text .  "- ERROR! directory $ro_dir$ro_name already exists!  Manually delete the directory or use -f option to force delete.\n";
	$errors_exist = 1;
	if($logfile)
	{
		open(OUTF, ">>$lesdir/log/$logfile");
		print OUTF $log;
	}
	exit 0;
}
elsif (-d $ro_dir . $ro_name)
{
	if($detailed_output){printf( "Rollout directory ($ro_dir.$ro_name) already exists. \n-f option passed in so we will remove it\nRemoving Directory...\n\n");}
	$log = $log . "Rollout directory ($ro_dir.$ro_name) already exists. \n-f option passed in so we will remove it\nRemoving Directory...\n\n";
	rmtree($ro_dir . $ro_name);
}

if($detailed_output){printf( "Reading file $ro to get options for creating rollout directory\n\n");}
$log = $log . "Reading file $ro to get options for creating rollout directory\n\n";


$ro_name_parm = "-r $ro_name ";

my $line_count = 0;
printf(" $ro_dir$ro\n");

# Opening a file and reading content  

# loop through the rollout input file and pass each line to pull_files function
#open (ROFILE,$ro_dir.$ro);
open($vOutputFile, '<:encoding(UTF-8)', $ro_dir.$ro) or die "Could not open file '$ro_dir.$ro' $!";
printf(" input file is opened for reading\n");
while (my $line = <$vOutputFile>)
{
	printf("Starting reading the input file\n");
	# cannot send d, t, f, s, or n parameters to pull_files as these are reserved
	# for use in the ro file
	#chomp;
	# don't read line if it starts with #
	
	chomp $line;
	printf("Got Line:$line\n");
	$line_count = $line_count + 1;
	

	#if($detailed_output){printf("Got Line:$line\n");}
	#$log = $log . "Got Line:$line\n";
	
	my $pull_file_string ="-c $line $ro_name_parm $ro_dir_parm $logfile_parm $detailed_output_parm\n";
	#if($detailed_output){printf( "Calling pull_files function with: $pull_file_string \n\n");}
	#$log = $log . "Calling pull_files function with: $pull_file_string \n\n";
	
	#write to log since we may get new info for the log in pull_files
	#write_log();
	#call pull files
	printf("Pull Line:$pull_file_string\n");
	pull_files($pull_file_string);
	
}
if($line_count > 0)
{
	$log = $log . "Finished calls to pull_files.  Read in and processed $line_count lines. \n\n";
	printf("Finished calls to pull_files.  Read in and processed $line_count lines. \n\n");
}
# if -p parameter was passed in, we will package the rollout after creating the directory
#if($pack or $build_script)
#{
#	my $pack_parm;
	#if($pack)
	#{
	#	$pack_parm = '-p';
	#}
	#my $pack_cmd = "-d $orig_dir/$ro_name $logfile_parm $detailed_output_parm $pack_parm $readme_parm\n";
	#if($detailed_output){printf( "Calling package_rollout function with: $pack_cmd \n\n");}
	#$log = $log . "Calling package_rollout function with: $pack_cmd \n\n";
	#write to log since we may get new info for the log in package_rollout
	#write_log();
	#call package_rollout
#	package_rollout($pack_cmd);
#}	
close($vOutputFile);
printf("\n");
if($warnings_exist == 1)
{
	printf($warning_text . "\n");
}
if($errors_exist == 1)
{
	printf($error_text);
}
exit 0;