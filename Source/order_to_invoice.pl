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
use DateTime::Format::Excel;

use Parser::OrderParser;

my $db_filename = "/home/nrusin/inventory/Data/p.db";

sub usage {
    die "order_to_invoice [order_filename]";

}


my $dbh = DB::SchemaBuilder->connect_to_sqlite($db_filename);

#my $dbh = DBI->connect("dbi:SQLite:dbname=$db_filename", "", "",
#		       { RaiseError => 1});

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


while(!$order_parser->at_eof()) {

    my $order = $order_parser->get_order_info();

    my $item_no = $order->{pi}->get_item_no();

    if (defined($item_no)) {
	my $product = $products->lookup_by_item_no($item_no);

	if (defined($product)) {
	    $order->{pi}->set_department_no($product->get_department_no());
	    $order->{pi}->set_description($product->get_description());
	    
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
	    my $cmpr = $a->{pi}->get_description() cmp $b->{pi}->get_description();
	    return $cmpr;
	} else {
	    return $a_depno <=> $b_depno;
	    
	}
    } elsif (defined($a_depno) && !defined($b_depno)) {
	return -1;
    } elsif (defined($b_depno) && !defined($a_depno)) {
	return 1;
    } else {
	my $cmpr = $a->{pi}->get_description() cmp $b->{pi}->get_description();
	
	return $cmpr;
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

my $datetime_format = $workbook->add_format();
$datetime_format->set_color('white');
$datetime_format->set_bg_color('orange');
$datetime_format->set_bold();

$worksheet->write($row, 0, "Datetime:", $datetime_format);


my $datetime = DateTime->now();
my $day_num = DateTime::Format::Excel->format_datetime($datetime);


my $date_format = $workbook->add_format();

$date_format->set_color('white');
$date_format->set_bg_color('orange');
$date_format->set_num_format('d mmm yyyy');

$worksheet->write($row, 1, $day_num, $date_format);

$row++;


my @fields = ["Quantity(by unit)", "Item #", "Description",
	      "UPC", "Unit", "Quantity Received(pcs)",
	      "Cost per Unit", "Cost", "SKU", "Price(pcs)", "Price(units)", "Cost Amount"];



my @qty_by_unit_sum_range = (0, 0);
my @qty_received_pcs_sum_range = (0, 0);
my @cost_sum_range = (0, 0);
my @price_sum_range = (0, 0);


my $qty_by_unit_sum = 0;

my $qty_received_pcs_sum = 0;
my $cost_sum = 0;
my $price_sum = 0;

	       
#$worksheet->write($row, 0, "Item #");
#$worksheet->write($row, 1, "Description");
#$worksheet->write($row, 2, "UPC");
#$worksheet->write($row, 3, "Unit");
#$worksheet->write($row, 4, "Quantity Received");
#$worksheet->write($row, 5, "Cost per Unit");
#$worksheet->write($row, 6, "Cost");
#$worksheet->write($row, 7, "SKU");

$row++;


my $old_depno;

my $item_index = 0;

my $sum_format = $workbook->add_format();

$sum_format->set_color('red');

my $sum_currency_format = $workbook->add_format();
$sum_currency_format->set_color('red');
$sum_currency_format->set_num_format('$0.00');

my $currency_format = $workbook->add_format();
$currency_format->set_num_format('$0.00');


my $department_format = $workbook->add_format();
$department_format->set_bg_color('green');
$department_format->set_bold();
$department_format->set_color('white');

my $field_format = $workbook->add_format();
$field_format->set_bg_color('blue');
$field_format->set_color('white');
$field_format->set_bold();

my $normal_format = $workbook->add_format();

foreach my $item (@ordered_items) {
    my $item_no = $item->{pi}->get_item_no();


    my $product = $products->lookup_by_item_no($item_no);


    my $depno = $product->get_department_no();

    if (defined($depno)) {
	if (!defined($old_depno) || $depno != $old_depno) {
	    $qty_by_unit_sum = 0;
	    $qty_by_unit_sum_range[0] = 'A' . ($row + 3);
	    $qty_received_pcs_sum_range[0] = 'F' . ($row + 3);
	    $cost_sum_range[0] = 'L' . ($row + 3);
	    $price_sum_range[0] = 'K' . ($row + 3);

	    $qty_received_pcs_sum = 0;

	    $cost_sum = 0;
	    $price_sum = 0;

	    
	    $worksheet->write($row, 0, "Department:", $department_format);
	    $worksheet->write($row, 1, $depno, $department_format);
	    $old_depno = $depno;

	    $row++;
	    
	    my $i = 0;
	    foreach my $field (@fields) {

		$worksheet->write($row, $i, $field, $field_format);
		$i++;
	    }
	    

	    $row++;
	}
    }

    if (!($item->{qty} =~ /\d+/)) {
	print "Qty is not numeric" . $item->{qty} . "\n";
	print $product->get_description() . "\n";
    }


    # qty received in pieces
    my $qty_received = $item->{qty} * $product->get_unit();


    my $qty_in_units = $qty_received/$product->get_unit();
    
    $worksheet->write($row, 0, $qty_in_units);
    
    $worksheet->write($row, 1, $item_no);
    $worksheet->write($row, 2, $product->get_description());
    $worksheet->write_string($row, 3, $product->get_upc()?$product->get_upc()->str():"");
    $worksheet->write($row, 4, $product->get_unit());
    
    $worksheet->write($row, 5, $qty_received);
    $worksheet->write($row, 6, $product->get_unit_cost(), $currency_format);
    
    $worksheet->write($row, 7, $product->get_cost(), $currency_format);

    
    $worksheet->write($row, 8, $product->get_sku());


    my $rp = $row + 1;
    my $price_amount;
    
    if (defined($product->get_price())) {    
	$worksheet->write($row, 9, $product->get_price(), $currency_format);

  

	$price_amount = $qty_received * $product->get_price();

	if ($depno == 4) {
	    $price_amount *= 10;

	    $worksheet->write_formula($row, 10, "= F$rp * J" . ($row * 10 + 1), 
				      $currency_format, $price_amount);
	} else {
	    $worksheet->write_formula($row, 10, "= F$rp * J$rp", $currency_format,
				      $price_amount);
	}
    } else {
	$price_amount = 0;
    }

    
#    $worksheet->write($row, 10, $price_amount, $currency_format);
    
    my $cost_amount = $product->get_cost() * $qty_in_units;

    $worksheet->write_formula($row, 11, "= (F$rp / E$rp) * H$rp", 
			      $currency_format, $cost_amount);
#    $worksheet->write($row, 11, $cost_amount, $currency_format);

    $qty_by_unit_sum += $qty_in_units;
    $qty_received_pcs_sum += $qty_received;
    
    $price_sum +=  $price_amount;
    $cost_sum += $cost_amount;
    
    $row++;

    
    my $next_item = $ordered_items[$item_index + 1];



    if ($next_item) {
	my $item_no = $next_item->{pi}->get_item_no();
	
	my $next_product = $products->lookup_by_item_no($item_no);
	if ($depno != $next_product->get_department_no()) {



	    $qty_by_unit_sum_range[1] = 'A' . $row;
	    $qty_received_pcs_sum_range[1] = 'F' . $row;
	    $cost_sum_range[1] = 'L' . $row;
	    $price_sum_range[1] = 'K' . $row;
	    
	    #	    $worksheet->write($row, 0, $qty_by_unit_sum, $sum_format);

	    $worksheet->write_formula($row, 0, 
				      "=SUM($qty_by_unit_sum_range[0]:$qty_by_unit_sum_range[1])",
				      $sum_format, $qty_by_unit_sum);

	    $worksheet->write_formula($row, 5,
				      "=SUM($qty_received_pcs_sum_range[0]:$qty_received_pcs_sum_range[1])",
				      $sum_format, $qty_received_pcs_sum);
	    
	#    $worksheet->write($row, 5, $qty_received_pcs_sum, $sum_format);

	    $worksheet->write_formula($row, 11,
				     "=SUM($cost_sum_range[0]:$cost_sum_range[1])",
				     $sum_currency_format, $cost_sum);
	    
	    #$worksheet->write($row, 11, $cost_sum, $sum_format);

	    $worksheet->write_formula($row,  10,
				     "=SUM($price_sum_range[0]:$price_sum_range[1])",
				     $sum_currency_format, $price_sum);
	    
	    #$worksheet->write($row, 10, $price_sum, $sum_format);

	    $row += 2;
	}
    }
	


    $item_index++;
}
