#!/usr/bin/perl
use strict;
use warnings;

require 'core.pl';




sub test_replenishment_entry {
    my $re = new ReplenishmentEntry();


    $re->set_qty_sold(20);
    $re->set_price(33.30);
    $re->set_description("Cheez Its");


    if ($re->get_qty_sold() != 20) {

	die "re->get_qty_sold() != 20";

    }
    

    if ($re->get_price() != 33.30) {
	die "re->get_price() != 33.30";
    }


    if ($re->get_description() ne "Cheez Its") {
	die "re->get_description() != Cheez Its";

    }


    print "Test replenishment succeeded!\n";
}



if (!test_is_number()) {
    print "test_is_number failed!\n";

} else {
    print "test is_number succeeded!\n";
}

if (!test_is_floating_pt()) {
    print "test_is_floating_pt failed!\n";
} else {
    print "test_is_floating_pt succeeded!\n";
}

test_upc();

test_replenishment_entry();
