#!/usr/bin/perl
use strict;
use warnings;


my $directory = "../Data/replenishment_files/";
my $src_directory = ".";
my $scanner = "$src_directory/scan_replenishment.pl";

my $perl_exec = "perl -I $src_directory/ $scanner ";

opendir(DIR, $directory) or die $!;


my @files;

while(my $file = readdir(DIR)) {
    if ($file =~ /.*\.xlsx$/) {
	push @files, $file;
    }

}

@files = sort {return $a cmp $b}  @files;

my $cnt = 0;

foreach my $file (@files) {
    my $full_path = "\"" . $directory . $file . "\"";
    my $cmd = "$perl_exec  $full_path";
    print $cmd . "\n";
    system($cmd);

}


