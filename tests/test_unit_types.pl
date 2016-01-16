#!/usr/bin/perl -I ../Source

use warnings;
use strict;

use DB::UnitTypes;

use Test::More tests => 3;
use DB::SchemaBuilder;


my $dbh = DB::SchemaBuilder->connect_to_sqlite("test.db");



my $sb = DB::SchemaBuilder->new($dbh);

$sb->unbuild();
$sb->build();



sub test_unit_type {
    my $unit_types = DB::UnitTypes->new($dbh);


    my @units = $unit_types->get_units();


    is($units[0], "pc(s)", 'check first unit');
    is($units[1], "box(s)", 'check second unit');
    is($units[2], "case-pack(s)", 'check third unit');
    
}





test_unit_type();


