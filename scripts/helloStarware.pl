#!/usr/bin/perl 

# Modules used 
use strict; 
use warnings;
use File::Find;

# Print function 
print("Hello World\n"); 



my @content;
my @sorted;
#find( \&wanted, \&preprocess, '/y/Docker/tmp');
#find( { wanted => \&wanted, preprocess => \&preprocess}, '/y/Docker/tmp');
#find( {preprocess => \&preprocess,wanted => \&wanted,}, '/y/Docker/tmp');

#find({preprocess => \&before, wanted => \&when, postprocess => \&after}, '/y/Docker/tmp');
find({preprocess => \&before, wanted => \&when}, '/y/Docker/tmp');

sub before
  {
  print "Sorting files ";
  sort @_
  }

#sub after {print "Againnnnnn file! $File::Find::name "}

sub when { print "file! $File::Find::name " }
