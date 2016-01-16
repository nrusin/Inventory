#!/usr/bin/perl

use warnings;
use strict;
use Carp;
use DBI;

use DateTime::Format::DBI;
use DB::ReplenishmentsIterator;
use DB::Products;
use DB::Stockrooms;
use Core::ProductInfo;
use Data::Dumper;

package DB::Replenishments;

# Replenishments
sub new {
    my $class = shift;

    my $self = {
	dbh => shift
    };

    bless $self, $class;

}

# Replenishments
sub lookup_qty_sold_by_sku {
    my $self = shift;
    my $sku = shift;
    my $beginning_datetime = shift;


    my $sth;

    my $dbh = $self->{dbh};

    my $db_parser = DateTime::Format::DBI->new($dbh);



    my $beginning_datetime_str = $db_parser->format_datetime($beginning_datetime);
  


    $sth = $dbh->prepare("SELECT qty_sold
                             From Replenishments r, Replenishments_detail rd
                             WHERE r.id             = rd.master_replenishment_id AND
                                   r.begin_datetime = ? AND
                                   rd.SKU           = ?");


    $sth->bind_param(1, $beginning_datetime_str);
    $sth->bind_param(2, $sku);




    if (!$sth->execute()) {

	die "lookup_qty_sold_by_sku failed at execute!\n";

    }

    my $qty_sold;

    ($qty_sold) = $sth->fetchrow_array();


    return $qty_sold;

}

# Replenishments
sub lookup_qty_sold_by_upc {
    my $self = shift;
    my $upc = shift;
    my $beginning_datetime = shift;

    my $dbh = $self->{dbh};


    my $products = DB::Products->new($dbh);

    my $product = $products->lookup_by_upc($upc);


    if (!defined($product)) {
	return undef;
    }


    return $self->lookup_qty_sold_by_sku($product->get_sku(), $beginning_datetime);
}





# Replenishments
sub insert_replenishment {


}

# Replenishments
sub get_qty_sold_since_by_upc {
    my $self = shift;
    my $upc = shift;
    my $datetime = shift;

    my $products = Products->new($self->{dbh});


    my $product = $products->lookup_by_upc($upc);

    
    return $self->get_qty_sold_since_by_sku($product->get_sku(), $datetime);
}


# Replenishments
sub get_qty_sold_since_by_sku {
    my $self = shift;
    my $sku = shift;

    my $datetime_str = shift;

    my $dbh = $self->{dbh};

    my $db_parser = DateTime::Format::DBI->new($dbh);
    
    my $datetime = $db_parser->format_datetime($datetime_str);

    my $sth = $dbh->prepare("SELECT sum(rd.qty_sold) as sold_since
                             FROM Replenishments r, Replenishments_detail rd
                             WHERE r.id = rd.master_replenishment_id AND
                             r.end_datetime < ? AND
                             rd.SKU = ?");


    $sth->bind_param(1, $datetime, DBI::SQL_VARCHAR);
    $sth->bind_param(2, $sku, DBI::SQL_INTEGER);


    if (!$sth->execute()) {
	die "get_qty_sold_since failed at execute!\n";

    }


    my $sold_since;
    my $ss;

    while(($ss) = $sth->fetchrow_array()) {
	$sold_since = $ss

    }

    return $sold_since;
}

# Replenishments

sub begin_replenishment {
    my $self = shift;
    my $beginning_datetime = shift;
    my $ending_datetime = shift;
    my $stockroom = shift;
    
    my  $dbh = $self->{dbh};
    my $sth;

    my $db_parser = DateTime::Format::DBI->new($dbh);

    my $stockrooms = DB::Stockrooms->new($dbh);
    my $stockroom_id = $stockrooms->get_stockroom_id($stockroom->get_name());

    if (DateTime->compare($beginning_datetime, $ending_datetime) == 1) {
	die "Ending datetime must be after beginning datetime.";
    }
    
    $sth = $dbh->prepare("SELECT max(end_datetime)
                          FROM Replenishments
                          WHERE stockroom_id = ?");

    $sth->bind_param(1, $stockroom_id);

    if (!$sth->execute()) {
	die "begin_replenishment failed at execute!\n";
    }


    my $end_dt_max;
    my $end_dt_max_str;
    
    ($end_dt_max_str) = $sth->fetchrow_array();

    if (defined($end_dt_max_str)) {
	$end_dt_max = $db_parser->parse_datetime($end_dt_max_str);

	
	if ($beginning_datetime->delta_md($end_dt_max)->delta_days != 1) {

	    die "$beginning_datetime $end_dt_max -- A new replenishment\n".
                 "must be consecutive with prior replenishments\n" .
                 "last replenishment was $end_dt_max\n";
	}

    }



    my $beginning_datetime_str = $db_parser->format_datetime($beginning_datetime);
    my $ending_datetime_str = $db_parser->format_datetime($ending_datetime);



    $sth = $dbh->prepare("INSERT INTO Replenishments(id, begin_datetime, end_datetime,
                                      stockroom_id)
                             VALUES(NULL, ?, ?, ?)");



    $sth->bind_param(1, $beginning_datetime_str);
    $sth->bind_param(2, $ending_datetime_str);
    $sth->bind_param(3, $stockroom_id);
    
    if (!$sth->execute()) {
	die "begin_replenishment failed at execute!\n";

    }

    
    my $catalog = undef;
    my $schema = undef;
    my $table = "Replenishments";
    my $field = "id";

    my $replenishment_id = $dbh->last_insert_id($catalog, $schema, $table, $field);


    return $replenishment_id;
}

# Replenishments
sub insert_into {
    my $self = shift;

    my $replenishment_id = shift;
    my $replenishment_entry = shift;

    my $dbh = $self->{dbh};
    
    my $upc_str = $replenishment_entry->get_upc()->str();

    my $description = $replenishment_entry->get_description();
    my $price = $replenishment_entry->get_price();
    my $qty_sold = $replenishment_entry->get_qty_sold();
    my $depno = $replenishment_entry->get_depno();


   
    my $sth = $dbh->prepare("SELECT id
                             FROM Replenishments
                             WHERE id = ?");
    $sth->bind_param(1, $replenishment_id);

    if (!$sth->execute()) {
	die "insert into failed at execute!\n";
    }

    if (!$sth->fetchrow_array()) {
	die "replenishment_id must be a valid replenishment_id\n";
    }


    $sth = $dbh->prepare("SELECT SKU
                          FROM Products
                          WHERE upc = ?");

    $sth->bind_param(1, $upc_str);
    
    if (!$sth->execute()) {
	die "insert_into failed at execute!\n";

    }


    my $sku;
    ($sku) = $sth->fetchrow_array();


    if (!defined($sku)) {
	my $products = DB::Products->new($dbh);


	my $product_info = Core::ProductInfo->new();


	$product_info->set_price($price);
	$product_info->set_description($description);
	$product_info->set_upc(Core::Upc->new($upc_str));
	$product_info->set_department_no($depno);

	
	my $product = $products->insert($product_info);

	warn("Entering $description $upc_str $price $qty_sold into Product's database");


	$sku = $product->get_sku();
	     
    }


    if (defined($sku)) {

	my $product = DB::Product->new($dbh, $sku);


	# Update price from replenishment
	
	$product->set_price($price);
	    
	$sth = $dbh->prepare("INSERT INTO
                             Replenishments_detail(id, SKU, qty_sold, master_replenishment_id)
                             VALUES(NULL, ?, ?, ?)");


	$sth->bind_param(1, $sku);
	$sth->bind_param(2, $qty_sold);
	$sth->bind_param(3, $replenishment_id);


	if (!$sth->execute()) {
	
	    die "insert into failed at execute 2!\n";
	}

    } else {
	die "SKU should be defined";

    }

    

    
}


sub get_no_of_replenishments {
    my $self = shift;

    my $dbh = $self->{dbh};




    my $sth = $dbh->prepare("SELECT COUNT(*) 
                             FROM Replenishments");


    if (!$sth->execute()) {
	die "Execute failed in get_no_of_replenishments";

    }


    my ($no_of_replenishments) = fetchrow_array();


    return $no_of_replenishments;
}


sub get_iterator{
    my $self = shift;

    my $dbh = $self->{dbh};

    if (!defined($dbh)) {

	die "get_iterator called with out database handle!\n";

    }

    return ReplenishmentsIterator->new($dbh);

}




1
