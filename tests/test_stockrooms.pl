#!/usr/bin/perl -I ../Source

use warnings;
use strict;

use DB::Stockrooms;
use DB::SchemaBuilder;


use Test::More tests => 10;


my $dbh = DB::SchemaBuilder->connect_to_sqlite("test.db");

my $sb = DB::SchemaBuilder->new($dbh);

$sb->unbuild();
$sb->build();

sub test_stockrooms {
    my $stockrooms = DB::Stockrooms->new($dbh);


    my $si = $stockrooms->get_iterator();

    
    while(my $stockroom = $si->fetch()) {
	my $name = $stockroom->get_name();
	my $purpose = $stockroom->get_purpose();


	if ($purpose eq 'primary') {
	    is($name, 'Genco', 'primary equals Genco');
	} elsif($purpose eq 'secondary') {
	    is($name, 'Airport', 'secondary equals Airport');
	}
    }
    
}



test_stockrooms();

$dbh->commit();






