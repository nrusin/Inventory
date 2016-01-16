#!/usr/bin/perl

use warnings;
use strict;

use Parser::ReplenishmentParser;
use DB::Replenishments;
use DB::SchemaBuilder;
use DB::Stockroom;

my $rp = Parser::ReplenishmentParser->new();

my $rfilename = $ARGV[0];
my $db_filename = "/home/nrusin/inventory/Data/p.db";

if (!defined($rfilename)) {
    print $0 . " <replenishment filename>\n";
    exit 0;
}


$rp->open($rfilename);


my $beginning_date = $rp->get_beginning_date();
my $ending_date = $rp->get_ending_date();

print "beginning_date = $beginning_date\n";
print "ending_date = $ending_date\n";



my $dbh = DB::SchemaBuilder->connect_to_sqlite($db_filename);



my $sb = DB::SchemaBuilder->new($dbh);

$sb->build();

my $replenishments = DB::Replenishments->new($dbh);


my $rid = $replenishments->begin_replenishment($beginning_date,
					       $ending_date, DB::Stockroom->new("Airport"));

while(!$rp->eof()) {
    my $re = $rp->get_replenishment_entry();

    $_ = $re->get_description();

    if (defined($re->get_upc())) {
	$replenishments->insert_into($rid, $re);
    } else {
	warn "upc not defined for " . $re->get_description() . "\n";
    }


    $rp->next();
}

$dbh->commit();

