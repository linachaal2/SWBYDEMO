#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper qw(Dumper);
use Getopt::Std;
use lib "./scripts";
use Cwd;
use File::Path;
#use File::Path qw(make_path);
use File::Path qw(make_path remove_tree);
use File::Spec::Functions;
use Text::ParseWords;
use IPC::Open2;
use File::Basename;
use File::Copy;
use File::Find;
use Time::localtime;
#use Text::Trim;
#use XML::Parser;

#use XML::Simple;
#use XML::DOM;
use XML::LibXML;
#use Meta::Math::Pad;

my $git_branch_name ;
my $rolloutSettingsFile;
my %opts = ();

#####################################################################
#####################################################################
# MAIN Parsing XML 
#####################################################################
#####################################################################

#get options

getopts('b:f:ohpm', \%opts);
#perl parseXMLfile.pl  -b GITBRANCH -f ./rollout_gen/generic/rollout_settings.xml

# get the arguments
$git_branch_name = $opts{b} if defined($opts{b});#-b - required - GIT branch name
$rolloutSettingsFile = $opts{f} if defined($opts{f});#-b - required - GIT branch name

print $git_branch_name;

print "Parsing XML \n";

#my $filename = 'BranchRolloutNumber.xml';
#$rolloutSettingsFile = 'rollout_settings.xml';

my $dom = XML::LibXML->load_xml(location => $rolloutSettingsFile);

#Validate the XML file 
#print $dom;
my $rollout_settings = $dom->documentElement;

#Get the Highest_Rollout_Number 
my ($paths)=  $rollout_settings->getChildrenByTagName('paths');
my ($Highest_Rollout_Number)=  $paths->getChildrenByTagName('dir_db_upgrade_rollout_number');
print "-------------------Highest_Rollout_Number------------------------\n";
#print $Highest_Rollout_Number->findvalue();
print $Highest_Rollout_Number->to_literal();
print "\n-----------------------------------------------------------------\n";
print "------------------- New Highest_Rollout_Number--------------------\n";
#my($padded)=Meta::Math::Pad::pad($new_rollout_number,3);
my($new_rollout_number) = sprintf("%03d", $Highest_Rollout_Number->to_literal()+1);
print $new_rollout_number;
print "\n-----------------------------------------------------------------\n";
my($branches) = $rollout_settings->getChildrenByTagName('branches');
my $branche_info = $dom->createElement('branche-info'); 
my $branche_name = $dom->createElement('branche-name'); 
my $branche_rol = $dom->createElement('branche-rol'); 
$branche_name->appendText($git_branch_name); 
$branche_rol->appendText($new_rollout_number); 
$branche_info->appendChild($branche_name);
$branche_info->appendChild($branche_rol);
$branches->appendChild($branche_info);
#Add indentation
foreach ($dom->findnodes('//text()')) { $_->parentNode->removeChild($_) unless /\S/;
}
#print $dom->toString(1);

$Highest_Rollout_Number->removeChildNodes();
$Highest_Rollout_Number->appendText($new_rollout_number);
print $dom->toString(1);
#foreach my $highestRolloutNumber ($dom->findnodes('/rollout_settings/paths/dir_db_upgrade_rollout_number')) {
#    print $highestRolloutNumber->to_literal();
#}

#my $parser = XML::LibXML->new;
#my $doc = $parser->parse_file("myrollout_settingstest.xml");
#my $root = $doc->getDocumentElement();my $record = $dom->documentElement;

#my $new_element= $doc->createElement("element4");
#$new_element->appendText('testing');

#$root->appendChild($new_element);

#print $root->toString(1
return $new_rollout_number;