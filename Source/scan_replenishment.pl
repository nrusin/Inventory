#!/usr/bin/perl

use warnings;
use strict;

use Parser::ReplenishmentParser;
use DB::Replenishments;
use DB::SchemaBuilder;

my $config_fn = "../config/config.cfg";
    
my $rp = Parser::ReplenishmentParser->new();

my $rfilename = $ARGV[0];


if (!defined($rfilename)) {
    print $0 . " <replenishment filename>\n";
    exit 0;
}



open(my $fh, '<', $config_fn) or die "Could not open config file!";



my $data_directory;
my $dbname;

while(my $line = <$fh>) {
    chomp $line;
    
    print "line = $line\n";
    
    if ($line =~ /Data Directory:\s*\"(.+)\"\s*$/) {
	$data_directory = $1;
    }
    
    if ($line =~ /DB Name:\s*\"(.+)\"\s*$/) {
       $dbname = $1;
   }
}

if (!defined($data_directory) || !defined($dbname)) {
    print "$data_directory  $dbname\n";
    die "Config file in wrong format!";
}

$rp->open($rfilename);


my $beginning_date = $rp->get_beginning_date();
my $ending_date = $rp->get_ending_date();

print "beginning_date = $beginning_date\n";
print "ending_date = $ending_date\n";



my $dbh = DBI->connect("dbi:SQLite:dbname=$data_directory/$dbname", "", "",
		       { RaiseError => 1});

$dbh->{AutoCommit} = 0;


my $sb = DB::SchemaBuilder->new($dbh);


my $replenishments = DB::Replenishments->new($dbh);


my $rid = $replenishments->begin_replenishment($beginning_date,
					       $ending_date);

while(!$rp->eof()) {
    my $re = $rp->get_replenishment_entry();

    if (defined($re->get_upc())) {
	$replenishments->insert_into($rid, $re);
    } else {
	warn("$re->get_description() does not have UPC: Cannot insert!");
    }

    $rp->next();
}

$dbh->commit();

