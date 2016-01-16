#!/usr/bin/perl
use strict;
use warnings;

my $first_file = $ARGV[0];

print "scan all replenishments\n";

my $directory = "../Data/replenishment_files";

opendir(DIR, $directory) or die "Could not open directory: $!";


my @files;

while(my $file = readdir(DIR)) {
    print "File = $file\n";
    
    if (($file =~ /\.xlsx$/)) {
	push @files, $file;
    }


}

@files = sort {return $a cmp $b}  @files;


my $begin_scan = 0;

$begin_scan = 1 if !defined($first_file);

foreach my $file (@files) {
    if (defined($first_file) && $file eq $first_file) {
	$begin_scan = 1;
    }
    
    my $fullpath = $directory . "/" . $file;
    print $fullpath . "\n";
    
    system("perl -I ./ scan_replenishment.pl $fullpath");
}



