#!/usr/bin/perl


use strict;
use warnings;


require 'parser.pl';




my $parser = new ProductInfoParser;


print "testing parser" . "\n";

$parser->open("PRODUCT_LIST.xlsx");

while (!$parser->eof()) {

    my $pi = $parser->get_product_info();

    printf("%6s, %-60s, %14s\n", $pi->get_item_no(), $pi->get_description(), $pi->get_upc());

#    $pi->get_item_no() . "\t" . $pi->get_description() . "\t" . $pi->get_upc() . "\n";
    $parser->next();
}

my $rp = ReplenishmentParser->new();

$rp->open("replenishment.xlsx");


while(!$rp->eof()) {
    my $re = $rp->get_replenishment_entry();


    my $price = $re->get_price();
    my $upc = $re->get_upc();
    my $description = $re->get_description();
    my $qty_sold = $re->get_qty_sold();


    if (!defined($price)) {
	print "Undefined price\n";
	$price = "";
    }


    if (!defined($upc)) {
	print "Undefined upc\n";
	$upc = "";
    }

    if (!defined($description)) {
	print "Undefined description\n";
	$description = "";
    }

    if (!defined($qty_sold)) {
	print "Undefined qty sold\n";
	$qty_sold = "";
    }

    printf ("%-64s, %14s, %6s\n", $description, $upc->str(), $qty_sold);
    $rp->next();



    $parser->reset();



    print "BEGIN UPC Search\n";

    while(!$parser->eof()) {
	my $prod_entry = $parser->get_product_info();

	my $pdesc = $prod_entry->get_description();
	my $pupc = $prod_entry->get_upc();

	
	$rp->reset();
	while(!$rp->eof()) {
	    my $re = $rp->get_replenishment_entry();

	    my $rdesc = $re->get_description();
	    my $rupc = $re->get_upc();

	    
	    if ($pupc eq $rupc) {
		print $pdesc . ", " . $rdesc . ", " .  $pupc . ", " . $rupc . "\n";

	    }


	    $rp->next();
	}


	
	$parser->next();
    }

}


