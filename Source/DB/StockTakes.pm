#!/usr/bin/perl

use DBI;
use warnings;
use strict;
use DateTime;
use DateTime::Format::DBI;
use Core::StockTakeInfo;
use DB::Products;


package DB::StockTakes;

sub new {
    my $class = shift;

    my $self = {
	dbh => shift

    };


    bless $self, $class;

}


sub get_last_stock_take_by_upc {
    my $self = shift;
    my $upc = shift;

    my $products = Products->new($self->{dbh});

    my $product = $products->lookup_by_upc($upc);

    if (!defined($product)) {
	Carp::confess("get_last_stock_take_by_upc lookup by upc failed!\n");
    }


    my $sku = $product->get_sku();

    print "sku = $sku at get_last_stock_take_by_upc\n";

    return $self->get_last_stock_take_by_sku($sku);
}


sub get_last_stock_take_by_sku {
    my $self = shift;
    my $sku = shift;
    
    my $dbh = $self->{dbh};
    my $db_parser = DateTime::Format::DBI->new($dbh);

    my $date_of_st;

    my $sth = $dbh->prepare("SELECT MAX(st.datetime_counted)
                   FROM Stock_takes st, Stock_takes_detail sd
                   WHERE st.id = sd.master_id AND
                         sd.SKU = ?");

    $sth->bind_param(1, $sku);
    
    if (!$sth->execute()) {
	die "get_last_stock_take failed at execute!\n";
    }

    my $the_datetime;


    ($the_datetime) = $sth->fetchrow_array();


    my %stock_take;
    
    if (!defined($the_datetime)) {
	$stock_take{sku} = undef;
	$stock_take{qty_counted} = undef;
	$stock_take{datetime} = undef;
	
	return %stock_take;
    } else {
	print "Date = " . $the_datetime . "\n";
    }


    $date_of_st = $db_parser->parse_datetime($the_datetime);

    $sth = $dbh->prepare("SELECT SKU, qty_counted
                          FROM Stock_takes st, Stock_takes_detail sd
                          WHERE st.id = sd.master_id AND
                                sd.SKU = ? AND st.datetime_counted = ?");

    $sth->bind_param(1, $sku, DBI::SQL_INTEGER);
    $sth->bind_param(2, $the_datetime, DBI::SQL_VARCHAR);

    print "SKU = " . $sku .  "\n";
    print "the_datetime = " . $the_datetime . "\n";

    if (!$sth->execute()) {
	die "get_last_stock_failed at execute!\n";
    }


    my $qty_counted;
    my $s;
    my $qty;

    while(($s, $qty) = $sth->fetchrow_array()) {
	$sku = $s;
	$qty_counted = $qty;
    }

    if (!defined($qty_counted)) {
	return undef;
    }


    $stock_take{sku} = $sku;
    $stock_take{qty_counted}  = $qty_counted;
    $stock_take{datetime} = $date_of_st;


    return %stock_take;
}


sub begin_stock_take {
    my $self = shift;

    my $datetime = shift;


    my $dbh = $self->{dbh};

    my $db_parser = DateTime::Format::DBI->new($dbh);



    my $datetime_str = $db_parser->format_datetime($datetime);

    my $sth = $dbh->prepare("INSERT INTO Stock_takes(id, datetime_counted)
                             VALUES(NULL, ?)");
    
    $sth->bind_param(1, $datetime);


    if (!$sth->execute()) {
	die "begin_stock_take failed at execute!\n";

    }

    my $catalog = undef;
    my $schema = undef;
    my $table = "Stock_takes";
    my $field = "id";

    my $stock_take_id = $dbh->last_insert_id($catalog, $schema, $table, $field);

    
    return $stock_take_id;
}


sub insert_into {
    my $self = shift;
    my $stock_take_id = shift;
    my $stock_take_info = shift;


    my $dbh = $self->{dbh};
    


    my $upc = $stock_take_info->get_upc();

#    print "upc = " . $upc->str() . "\n";
#    print "UPC = " . $stock_take_info->get_upc()->str() . "\n";




    my $products = DB::Products->new($dbh);
    my $product = $products->lookup_by_upc($upc);
    

    if (!defined($product)) {

	Carp::confess("insert_into failed: " . $upc->str() . " not in product database!\n");

    }


    my $sku = $product->get_sku();

    my $qty_counted = $stock_take_info->get_qty_counted();


    my $sth = $dbh->prepare("SELECT unit FROM Products WHERE SKU = ?");

    $sth->bind_param(1, $sku);

    if (!$sth->execute()) {
	die "insert_into failed at execute!\n";
    }
    

    my ($unit) = $sth->fetchrow_array();


    my $qty_counted_in_units = defined($unit) && $unit > 0? $qty_counted * $unit : $qty_counted;

    

    $sth = $dbh->prepare("INSERT INTO Stock_takes_detail(id, master_id, SKU, qty_counted)
                             Values(NULL, ?, ?, ?)");




    $sth->bind_param(1, $stock_take_id);
    $sth->bind_param(2, $sku);
    $sth->bind_param(3, $qty_counted_in_units);


    if (!$sth->execute()) {

	die "insert_into failed at execute!\n";
    }


}

1
