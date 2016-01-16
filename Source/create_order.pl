#!/usr/bin/perl

use DBI;
use warnings;
use strict;
use DateTime;
use DateTime::Format::DBI;
use Excel::Writer::XLSX;
use DB::Products;
use DB::Product;

my $db_filename = "../Data/p.db";


my $dbh;
my $pi;



$dbh = DBI->connect("dbi:SQLite:dbname=$db_filename", "", "",
		    {RaiseError => 1});


my $products = DB::Products->new($dbh);


$pi = $products->get_iterator();


my $product;

my $datenow = DateTime->now();

my $workbook = Excel::Writer::XLSX->new("resnick_order-" . 
					$datenow->year() . "-" .
					$datenow->month() . "-" . 
					$datenow->day() . ".xlsx");

my $worksheet = $workbook->add_worksheet();


my $row = 0;

$worksheet->write($row, 0, 'Item #');
$worksheet->write($row, 1, 'Quantity');
$worksheet->write($row, 2, 'Description');
$worksheet->write($row, 3, 'Unit');
$worksheet->write($row, 4, 'Case Pack');
$worksheet->write($row, 5, 'Cost');
$worksheet->write($row, 6, 'Unit Cost');
$worksheet->write($row, 7, 'Retail');
$worksheet->write($row, 8, 'Unit UPC');
$worksheet->write($row, 9, 'Price');
$worksheet->write($row, 10, 'Par');
$worksheet->write($row, 11, 'Qty on Hand');



$row++;
while($product = $pi->fetch_product()) {

    my $qty_on_hand = "";
    my $unit = "";
    my $par = "";
    my $eoq = "";
    my $case_pack = "";
    my $cost = "";
    my $unit_cost = "";
    my $retail = "";
    my $upc_str = "";
    my $price = "";
   

    my $description = $product->get_description();
    my $resnick_unit;


    $qty_on_hand = $product->get_qty_on_hand() 
	if defined($product->get_qty_on_hand());

    $unit        = $product->get_unit() if defined($product->get_unit());
#    $resnick_unit = $unit;
    
#    if ($description =~ /^MARL.*/ || $description =~ /^NEWPORT.*/
#	|| $description =~ /^CAMEL.*/) {
#	$resnick_unit *= 10;
	
#    }


    $par         = $product->get_par() if defined($product->get_par());
    $eoq         = $product->get_eoq() if defined($product->get_eoq());
    $case_pack   = $product->get_case_pack() if defined($product->get_case_pack());
    $cost        = $product->get_cost() if defined($product->get_cost());
    $unit_cost   = $product->get_unit_cost() if defined($product->get_unit_cost());
    $retail      = $product->get_retail() if defined($product->get_retail());
    $upc_str     = $product->get_upc()->str() if defined($product->get_upc());
    $price       = $product->get_price() if defined($product->get_price());


    if ($eoq eq "") {
	$eoq = $unit;
    }


    if ($par eq "") {


	$par = 0;
    }


    if ((!defined($par) || $par == 0) && $unit =~ m/\d+/ && $unit > 0) {
	my $avg_sold = $product->get_avg_sold();

	if (defined($avg_sold)) {
	    $par = $product->get_avg_sold() * 10 / $unit;

	}

    } 





    if ($unit eq "") {
	die "unit not defined at $description!\n" . $product->get_unit();
    }

    if ($qty_on_hand eq "") {
	die "qty_on_hand not defined at $description!\n";
    }

    my $qty_to_order = ($par * $unit - $qty_on_hand)/$unit;

    $qty_to_order = int($qty_to_order + 0.5);

    print "Ordering $description, qty_on_hand = $qty_on_hand, par = $par, order = $qty_to_order\n";


    $worksheet->write($row, 0, $product->get_item_no());
    
    if ($qty_to_order != 0) {
	$worksheet->write($row, 1, $qty_to_order);
    }

    $worksheet->write($row, 2, $description);
    $worksheet->write($row, 3, $unit);
    $worksheet->write($row, 4, $case_pack);
    $worksheet->write($row, 5, $cost);
    $worksheet->write($row, 6, $unit_cost);
    $worksheet->write($row, 7, $retail);
    $worksheet->write($row, 8, $upc_str);
    $worksheet->write($row, 9, $price);



    $worksheet->write($row, 10, $par);




    $worksheet->write($row, 11, $qty_on_hand);

    $row++;
}





