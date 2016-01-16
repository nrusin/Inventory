#!/usr/bin/perl -I ../Source


use warnings;
use strict;

use Test::More tests => 19;

use Core::ReplenishmentEntry;

use Core::ProductInfo;
use Core::InvoiceInfo;

use DB::Product;
use DB::Products;
use DB::SchemaBuilder;
use DB::Replenishments;
use DB::Stockroom;
use DB::Invoices;
use DB::Transfers;

use DateTime;

use Parser::ProductInfoParser;



#my $dbh = DB::SchemaBuilder->connect_to_sqlite("test.db");

my $dbh = DBI->connect("dbi:SQLite:dbname=../Data/test.db", "", "",
		       { RaiseError => 1});

$dbh->{AutoCommit} = 1;


sub build_product_db {   
    my $sb = DB::SchemaBuilder->new($dbh);
    
    $sb->unbuild();
    $sb->build();
    
    my $products = DB::Products->new($dbh);
    
    my $parser = Parser::ProductInfoParser->new();
    $parser->open("TEST_PRODUCT_LIST.xlsx");
    
    
    while(!$parser->at_eof()) {
	my $product_info = $parser->get_product_info();
	
	$products->insert($product_info);
	
	$parser->next();

    }
}


sub test_1 {
    my $replenishments = DB::Replenishments->new($dbh);



    my $beginning_datetime = DateTime->new({year=>2016, month=>1, day=>3});
    my $ending_datetime = DateTime->new({year=>2016, month=>1, day=>3});

    my $rid = $replenishments->begin_replenishment($beginning_datetime,
						  $ending_datetime,
						  DB::Stockroom->new("Airport")
	);


    my $re = Core::ReplenishmentEntry->new("014054030715",
					   10.00,
					   "odwalla mango",
					   101);


    my $products = DB::Products->new($dbh);
    
    my $product = $products->lookup_by_upc(Core::Upc->new("014054030715"));
    is($product->get_sku(), 1, 'check sku');
    is($product->get_upc()->str(), '014054030715', 'check upc');
    is($product->get_description(),'ODWALLA MANGO PROTEIN 15.2Z  !',
       'check description'
	);
    
    
	
    is($product->get_qty_sold(), 0);
    is($product->get_qty_sold_since($ending_datetime), 0);
    is($product->get_qty_sold_since(DateTime->new({year=>2016, month=>1, day=>2})),
       0);

    is($product->get_qty_sold_since(DateTime->new({year=>2016, month=>1, day=>4})),
       0);
    
    is($product->get_qty_sold_by_stockroom(DB::Stockroom->new("Airport")), 0);

    $replenishments->insert_into($rid, $re);



    $dbh->commit();
    

    is($product->get_qty_sold(), 101);
    is($product->get_qty_sold_since($ending_datetime), 101);
    is($product->get_qty_sold_since(DateTime->new({year=>2016, month=>1, day=>4})),
       0);
    
    is($product->get_qty_sold_by_stockroom(DB::Stockroom->new("Airport")), 101);


    is($product->get_qty_sold_by_stockroom_since(DB::Stockroom->new("Airport"),
						 $ending_datetime), 101);

    is($product->get_qty_received(), 0);

    
    is($product->get_qty_received_since($ending_datetime), 0);


    is($product->get_qty_received_by_stockroom(DB::Stockroom->new("Airport")), 0);
    
    is($product->get_qty_received_by_stockroom_since(DB::Stockroom->new("Airport"),
						     DateTime->new({year=>2016,
								    month=>1,
								    day=>2}) ), 0);

    
						     

    is($product->get_qty_on_hand(DB::Stockroom->new("Airport")), -101);
    is($product->get_qty_on_hand_at_stockroom(DB::Stockroom->new("Airport")), -101);
       

	
    $product->get_avg_sold();

    

   

}


sub match_integer {
    my $line = shift;
    my $field = shift;
    my $num;

    my $regex = '^\s*' . $field . '\s*(-?\d+)\s*$';


    if ($line =~ m/$regex/) {
	$num  = $1;
    }

    
    return $num;
}


sub match_datetime {
    my $line = shift;
    my $field = shift;
    

    my $datetime;

    my $regex = '^\s*' . $field . '\s*(\d+)\/(\d+)\/(\d+)\s*$';

    
    if ($line =~ m/$regex/) {
	$datetime = DateTime->new({month=>$1,
				   day => $2,
				   year => $3});

	
    } 


    return $datetime;
}

sub match_string {
    my $line = shift;
    my $field = shift;

    my $s;

    my $regex = '^\s*' . $field . '\s*(\w+)\s*$';

    if ($line =~ m/$regex/) {
	$s = $1;

    }



    return $s;
}






sub test_2 {
    my $fh;


    if (!open($fh, "<", "test_product.info")) {
	die "Could not open file: $!";
    }


    my $products = DB::Products->new($dbh);
    
    my $product = $products->lookup_by_upc(Core::Upc->new("014054030715"));
    
    my $invoices = DB::Invoices->new($dbh);
    my $replenishments = DB::Replenishments->new($dbh);
    my $stocktakes = DB::StockTakes->new($dbh);
    my $transfers = DB::Transfers->new($dbh);
    

    my $lineno = 0;

    my $state = "scan line";
    my $stockroom;
    my $beginning_datetime;
    my $ending_datetime;
    my $stockroom_from;
    my $stockroom_to;
    my $qty_on_hand;
    my $datetime;
    my $qty_transfered;
    my @sold;
    my @received;
    
    while(my $line = readline($fh)) {
	chomp($line);
	$lineno++;

	if ($lineno == 86) {
	    print "$line\n";

	}
	
	if ($line =~ /^\s*begin replenishment\s*$/) {
	    $state = "begin_replenishment";
	    $stockroom = undef;
	    $beginning_datetime = undef;
	    $ending_datetime = undef;
	    @sold = ();
	} elsif ($line =~ /^\s*begin stocktake\s*$/) {
	    $state = "begin_stocktake";
	    $stockroom = undef;
	    $datetime = undef;
	    $qty_on_hand = undef;
	} elsif ($line =~ /^\s*begin invoice\s*$/) {
	    $state = "begin_invoice";
	    $stockroom = undef;
	    $datetime = undef;
	    @received = ();
	} elsif ($line =~ /^\s*begin transfer\s*$/) {
	    $state = "begin_transfer";

	    $stockroom_from = undef;
	    $stockroom_to = undef;
	    $qty_transfered = undef;
	    $datetime = undef;
	} elsif ($state eq "begin_transfer") {
	    if (my $s = match_string($line, "stockroom_from:")) {
		$stockroom_from = $s;
	    } elsif (my $ss = match_string($line, "stockroom_to:")) {
		$stockroom_to = $ss;
	    } elsif (my $n = match_integer($line, "qty_transfered:")) {
		$qty_transfered = $n;
	    } elsif (my $dt = match_datetime($line, "datetime:")) {
		$datetime = $dt;
	    } elsif ($line =~ m/^\s*end transfer\s*$/) {

		die "both stockrooms equal" if $stockroom_from eq $stockroom_to;
		
		my $tid = $transfers->begin_transfer(DB::Stockroom->new($stockroom_from),
						     DB::Stockroom->new($stockroom_to),
						     $datetime);
		

		$transfers->insert_into($tid,
					$product->get_sku(),
					$qty_transfered);

		$state = "scan_line";
	    }

	} elsif ($state eq "begin_invoice") {
	    if (my $s = match_string($line, "stockroom:")) {
		$stockroom = $s;
	    } elsif (my $dt = match_datetime($line, "datetime:")) {

		$datetime = $dt;
		
	    } elsif (my $qr = match_integer($line, "qty_received:")) {
		push @received, $qr;
	    } elsif ($line =~ /^\s*end invoice\s*$/) {
		my $invoice_id = $invoices->begin_invoice($datetime, 1);


		foreach my $received_amnt (@received) {
		    my $invoice_info = Core::InvoiceInfo->new();
		    $invoice_info->set_sku($product->get_sku());
		    $invoice_info->set_qty_received($received_amnt);
		
		
		    $invoices->insert_into($invoice_id, $invoice_info);
		}
		
		$state = "scan_line";
	    }
       
	} elsif($state eq "begin_stocktake") {
	    if ($line =~ /^\s*stockroom:\s*(\w+)\s*$/) {
		$stockroom = $1;
	    } elsif (my $d = match_datetime($line, "datetime:")) {
		$datetime = $d;
	    } elsif (my $q = match_integer($line, "qty_on_hand:")) {
		$qty_on_hand = $q;
	    } elsif ($line =~ /^\s*end stocktake\s*$/) {
		my $sid = $stocktakes->begin_stock_take($datetime,
							DB::Stockroom->new($stockroom));

		my $stock_take_info = Core::StockTakeInfo->new();

		print "seting stocktake quantity = $qty_on_hand!\n";
		
		$stock_take_info->set_qty_counted($qty_on_hand);
		$stock_take_info->set_upc($product->get_upc());
		$stocktakes->insert_into($sid, $stock_take_info);
		
		$state = "scan_line";
	    }
	    
	    


	} elsif ($state eq "begin_replenishment") {
	    if (my $s = match_string($line, "stockroom:")) {
		$stockroom = $s;
	    } elsif (my $begin_d = match_datetime($line, "beginning:")) {
		$beginning_datetime = $begin_d;
	    } elsif (my $end_d = match_datetime($line, "ending:")) {
		$ending_datetime = $end_d;
		
	    } elsif (my $n = match_integer($line, "sold:")) {
		push @sold, $n;
	    } elsif ($line =~ /^\s*end replenishment\s*$/) {
		my $rid = $replenishments->begin_replenishment($beginning_datetime,
							       $ending_datetime,
							       DB::Stockroom->new($stockroom));

							      

		foreach my $sold_item (@sold) {
		    my $re = Core::ReplenishmentEntry->new("014054030715",
							   10.00,
							   "odwalla mango",
							   $sold_item);


		
		    $replenishments->insert_into($rid, $re);
		}
		
		$state = "scan_line";
	    }
	    
	    

	} 


	if ($line =~ /^\s*E\(qty_on_hand\):\s*(-?\d+)\s*$/) {
	    my $expected_qty_on_hand = $1;

	    is($product->get_qty_on_hand(), $expected_qty_on_hand,
	       "check qty at hand test_product.info:$lineno");

	} elsif ($line =~ /^\s*E\(qty_on_hand_at_airport\):\s*(-?\d+)\s*$/) {
	    my $expected_qty_at_hand_airport = $1;


	    is($product->get_qty_on_hand_at_stockroom(DB::Stockroom->new("Airport")),
	       $expected_qty_at_hand_airport,
	       "check test_product.info:$lineno");
						       
	} elsif ($line =~ /^\s*E\(qty_on_hand_at_genco\):\s*(-?\d+)\s*$/) {
	    my $expected_qty_at_hand_genco = $1;


	    is($product->get_qty_on_hand_at_stockroom(DB::Stockroom->new("Genco")),
	       $expected_qty_at_hand_genco,
	       "check test_product.info:$lineno");
	    

	}

	if ($lineno == 78) {

	    die "at 78";
	}
	
	
    }
    
    


}



#build_product_db();
#test_1();


build_product_db();



test_2();



$dbh->commit();

