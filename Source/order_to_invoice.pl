#!/usr/bin/perl

use DBI;
use warnings;
use strict;
use DateTime;
use DateTime::Format::DBI;
use Excel::Writer::XLSX;
use DB::Products;
use DB::Product;
use DB::SchemaBuilder;

use Parser::OrderParser;


sub usage {
    die "order_to_invoice [order_filename]";

}

my $dbh = DBI->connect("dbi:SQLite:dbname=p.db", "", "",
		       { RaiseError => 1});

$dbh->{AutoCommit} = 1;

my $sb = DB::SchemaBuilder->new($dbh);



my $order_filename = $ARGV[0];


if (!$order_filename) {
    usage();
}

my $order_parser = Parser::OrderParser->new();


$order_parser->open($order_filename);

my @ordered_items;

my $products = DB::Products->new($dbh);



if (!defined($products->lookup_by_item_no(40003))) {
    die "lookup not working";
}


while(!$order_parser->at_eof()) {

    my $order = $order_parser->get_order_info();

    my $item_no = $order->{pi}->get_item_no();

    if (defined($item_no)) {
	my $product = $products->lookup_by_item_no($item_no);

	if (defined($product)) {
	    $order->{pi}->set_department_no($product->get_department_no());
	}
    }
    
    
    if ($order->{qty}) {
	push @ordered_items, $order;
    }
    
    $order_parser->next();
}





@ordered_items = sort {
    my $a_depno = $a->{pi}->get_department_no();
    my $b_depno = $b->{pi}->get_department_no();
    

    if (defined($a_depno) && defined($b_depno)) {
	if ($a_depno == $b_depno) {
	    return $a->{pi}->get_description() cmp $b->{pi}->get_description();
	} else {
	    return $a_depno <=> $b_depno;
	    
	}
    } elsif (defined($a_depno) && !defined($b_depno)) {
	return -1;
    } elsif (defined($b_depno) && !defined($a_depno)) {
	return 1;
    } else {
	return $a->{pi}->get_description() cmp $b->{pi}->get_description();
    }
    

} @ordered_items;


$_ = $order_filename;
s/resnick_order/invoice/;
s/resnick-order/invoice/;


my $invoice_filename = $_;


if ($order_filename eq $invoice_filename) {
    die "invoice filename should not be the same as the order filename!";
}



my $workbook = Excel::Writer::XLSX->new($invoice_filename);


my $worksheet = $workbook->add_worksheet();


my $row = 0;


$worksheet->write($row, 0, "Datetime:");
$worksheet->write($row, 1, DateTime->now());

$row++;

$worksheet->write($row, 0, "Item #");
$worksheet->write($row, 1, "Description");
$worksheet->write($row, 2, "UPC");
$worksheet->write($row, 3, "Unit");
$worksheet->write($row, 4, "Quantity Received");
$worksheet->write($row, 5, "Cost per Unit");
$worksheet->write($row, 6, "Cost");

$row++;


my $old_depno;

foreach my $item (@ordered_items) {
    my $item_no = $item->{pi}->get_item_no();


    my $product = $products->lookup_by_item_no($item_no);


    my $depno = $product->get_department_no();

    if (defined($depno)) {
	if (!defined($old_depno) || $depno != $old_depno) {
	    $worksheet->write($row, 0, "Department:");
	    $worksheet->write($row, 1, $depno);
	    $old_depno = $depno;
	    $row++;
	}
    }

    my $qty_received = $item->{qty} * $product->get_unit();
    
    $worksheet->write($row, 0, $item_no);
    $worksheet->write($row, 1, $product->get_description());
    $worksheet->write($row, 2, $product->get_upc()?$product->get_upc()->str():"");
    $worksheet->write($row, 3, $product->get_unit());
    
    $worksheet->write($row, 4, $qty_received);

    
    $worksheet->write($row, 5, $product->get_unit_cost());
    $worksheet->write($row, 6, $product->get_cost());
    
    $row++;
}
