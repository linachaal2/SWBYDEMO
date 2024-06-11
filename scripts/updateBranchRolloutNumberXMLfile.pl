#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper qw(Dumper);
use Getopt::Std;



my $branchRolloutNumber;
my $rolloutSettingsFile;
my %opts = ();
my $vOutputFile;
#####################################################################
# show UpdateBranchRolloutNumber()
#####################################################################

sub UpdateBranchRolloutNumber {
	
print ("Update $rolloutSettingsFile to have $branchRolloutNumber\n" );
my $text =<<'XHTML';
<?xml version="1.0" encoding="utf-8" standalone="no"?>
<branch_rollout_number>000</branch_rollout_number>
XHTML

#$string =~ s/regex/replacement/g;

$text =~ s/(<branch_rollout_number>)(?:\d*)/$1.$branchRolloutNumber/e;
print ("$text\n" );
printf("File is opened for writing\n");
open($vOutputFile, ">$rolloutSettingsFile")or die "Could not open file  $!";;
print $vOutputFile $text;
close($vOutputFile);	

}#UpdateBranchRolloutNumber

#####################################################################
#####################################################################
# MAIN Updating BranchRolloutNumber.xml 
#####################################################################
#####################################################################
#<?xml version="1.0" encoding="utf-8" standalone="no"?>
#<branch_rollout_number>039</branch_rollout_number>



#get options

getopts('v:f:ohpm', \%opts);
#perl updateBranchRolloutNumberXMLfile.pl  -v BRANCHROLLOUTNB -f ./rollout_gen/generic/BranchRolloutNumber.xml

# get the arguments
$branchRolloutNumber = $opts{v} if defined($opts{v});#-v - required - branch rollout number
$rolloutSettingsFile = $opts{f} if defined($opts{f});#-b - required - GIT branch name

UpdateBranchRolloutNumber();
