use Archive::Tar;
use Archive::Zip;
use File::Basename;
use File::Find;
use File::Spec;
use File::Path;
use File::Copy;
use strict;
use POSIX qw( strftime );
use File::Path qw( rmtree );
use IO::Uncompress::Unzip qw(unzip $UnzipError);

# ------------------------------------------------------------------------------
# GLOBAL VARIABLES - START
# ------------------------------------------------------------------------------

my $arg_install_mode;
my $arg_rollout_name;
my $arg_force_extract;
my $arg_dry_run;
my $arg_start_service;
my $arg_allow_db_backup;
my $arg_create_db_backup;
my $arg_change_to_environment;
my $arg_change_to_environment_wh_id;
my $arg_install_types;
my $arg_types_spec;

my $env_les_dir = "$ENV{LESDIR}";
my $env_moca_env_name = "$ENV{MOCA_ENVNAME}";
my $env_registry_file = "$ENV{MOCA_REGISTRY}";
my $env_rollouts_dir = "$ENV{LESDIR}/rollout_gen";
my $env_db_backup_dir = "$ENV{LESDIR}/backups";
my $env_dbname;
my $env_logfile;

my $os_name;
my $refsname='';

# ------------------------------------------------------------------------------
# GLOBAL VARIABLES - END
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# GENERIC FUNCTIONS - START
# ------------------------------------------------------------------------------
sub get_os_name {
	$os_name = $^O;
}

sub check_moca_exists {
	my $mocaname = '';
	if($os_name eq 'linux'){
		$mocaname = 'STWWMSMD'
	} else {
		$mocaname = qx(sc query | find /I "moca.$env_moca_env_name");
	};
	if(defined $mocaname and length $mocaname){
		return(1);
	} else {
		return(0);
	};
}

sub check_refs_exists {
	print "REFS Service: ";
	if($os_name eq 'linux'){
		$refsname = 'STWWMSPD'
	} else {
		$refsname = qx(sc query | find /I "REFS \(");
		$refsname = substr($refsname, 14, index($refsname, "DISPLAY_NAME:") - 15);
	};
	print "$refsname\n";
	if(defined $refsname and length $refsname){
		return(1);
	} else {
		return(0);
	};
}

sub stop_services {
	my $cmd;
	## Shutdown MCS service
	if(check_moca_exists()) {		
		if($os_name eq 'linux') {
			$cmd = "rp stop";
		} else {
			$cmd = "NET STOP moca.$env_moca_env_name";
		}
		system($cmd);
	}

}

sub start_services {
	my $cmd;
	## Start MCS service
	if(check_moca_exists()) {		
		if($os_name eq 'linux') {
			$cmd = "rp start";
		} else {
			$cmd = "NET START moca.$env_moca_env_name";
		}
		system($cmd);
	}
}

sub extract_any{
	my ($file_path, $unzip_dir) = @_;
	
	if($file_path =~ /.*\.zip/){
		extract_zip($file_path, $unzip_dir);
	}
	elsif($file_path =~ /.*\.exe/){
		extract_zip($file_path, $unzip_dir);
	}
	elsif($file_path =~ /.*\.tar\.gz/)
	{
		extract_tar($file_path, $unzip_dir);
	}
	else
	{
		print "Unknown archive file.";
	}
}

sub extract_tar{
	my ($tar_path, $unzip_dir) = @_;
	my $fileCounter = 0;
	
	print "Extracting";
	
	my $tar = Archive::Tar->new($tar_path, 1);
    foreach my $in_tar_file ($tar->list_files)
    {
		my $destfile = File::Spec->catfile($unzip_dir, $in_tar_file);
		$tar->extract_file($in_tar_file, $destfile);
		
		if($fileCounter % 25 == 0){
			print ".";
		}	
		$fileCounter++;
    }
	print "Done (extracted $fileCounter files)\n";
}

sub extract_zip{
	my ($zip_path, $unzip_dir) = @_;
	my $fileCounter = 0;
	
	print "Extracting";
	
	my $u = new IO::Uncompress::Unzip $zip_path
		or die "Cannot open $zip_path: $UnzipError";

	
	if (! defined $u->getHeaderInfo){
		die "Zipfile has no members"
	}

    for (my $status = 1; $status > 0; $status = $u->nextStream()) 
	{
        my $header = $u->getHeaderInfo();
        my (undef, $path, $name) = File::Spec->splitpath($header->{Name});
        my $destdir = File::Spec->catdir($unzip_dir, $path);
		my $destfile = File::Spec->catfile($destdir, $name);

		if($name ne ''){
			if(! -d $destdir) {
				File::Path::mkpath($destdir) or die "Couldn't mkdir $destdir: $!";
			}
		
			my $buff;
			my $fh = IO::File->new($destfile, "w")
				or die "Couldn't write to $destfile: $!";
			binmode($fh);
			while (($status = $u->read($buff)) > 0) {
				$fh->write($buff);
			}
			$fh->close();
			
			my $stored_time = $header->{'Time'};
			utime ($stored_time, $stored_time, $destfile)
				or die "Couldn't touch $destfile: $!";
		}
		
		if($fileCounter % 25 == 0){
			print ".";
		}	
		$fileCounter++;
    }
	print "Done (extracted $fileCounter files)\n";
}

sub print_header{
	my($header_text) = @_;
	my $header_width = 60;
	
	print "-" x $header_width . "\n";
	print "- $header_text" . "\n";
	print "-" x $header_width . "\n";
}

sub backup_db_sqlserver{
	my($dbname, $path_backup) = @_;
	print "Backing up current database\n";
	my $sql = "BACKUP DATABASE $dbname TO DISK='$path_backup' WITH COMPRESSION";
	my $cmd = "SqlCmd -b -E -S localhost -Q \"" . $sql . "\"";
	if($arg_dry_run == 1){
		print "(dry-run) $cmd\n";
	}else{
		print "$cmd\n";
		system($cmd);
	}	
	my $return_status = $? >> 8;
	if($return_status > 0){
		exit(-1);
	}
}

sub restore_db_sqlserver{
	my($dbname, $path_backup) = @_;
	print "Restoring database\n";
	
	my $sql = 	"ALTER DATABASE $dbname SET SINGLE_USER WITH ROLLBACK IMMEDIATE;" .
				"ALTER DATABASE $dbname SET OFFLINE;" .
				"RESTORE DATABASE $dbname FROM DISK='$path_backup' WITH REPLACE;" . 
				"ALTER DATABASE $dbname SET ONLINE;" . 
				"ALTER DATABASE $dbname SET MULTI_USER;" .
				#Restore orphaned users after database restore:
				#https://docs.microsoft.com/en-us/sql/sql-server/failover-clusters/troubleshoot-orphaned-users-sql-server?view=sql-server-ver15
				#"EXEC sp_MSforeachdb 'USE ?;ALTER USER JDAWMS WITH Login = JDAWMS;';" .
				"USE $dbname;ALTER USER BYWMS WITH Login = BYWMS;";
	
	my $cmd = "SqlCmd -b -E -S localhost -Q \"" . $sql . "\"";
	if($arg_dry_run == 1){
		print "(dry-run) $cmd\n";
	}else{
		system($cmd);
	}
	my $return_status = $? >> 8;	
	if($return_status > 0){
		exit(-1);
	}
}

# ------------------------------------------------------------------------------
# GENERIC FUNCTIONS - END
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# APPLICATION FUNCTIONS - START
# ------------------------------------------------------------------------------

sub usage
{
   print STDERR "usage: usr_install_rollouts.pl [options]\n" .
				"There must be only 1 of the following provided\n".
                "    [-d <rollout>] [-v <rollout>]\n\n".
				"  -s, --dry-run                         Runs the installation as a dry run where no changes are actually made\n" .
				"  -x, --force-extract                   Reextracts rollouts for which an extracted folder already exists\n" .
				"  -r, --restore-db                      Restore a database backup (if available) to reduce the number of rollouts to be installed\n" .
				"  -b, --backup-db                       Create a backup of the database after each rollout installation\n" .
				"  -c, --change-to-environment <wh_id>   Change to environment(s) <wh_id> separated by pipes (and between quotes) <\"1|2|3|7\"> (before running the rollouts) \n" .
				"  -d, --only-rollout <rollout>          Process <rollout> only\n" .
				"  -v, --from-rollout <rollout>          Start upgrading at <rollout>\n" .
				"  -t, --types <type>                    Run these type(s) separated by pipes (and between quotes); TMP|RBK|BCK are excluded by default <\"DEV|FIX\">\n" .
				"  -e, --exclude-start                   do not start moca service after installing rollout(s)\n" .
				"  -h, --help                            Show this message\n";

   exit(-1);
}

sub get_dbname_from_registry{
	my($registry_file) = @_;
	
    open(FH, $registry_file) or die("File $registry_file not found"); 
      
    while(my $line = <FH>) 
    { 
        if($line =~ /url=jdbc:sqlserver:\/\/.*\=(.*)/) 
        { 
            return ($1); 
        } 
    } 
    close(FH); 
}

sub find_newest_db_backup{
	my($backup_dir, $dbname, @rollout_list) = @_;
	
	opendir(my $dir, $backup_dir) or die("ack: $!");
	my @backup_files = grep (/^.*\.bak$/, readdir $dir);
	closedir $dir;
	
	foreach my $rollout (@rollout_list){
		#Remove the extension
		my $rollout_no_ext = $rollout;
		$rollout_no_ext =~ s/(\.zip|\.tar\.gz|\.exe)//;
		foreach my $backup (@backup_files){
			if($backup eq "$dbname\_$rollout_no_ext.bak"){
				print "Found backup for $rollout ($backup)\n";
				return ($rollout, $backup);
			}
		}
	}
	print "No backup found.\n";
	return ();
}

sub restore_db_from_backup{
	my ($db_backup_dir, $dbname, @rollout_list) = @_;

	print_header("DATABASE RESTORE");
	
	my ($newest_backup_rollout, $newest_backup_filename) = find_newest_db_backup($db_backup_dir, $dbname, reverse @rollout_list);
	if($newest_backup_rollout ne ""){
		backup_db_sqlserver($dbname, "$env_db_backup_dir/$env_dbname-" . strftime("%Y%m%d_%H%M%S", localtime()) . ".bak");
		restore_db_sqlserver($dbname, "$env_db_backup_dir/$newest_backup_filename");
	}
	return $newest_backup_rollout;
}

sub check_cmd_arguments
{
	my $install_mode_next_arg_rollout_name = 0;
	my $change_to_environment_next_arg_wh_id = 0;
	my $install_type_next_arg_types = 0;
	
	print_header("ARGUMENTS");
	
	foreach my $arg (@ARGV)
    {
		if($install_mode_next_arg_rollout_name == 1){
			$arg_rollout_name = $arg;
			$install_mode_next_arg_rollout_name = 0;
		}elsif($install_type_next_arg_types == 1){
			$arg_types_spec = $arg;
			$install_type_next_arg_types = 0;
		}elsif($change_to_environment_next_arg_wh_id == 1){
			$arg_change_to_environment_wh_id = $arg;
			$change_to_environment_next_arg_wh_id = 0;
		}elsif($arg eq "-x" || $arg eq "--force-extract"){
			$arg_force_extract = 1;
		}elsif($arg eq "-r" || $arg eq "--restore-db"){	
			$arg_allow_db_backup = 1;
		}elsif($arg eq "-b" || $arg eq "--backup-db"){	
			$arg_create_db_backup = 1;
		}elsif($arg eq "-s" || $arg eq "--dry-run"){
			$arg_dry_run = 1;
			}elsif($arg eq "-e" || $arg eq "--exclude-start"){
			$arg_start_service = 0;
		}elsif($arg eq "-c" || $arg eq "--change-to-environment"){
			$arg_change_to_environment = 1;
			$change_to_environment_next_arg_wh_id = 1;
		}elsif($arg eq "-v" || $arg eq "--from-rollout"){
			$arg_install_mode = "from-rollout";
			$install_mode_next_arg_rollout_name = 1;
		}elsif($arg eq "-d" || $arg eq "--only-rollout"){
			$arg_install_mode = "only-rollout";
			$install_mode_next_arg_rollout_name = 1;
		#when -t and -v is set loop to get arg_types_spec
		}elsif($arg eq "-t" || $arg eq "--types"){
			$arg_install_types = 1;
			$install_type_next_arg_types = 1;
		}elsif($arg eq "-h" || $arg eq "--help"){
			usage();
		}else{
			print STDERR "Unknown argument: $arg\n";
			usage();
		}
	}

	print "Change to environment: $arg_change_to_environment (environment(s): $arg_change_to_environment_wh_id)\n";
	
	print "Install mode is: $arg_install_mode\n";
	
	if ($arg_install_mode ne "" && $arg_rollout_name eq ""){
		print STDERR "ERROR: Rollout name not specified!\n";
		usage();
	}else{
		print "Rollout name: $arg_rollout_name\n";
	}
	
	if ($arg_install_types eq 1 && $arg_install_mode ne "from-rollout"){
		print STDERR "ERROR: setting types (-t) without from-rollout (-v) is not valid\n";
		usage();
	}else{
		print "install types: $arg_types_spec\n";
	}
	
	print "Allow DB backup restore: $arg_allow_db_backup\n";
	print "Force reextraction of rollouts: $arg_force_extract\n";
	print "Dry run: $arg_dry_run\n";
	print "Start service: $arg_start_service\n";

}

sub check_environment{
	
	print_header("ENVIRONMENT");
	
	if(-e "$env_les_dir"){
		print "LESDIR: $env_les_dir\n";
	}else{
		print STDERR "LESDIR not found ($env_les_dir).\n";
	}

	if(-e "$env_registry_file"){
		print "Registry: $env_registry_file\n";
	}else{
		print STDERR "Registry file not found ($env_registry_file).\n";
	}

#to enable script locally and on server switch from rollout_gen to rollouts folder if rollout_gen does not exist
    if (-d "$env_rollouts_dir") {
        print "Rollout directory: $env_rollouts_dir\n";
    }elsif(-d "$env_les_dir/rollouts") {
	    my $gen_env_rollouts_dir = $env_rollouts_dir;
	    $env_rollouts_dir = "$env_les_dir/rollouts";
	    print "Rollout directory: $env_rollouts_dir because $gen_env_rollouts_dir does not exist\n";
    }else{
		print STDERR "Rollouts directory not found ($env_rollouts_dir).\n";
	}

	print "Moca environment name: $ENV{MOCA_ENVNAME}\n";	

	$env_dbname = get_dbname_from_registry("$env_registry_file");
	if($env_dbname ne ""){
		print "Database name: $env_dbname\n";
	}else{
		print STDERR "Database name not found in registry.\n";
	}
	
	$env_logfile = "usr_install_rollouts.pl-" . strftime("%Y-%m-%d %H:%M:%S", localtime()) . ".log";
	print "Logfile $env_logfile\n";
}

sub print_rollouts_summary{
	my ($rollout_name_found, $total_no_rollouts, $to_install_no_rollouts, $backup_rollout_name_found, $backup_to_install_no_rollouts) = @_;

	print_header("ROLLOUT SUMMARY");

	print "Rollout found: $rollout_name_found\n";
	print "Rollouts found: $total_no_rollouts\n";
	print "Rollouts to install: $to_install_no_rollouts\n";
	print "Backup rollout found: $backup_rollout_name_found\n";
	print "Backup rollouts to install: $backup_to_install_no_rollouts\n";
}

sub list_rollouts{
	my ($rollouts_dir, @rollout_list) = @_;

	print_header("WILL INSTALL FOLLOWING ROLLOUTS IN ORDER");

	my $rollout_counter = 1;
	foreach my $rollout_file (@rollout_list)
	{
		  print sprintf("%-5s", $rollout_counter . ".") . "$rollout_file\n";
		  $rollout_counter++;
	}
}

sub extract_rollouts{
	my ($rollouts_dir, @rollout_list) = @_;

	print_header("EXTRACTING ROLLOUTS");
	
	my $rollout_counter = 1;
	foreach my $rollout_file (@rollout_list)
	{
		print sprintf("%-5s", $rollout_counter . ".") . "$rollout_file\n";

		my $rollout_file_path = File::Spec->catdir($rollouts_dir, $rollout_file);
		(my $rollout_filename_no_ext, my $rollout_file_dir, my $rollout_filename_ext) = fileparse($rollout_file_path, qr/\.[^.]*/);
		my $rollout_dir_path = File::Spec->catdir($rollout_file_dir, $rollout_filename_no_ext);

		if(! -d $rollout_dir_path || $arg_force_extract == 1) {
			if(-d $rollout_dir_path){
				if($arg_dry_run == 1){
					print "Removing extracted directory (dry-run)\n";
				}else{
					print "Removing extracted directory\n";
					rmtree($rollout_dir_path);
				}
			}
			
			if($arg_dry_run == 1){
				print "Extracting.... (dry-run)\n";
			}else{
				extract_any($rollout_file_path, $rollouts_dir);
			}
		}else{
			if($arg_dry_run == 1){
				print "Already extracted...Skipping(dry-run)\n";
			}else{
				print "Already extracted...Skipping\n";
			}
		}
		$rollout_counter++;
	}
}

sub install_rollouts{
	my ($rollouts_dir, @rollout_list) = @_;
	
	print_header("INSTALLING ROLLOUTS");
	
	my $rollout_counter = 1;

	foreach my $rollout_file (@rollout_list)
	{
		print sprintf("%-5s", $rollout_counter . ".") . "$rollout_file\n";
		
		my $rollout_file_path = File::Spec->catdir($rollouts_dir, $rollout_file);
		(my $rollout_filename_no_ext, my $rollout_file_dir, my $rollout_filename_ext) = fileparse($rollout_file_path, qr/\.[^.]*/);
		my $rollout_dir_path = File::Spec->catdir($rollout_file_dir, $rollout_filename_no_ext);

		my $rollout_script_path = File::Spec->catdir($rollout_dir_path, $rollout_filename_no_ext);
		
		if(-d $rollout_script_path) {
			$rollout_dir_path = $rollout_script_path;
			$rollout_script_path = File::Spec->catdir($rollout_script_path, $rollout_filename_no_ext);
		}
		
		if(-f $rollout_script_path) {
			my $install_rollout_cmd = "cd $rollout_dir_path && perl rollout.pl $rollout_filename_no_ext";	
			my $start = time();
			print "Installing..."; 
			print " start: " . strftime("%H:%M:%S", localtime());
			
			my $return_status;
			if($arg_dry_run == 1){
				$return_status = -1; 
			}else{
				system("$install_rollout_cmd >> $env_logfile 2>&1");
				$return_status = $? >> 8; 
			}

			my $finish = time();
			my $elapsed = $finish - $start;
			print " finish: " . strftime("%H:%M:%S", localtime()) . " ($elapsed seconds)\n";
			
			if($arg_dry_run == 1){
				print "Not installed (dry-run).";
			}elsif ($return_status == 0){
				print "The rollout has been installed successfully.";
			}elsif ($return_status == 1){
				print "An error occurred. Fix the errors and rerun.";
			}elsif ($return_status == 3){
				print "Rollout stopped, Requirement not met, see log for specific issue.";
				exit(-1);
			}elsif ($return_status == 2){
				print "Warnings occurred. Check the warnings and rerun if necessary.";
			}else{
				print "Unknown status. Check the log and rerun if necessary.";
			}
			
			print " (status: $return_status)\n";
			
			if($arg_create_db_backup == 1){
				backup_db_sqlserver($env_dbname, "$env_db_backup_dir/$env_dbname" . "_" . $rollout_filename_no_ext . ".bak");
			}

		}else{
			print "Unable to determine rollout script file.\n"
		}

		$rollout_counter++;
	}
}

sub change_to_environment{
	my ($change_to_environment_wh_id) = @_;

	print_header("CHANGE TO ENVIRONMENT");
	
	print "Changing to environment: $change_to_environment_wh_id\n";
	print "Checking for registry file: $env_registry_file.$change_to_environment_wh_id\n";
	
	if(-e "$env_registry_file.$change_to_environment_wh_id"){
		print "Copying environment registry file \"$env_registry_file.$change_to_environment_wh_id\" to active registry file \"$env_registry_file\"\n";
		copy("$env_registry_file.$change_to_environment_wh_id","$env_registry_file") or die "Copy failed: $!";
	}else{
		print "Did not find registry file for environment: $env_registry_file.$change_to_environment_wh_id\n";
	}
}

sub install_on_wh{
	my ($rollouts_dir, @rollouts_dir_rollouts_to_install_actual) =@_;
	my $restored_backup_rollout;
	
	if($arg_allow_db_backup == 1){		
		$restored_backup_rollout = restore_db_from_backup($env_db_backup_dir, $env_dbname, @rollouts_dir_rollouts_to_install_actual);
		if($restored_backup_rollout ne ""){
			if($arg_install_mode eq "from-rollout"){
				@rollouts_dir_rollouts_to_install_actual = sort(grep($_ gt $restored_backup_rollout, @rollouts_dir_rollouts_to_install_actual));
			}elsif($arg_install_mode eq "only-rollout"){
				@rollouts_dir_rollouts_to_install_actual = ();
			}
		}
	}

	install_rollouts($rollouts_dir, @rollouts_dir_rollouts_to_install_actual);
	print_header("Rollout on environment: $env_dbname is DONE");
}
# ------------------------------------------------------------------------------
# APPLICATION FUNCTIONS - END
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# APPLICATION START
# ------------------------------------------------------------------------------

# Set auto flushing of stdout and stderr.
STDOUT->autoflush(1);
STDERR->autoflush(1);
		   
my @rollouts_dir_files;
my @rollouts_dir_rollouts_to_install;
my @rollouts_dir_rollouts_to_install_actual;

check_cmd_arguments();
get_os_name();
check_environment();

opendir(my $dir, $env_rollouts_dir) or die("ack: $!");
@rollouts_dir_files = grep (/[^\.{1,2}]/, readdir $dir);
closedir $dir;

my @rollouts_dir_rollouts_found = grep(/.*(\.zip|\.tar\.gz|\.exe)/, @rollouts_dir_files);

my @rollout_names_found;
if($arg_rollout_name ne ""){
	@rollout_names_found = grep(/${arg_rollout_name}(\.zip|\.tar\.gz|\.exe)/, @rollouts_dir_files);
}

if($arg_install_mode eq "from-rollout" && $arg_install_types == 1){
	#limit list for specified type(s)
	#@A = grep(/\.DEV|FIX\./, @Array); 
	@rollouts_dir_rollouts_to_install = sort(grep($_ ge @rollout_names_found[0], @rollouts_dir_rollouts_found));
	@rollouts_dir_rollouts_to_install = sort(grep(/\.$arg_types_spec\./, @rollouts_dir_rollouts_to_install));
}elsif($arg_install_mode eq "from-rollout" && $arg_install_types != 1){
	#exclude default excluded types (TMP,RBK,BCK)
	@rollouts_dir_rollouts_to_install = sort(grep($_ ge @rollout_names_found[0], @rollouts_dir_rollouts_found));
	@rollouts_dir_rollouts_to_install = sort(grep(!/\.TMP|RBK|BCK\./, @rollouts_dir_rollouts_to_install));
}elsif($arg_install_mode eq "only-rollout"){
	@rollouts_dir_rollouts_to_install = sort(grep($_ eq @rollout_names_found[0], @rollouts_dir_rollouts_found));
}

if (scalar(@rollout_names_found) > 0){
	stop_services();

	@rollouts_dir_rollouts_to_install_actual = @rollouts_dir_rollouts_to_install;

	print_rollouts_summary(@rollout_names_found[0], scalar(@rollouts_dir_rollouts_found), scalar(@rollouts_dir_rollouts_to_install_actual), "", scalar(@rollouts_dir_rollouts_to_install_actual));
	#print_rollouts_summary(@rollout_names_found[0], scalar(@rollouts_dir_rollouts_found), scalar(@rollouts_dir_rollouts_to_install_actual), $restored_backup_rollout, scalar(@rollouts_dir_rollouts_to_install_actual));
	list_rollouts($env_rollouts_dir, @rollouts_dir_rollouts_to_install_actual);
	extract_rollouts($env_rollouts_dir, @rollouts_dir_rollouts_to_install_actual);

	if($arg_change_to_environment == 1){
		foreach my $wh_id ( split(/\|/, $arg_change_to_environment_wh_id))
		{
		change_to_environment($wh_id);
		check_environment();
		install_on_wh($env_rollouts_dir, @rollouts_dir_rollouts_to_install_actual);
		}
	}else{
		check_environment();
		install_on_wh($env_rollouts_dir, @rollouts_dir_rollouts_to_install_actual);
	}
	
	if($arg_start_service ne 0){
		start_services();
	}else{
		print "Service(s) not started\n"
	}

}else{
	print_rollouts_summary(@rollout_names_found[0], scalar(@rollouts_dir_rollouts_found), scalar(@rollouts_dir_rollouts_to_install_actual), "", scalar(@rollouts_dir_rollouts_to_install_actual));
	#print_rollouts_summary(@rollout_names_found[0], scalar(@rollouts_dir_rollouts_found), scalar(@rollouts_dir_rollouts_to_install_actual), $restored_backup_rollout, scalar(@rollouts_dir_rollouts_to_install_actual));
	print "Rollout not found.\n";
	exit(-1);
}