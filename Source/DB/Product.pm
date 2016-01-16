#!/usr/bin/perl

# Product.pm
#
# Author: Nicholas Rusinko
# Email:  nicholas.rusinko@gmail.com
#
#


use warnings;
use strict;
use Carp;
use DateTime::Format::DBI;
use Core::ProductInfo;
use Core::Upc;
use Data::Dumper;
use DB::StockTakes;
use DB::Stockroom;
use DB::Stockrooms;

package DB::Product;


# Product
sub make_product_with_info {
#    print "array size = " . scalar(@_) . "\n";

    my $class = shift;
    my $dbh = shift;
    my $product_info = shift;

    if (!defined($product_info)) {
	die "Product info not defined!\n";
    }


    my $sth = $dbh->prepare("INSERT INTO Products(SKU,
                                                  upc,
                                                  description, 
                                                  unit,
                                                  case_pack,
                                                  dep_no,
                                                  cost,
                                                  unit_cost,
                                                  par,
                                                  item_no,
                                                  category_id,
                                                  loc,
                                                  units_in_bx,
                                                  price,
                                                  eoq)
                             VALUES(NULL, ?, ?, ?, ?, ?, ?,
                                    ?, ?, ?, ?, ?, ?, ?, ?)");


    if ($product_info->get_upc()) {
	$sth->bind_param(1, $product_info->get_upc()->str(), DBI::SQL_VARCHAR);
    } else {
	$sth->bind_param(1, undef);

    }


    $sth->bind_param(2, $product_info->get_description());
    $sth->bind_param(3, $product_info->get_unit());
    $sth->bind_param(4, $product_info->get_case_pack());
    $sth->bind_param(5, $product_info->get_department_no());
    $sth->bind_param(6, $product_info->get_cost());
    $sth->bind_param(7, $product_info->get_unit_cost());
    $sth->bind_param(8, $product_info->get_par());
    $sth->bind_param(9, $product_info->get_item_no());
    $sth->bind_param(10, $product_info->get_category_id());
    $sth->bind_param(11, $product_info->get_location());
    $sth->bind_param(12, $product_info->get_units_in_bx());
    $sth->bind_param(13, $product_info->get_price());
    $sth->bind_param(14, $product_info->get_eoq());



    if (!$sth->execute()) {
	die "make_product_with_info failed at execute!\n";
    }
}

# Product
sub make_product {
    my $class = shift;

    my $dbh = shift;

    my $sth;


    $sth = $dbh->prepare("INSERT INTO Products(SKU) VALUES (NULL)");


    $sth->execute();


    
    my $catalog = undef;
    my $schema = undef;
    my $table = "Products";
    my $field = "SKU";
    my $sku = $dbh->last_insert_id($catalog, $schema, $table, $field);




    return $sku;
}

# Product
sub new {
    my $class = shift;

    my $self = {
	dbh => shift,
	sku => shift

    };
    

    bless $self, $class;
}

# Product
sub get_sku {
    my $self = shift;

    return $self->{sku};

}

#sub set_sku {
#    my $sku = shift;

#
#    $self->{sku} = $sku;
#}



# Product
sub set_description {
    my $self = shift;
    my $description = shift;

    my $dbh = $self->{dbh};
    my $sku = $self->{sku};

    

    if (!defined($description) || $description eq "") {
	die "Invalid description";
    }


    if (!defined($dbh)) {
	die "dbh must be defined\n";
    }

    my $sth = $dbh->prepare("UPDATE Products
                             SET description = ?
                             WHERE SKU = ?");


    $sth->bind_param(1, $description);
    $sth->bind_param(2, $sku);

    if (!$sth->execute()) {
	die "set_description failed!\n";
	
    }
   

}



# Product
sub get_description {
    my $self = shift;

    my $dbh = $self->{dbh};
    my $sku = $self->{sku};

    my $sth = $dbh->prepare("SELECT description
                   FROM Products
                   WHERE SKU = ?");


    $sth->bind_param(1, $sku);

    if (!$sth->execute()) {
	die "Product::get_description failed\n";
	
    }

    my $desc;



# Should run once
    my $description;

    while(($description) = $sth->fetchrow_array()) {
	$desc = $description;
    }


    return $desc;
    
}

# Product
sub get_stock_take {
    my $self = shift;
    my $dbh = $self->{dbh};
    my $sku = $self->{sku};
    my $sth;
    my @result;


    $sth = $dbh->prepare("SELECT MAX(st.datetime_counted)
                          FROM Stock_takes st, Stock_takes_detail std
                          WHERE st.id = std.master_id AND std.SKU = ?");


    $sth->bind_param(1, $sku);


    if (!$sth->execute()) {
	die "get_stock_take failed\n";
	
    }


    my $st_datetime;

    while(($st_datetime) = $sth->fetchrow_array()) {



    }
    

    if (defined($st_datetime)) {

		$sth = $dbh->prepare("SELECT SKU, qty_counted, datetime_counted
        	                      FROM Stock_takes st, Stock_takes_detail std
            	                  WHERE st.datetime_counted = ? AND st.id = std.master_id");


		if (!$sth->execute()) {	
	
		    die "get_stock_take failed!\n";
		}
	
		
		my $qty_counted;
		my $datetime_counted;
		my $st_sku;
	
		while(($st_sku, $qty_counted, $datetime_counted) = $sth->fetchrow_array()) {
		    @result = ($st_sku, $qty_counted, $datetime_counted);
	
		}

    }


    return @result;
}


# Product::get_qty_transfered_to_since
#
# Retrieve the quantity transfered after a particular datetime
#
# stockroom: stockroom where transfers are going to
# datetime: datetime afterwhich transfers are summed
#
sub get_qty_transfered_to_since {
    my $self = shift;
    my $stockroom = shift;
    my $datetime = shift;
    my $dbh = $self->{dbh};
    my $sku = $self->{sku};

    my $stockrooms = DB::Stockrooms->new($dbh);
    my $stockroom_id = $stockrooms->get_stockroom_id($stockroom->get_name());

    my $datetime_str = $self->impl_format_datetime($datetime);
    
    my $sth = $dbh->prepare("SELECT SUM(qty_transfered)
                             FROM Transfers t, Transfers_detail td
                             WHERE td.master_transfer_id = t.id AND
                                to_stockroom = ? AND
                                td.SKU = ? AND
                                from_stockroom <> to_stockroom AND
                                t.datetime >= ?");

    $sth->bind_param(1, $stockroom_id);
    $sth->bind_param(2, $sku);
    $sth->bind_param(3, $datetime_str);


    if (!$sth->execute()) {
	die "get_qty_transfered_to_since failed at execute!";
    }


    my $qty_transfered;
    ($qty_transfered) = $sth->fetchrow_array();

    $qty_transfered = 0 if !defined($qty_transfered);
    
    return $qty_transfered;

}


# Product::get_qty_transfered_to
#
# Retrieve the quantity transfered to a particular stockroom,
#          not counting any transfers to the same stockroom
#
# stockroom: stockroom where transfers are going to
#
sub get_qty_transfered_to {
    my $self = shift;
    my $stockroom = shift;

    my $dbh = $self->{dbh};
    my $sku = $self->{sku};

    my $stockroom_id = $self->get_stockroom_id($stockroom);

    my $sth = $dbh->prepare("SELECT SUM(qty_transfered)
                             FROM Transfers t, Transfers_detail td
                             WHERE td.master_transfer_id = t.id AND
                                   to_stockroom = ? AND
                                   td.SKU = ? AND
                                   from_stockroom <> to_stockroom");

    $sth->bind_param(1, $stockroom_id);
    $sth->bind_param(2, $sku);


    if (!$sth->execute()) {
	die "get_qty_transfered_to failed at execute";

    }

    my $qty_transfered;

    ($qty_transfered) = $sth->fetchrow_array();

    $qty_transfered = 0 if !defined($qty_transfered);


    return $qty_transfered;
    
}

# Product::get_transfered_from_since
#
# Retrieve the quantity transfered from a particular stockrooom
# after a specific date, not counting any transfers to the same
# stockroom
#
# stockroom: stockroom where the transfers come from
# datetime:  transfers after this date
sub get_qty_transfered_from_since {
    my $self = shift;

    my $stockroom = shift;
    my $datetime = shift;
    
    my $dbh = $self->{dbh};
    my $sku = $self->{sku};

    my $stockroom_id = $self->get_stockroom_id($stockroom);

    my $datetime_str = $self->impl_format_datetime($datetime);
    
    my $sth = $dbh->prepare("SELECT SUM(qty_transfered)
                             FROM Transfers t, Transfers_detail td
                             WHERE td.master_transfer_id = t.id AND
                             from_stockroom = ? AND
                             td.SKU = ? AND
                             from_stockroom != to_stockroom AND
                             t.datetime >= ?");

    $sth->bind_param(1, $stockroom_id);
    $sth->bind_param(2, $sku);
    $sth->bind_param(3, $datetime_str);


    if (!$sth->execute()) {
	die "get_qty_transfered_from_since failed at execute!";
    }

    my $qty_transfered;

    ($qty_transfered) = $sth->fetchrow_array();

    $qty_transfered = 0 if !defined($qty_transfered);

    print "get_qty_transfered_from_since: qty_transfered=$qty_transfered\n";
    

    return $qty_transfered;
}    

# Product::get_qty_transfered_from  
#
# Retrieve the quantity transfered from a particular stockroom,
# not counting any transfers to the same stockroom
#
# stockroom: stockroom where the transfers from
sub get_qty_transfered_from {
    my $self = shift;
    my $stockroom = shift;


    my $dbh = $self->{dbh};
    my $sku = $self->{sku};

    my $stockroom_id = $self->get_stockroom_id($stockroom);
    
    my $sth = $dbh->prepare("SELECT SUM(qty_transfered)
                             FROM Transfers t, Transfers_detail td
                             WHERE td.master_transfer_id = t.id AND
                             from_stockroom = ? AND
                             td.SKU = ? AND 
                             from_stockroom <> to_stockroom");

    $sth->bind_param(1, $stockroom_id);
    $sth->bind_param(2, $sku);


    if (!$sth->execute()) {
	die "get_qty_transfered_from failed at execute";
    }

    my $qty_transfered;

    ($qty_transfered) = $sth->fetchrow_array();

    $qty_transfered = 0 if !defined($qty_transfered);


    return $qty_transfered;
}


# impl_format_datetime
#
# Private method to convert a DateTime object into a string that
# DBI can use in the database
#
# datetime: DateTime object to convert into a database string
#
# Returns converted DateTime object's string
sub impl_format_datetime {
    my $self = shift;
    my $datetime = shift;
    
    my $dbh = $self->{dbh};


    if (!defined($dbh)) {
	Carp::confess("dbh is not a database handle");

    }
    
    my $db_parser = DateTime::Format::DBI->new($dbh);

    return $db_parser->format_datetime($datetime);

}

# Retrieve the quantity transfered from a particular stockroom,
# after a particular date
#
# stockroom: 


sub get_qty_received_by_stockroom_since {
    my $self = shift;
    my $stockroom = shift;    
    my $datetime = shift;

    

    my $dbh = $self->{dbh};
    my $sku = $self->{sku};


    my $datetime_str = $self->impl_format_datetime($datetime);


    my $stockroom_id = $self->get_stockroom_id($stockroom);
    

    my $sth = $dbh->prepare("SELECT SUM(qty_received)
                             FROM Invoices inv, Invoices_detail invd
                             WHERE inv.invoice_id = invd.master_invoice_id AND
                                   invd.SKU = ? AND
                                   inv.datetime_received > ? AND
                                   inv.stockroom_id = ?");

    $sth->bind_param(1, $sku);
    $sth->bind_param(2, $datetime_str);
    $sth->bind_param(3, $stockroom_id);
    
    if (!$sth->execute()) {
	die "Product::get_qty_received_by_stockroom_since failed at execute!\n";
    }
	

    my ($qty_received) = $sth->fetchrow_array();


    $qty_received = 0 if !defined($qty_received);

    
    return $qty_received;
}



sub get_qty_received_since {
    my $self = shift;
    my $datetime = shift;

    
    my $dbh = $self->{dbh};
    my $sku = $self->{sku};

    my $datetime_str = $self->impl_format_datetime($datetime);

    
    my $sth = $dbh->prepare("SELECT SUM(qty_received)
                              FROM Invoices inv, Invoices_detail invd
                              WHERE inv.invoice_id = invd.master_invoice_id AND
                              invd.SKU = ? AND
                               inv.datetime_received > ?");

    
    $sth->bind_param(1, $sku);
    $sth->bind_param(2, $datetime_str);

    
    if (!$sth->execute()) {
	    
	die "Product::get_qty_on_hand failed on execute\n";
    }

    my ($qty_from_invoices) = $sth->fetchrow_array();
    die "fetchrow_array failed: $DBI::errstr!\n" if DBI::errstr;


    $qty_from_invoices = 0 if !defined($qty_from_invoices);
    

    return $qty_from_invoices;
}

sub get_qty_received_by_stockroom {
    my $self = shift;
    my $stockroom = shift;
    
    my $sku = $self->{sku};
    my $dbh = $self->{dbh};


    my $stockroom_id = $self->get_stockroom_id($stockroom);
    
    
    
    my $sth = $dbh->prepare("SELECT SUM(invd.qty_received)
                             FROM Invoices inv, Invoices_detail invd
                             WHERE inv.invoice_id = invd.master_invoice_id AND
                                     invd.SKU=? AND
                                     stockroom_id=?");

    $sth->bind_param(1, $sku);
    $sth->bind_param(2, $stockroom_id);
    
    if (!$sth->execute()) {
	die "get_qty_received_by_stockroom failed!";
    }

    my $qty_received;

    ($qty_received) = $sth->fetchrow_array();


    $qty_received = 0 if (!defined($qty_received));
}


# Return the average number of units sold daily in selling units
sub get_avg_sold {
    my $self = shift;


    my $sku = $self->{sku};
    my $dbh = $self->{dbh};

    my $qty_sold_sum;
    my $begin_datetime;
    my $end_datetime;


    my $sth = $dbh->prepare("SELECT SUM(rd.qty_sold)
                             FROM Replenishments r, Replenishments_detail rd
                             WHERE r.id = rd.master_replenishment_id AND
                                   rd.SKU = ?");

    $sth->bind_param(1, $sku);

    if (!$sth->execute()) {
	die "get_avg_sold failed at execute!";

    }

    $qty_sold_sum = 0;
    
    while(my ($sum) = $sth->fetchrow_array()) {
	if (defined($sum)) {
	    $qty_sold_sum = $sum;
	}
    }


    $sth = $dbh->prepare("SELECT MIN(begin_datetime)
                          FROM Replenishments r");
  
 
    if (!$sth->execute()) {
	die "get_avg_sold failed at execute!";
    }

    while(my ($bd) = $sth->fetchrow_array()) {
	if (defined($bd)) {
	    my $db_parser = DateTime::Format::DBI->new($dbh);
	    $begin_datetime = $db_parser->parse_datetime($bd);
	}

    }

    $sth = $dbh->prepare("SELECT MAX(end_datetime)
                          FROM Replenishments r");


    if (!$sth->execute()) {
	die "get_avg_sold failed at execute!";
    }



    while(my ($ed) = $sth->fetchrow_array()) {
	if (defined($ed)) {
	    my $db_parser = DateTime::Format::DBI->new($dbh);
	    $end_datetime = $db_parser->parse_datetime($ed);
	}

    }

    
    if (defined($begin_datetime) && defined($end_datetime)) {
	my $days = $begin_datetime->delta_days($end_datetime);

    
	if ($days->{days} == 0) {
	    return undef;
	}
	
    
	return $qty_sold_sum / $days->{days};
    }



    return undef;
}


sub get_qty_sold_since {
    my $self = shift;
    my $datetime = shift;

    my $sku = $self->{sku};
    my $dbh = $self->{dbh};


    if (ref($datetime) ne "DateTime") {

	Carp::confess("datetime must be a DateTime object!");
    }
    
    my $datetime_str = $self->impl_format_datetime($datetime);

    
    my $sth = $dbh->prepare("SELECT SUM(qty_sold)
                              FROM Replenishments r, Replenishments_detail rd
                              WHERE r.id = rd.master_replenishment_id AND
                                rd.SKU = ? AND
                                r.end_datetime >= ?");
    
    $sth->bind_param(1, $sku);
    $sth->bind_param(2, $datetime_str);
    
    if (!$sth->execute()) {
	die "Product::get_qty_on_hand failed on execute!\n";
	    
    }
    
    my $qty_sold = 0;

    while(my ($qfr) = $sth->fetchrow_array()) {
	$qty_sold = $qfr if defined($qfr);
    }

    if ($DBI::err) {

	die "fetchrow_array failed: $DBI::errstr\n";
    }


    return $qty_sold;
}


sub get_qty_on_hand_at_stockroom {
    my $self = shift;
    my $stockroom = shift;

    
    my $dbh = $self->{dbh};
    my $sku = $self->{sku};
    my $qty_at_st = 0;           # Quantity at stock take
    
    my $sth;

    if (ref($stockroom) ne "DB::Stockroom") {
	die "Stockroom must be a DB::Stockroom";
    }
    
    my $stock_takes = DB::StockTakes->new($dbh);

    
    my %stock_take = $self->get_last_stock_take_at_stockroom($stockroom);
    

    my $qty_sold;
    my $qty_received;
    my $transfers_from;
    my $transfers_to;

    if (%stock_take) {
	$qty_at_st = $stock_take{qty_counted};
	my $datetime_of_st = $stock_take{datetime};


	$qty_sold  = $self->get_qty_sold_by_stockroom_since($stockroom,
							    $datetime_of_st);


	$qty_received = $self->get_qty_received_by_stockroom_since($stockroom,
								   $datetime_of_st);


	$transfers_from
	    = $self->get_qty_transfered_from_since($stockroom, $datetime_of_st);

	$transfers_to
	    = $self->get_qty_transfered_to_since($stockroom, $datetime_of_st);
	
    } else {
	$qty_sold = $self->get_qty_sold_by_stockroom($stockroom);

	$qty_received = $self->get_qty_received_by_stockroom($stockroom);

	$transfers_from =
	    $self->get_qty_transfered_from($stockroom);

	$transfers_to =
	    $self->get_qty_transfered_to($stockroom);
	    
    }
    
    
    return $qty_at_st - $qty_sold + $qty_received - $transfers_from
	+ $transfers_to;
}

# Retrieve the sum of all quantities sold at a particular stockroom
# since a particular datetime
#
# stockrooom_id: ID of the stockroom
# datetime:      datetime that sales are retrieved after
#
sub get_qty_sold_by_stockroom_since {
    my $self = shift;
    my $stockroom = shift;
    my $datetime = shift;

    my $sku = $self->{sku};
    my $dbh = $self->{dbh};

    my $datetime_str = $self->impl_format_datetime($datetime);
	
    my $stockroom_id = $self->get_stockroom_id($stockroom);
    
    
    my $sth = $dbh->prepare("SELECT SUM(qty_sold)
                                FROM Replenishments r, Replenishments_detail rd
                                WHERE r.id = rd.master_replenishment_id AND
                                rd.SKU = ? AND r.stockroom_id = ? AND 
                                r.end_datetime >= ?
                            ");

    $sth->bind_param(1, $sku);
    $sth->bind_param(2, $stockroom_id);
    $sth->bind_param(3, $datetime_str);
    
    if (!$sth->execute()) {

	die "get_qty_sold_by_stockroom_since failed!";

    }


    my ($qty_sold) = $sth->fetchrow_array();


    $qty_sold = 0 if !defined($qty_sold);

    
                                                            
    return $qty_sold;
}



#
# stockroom_id: ID of the stockroom
# datetime:     datetime which sales are retrieved after

# Retrieve the sum of all quantities sold at a particular stockroom
#
# stockroom_id: ID of the stockroom
#  
sub get_qty_sold_by_stockroom {
    my $self = shift;
    my $stockroom = shift;

    my $dbh = $self->{dbh};

    my $sku = $self->{sku};



    if (ref($stockroom) ne "DB::Stockroom") {
	die "stockroom is not DB::Stockroom but " . ref($stockroom);

    }
    
    my $stockroom_id = $self->get_stockroom_id($stockroom);
    
    
    my $sth = $dbh->prepare("SELECT SUM(qty_sold)
                                FROM Replenishments r, Replenishments_detail rd
                                WHERE r.id = rd.master_replenishment_id AND
                                rd.SKU = ? AND
                                r.stockroom_id = ?");


    $sth->bind_param(1, $sku);
    $sth->bind_param(2, $stockroom_id);


    if(!$sth->execute()) {
        die "get_qty_sold_by_stockroom failed at execute";


    }

    my ($qty_sold) = $sth->fetchrow_array();

    $qty_sold = 0 if !defined($qty_sold);

    return $qty_sold;
}


# Retrieve the sum of all quantities sold irrespective of
# stock takes
sub get_qty_sold {
    my $self = shift;
    
    my $dbh = $self->{dbh};
    my $sku = $self->{sku};



    my $test_str = "SELECT SUM(qty_sold)
                              FROM Replenishments r, Replenishments_detail rd
                              WHERE r.id = rd.master_replenishment_id AND
                                rd.SKU = $sku";
				
    my $sth = $dbh->prepare("SELECT SUM(qty_sold)
                              FROM Replenishments r, Replenishments_detail rd
                              WHERE r.id = rd.master_replenishment_id AND
                                rd.SKU = ?");


    $sth->bind_param(1, $sku);
    
    if (!$sth->execute()) {
	die "Product::get_qty_on_hand failed on execute!\n";
	
    }


    my $qty_sold;
    
    ($qty_sold) = $sth->fetchrow_array();


    $qty_sold = 0 if !defined($qty_sold);
    
    return $qty_sold;
}


# Retrieve the sum of all quantities received irrespective of
# stock takes
sub get_qty_received {
    my $self = shift;
    my $sku = $self->{sku};
    
    my $dbh = $self->{dbh};
    my $sth;
    
    $sth = $dbh->prepare("SELECT SUM(qty_received) 
                          FROM Invoices inv, Invoices_detail invd
                          WHERE invd.master_invoice_id = inv.invoice_id AND
                                invd.SKU = ?");
    
    $sth->bind_param(1, $sku);
    
    
    if (!$sth->execute()) {
	die "Product::get_qty_on_hand failed on execute!\n";
	    
    }

    my $qty_from_invoices;
    
    ($qty_from_invoices) = $sth->fetchrow_array();

    $qty_from_invoices = 0 if !defined($qty_from_invoices);
    

    return $qty_from_invoices;
}

# Product::get_last_stocktake
#
# Retrieves the Product's most recent stock take
# Stock takes are a hash containing keys datetime, when the stock take
# was made, and qty_counted, which is the number in pieces that
# was counted.
#
# Returns {datetime, qty_counted} hash
sub get_last_stocktake {
    my $self = shift;
    
    my $dbh = $self->{dbh};
    my $sku = $self->{sku};


    my $stock_takes = DB::StockTakes->new($dbh);

    return $stock_takes->get_last_stock_take_by_sku($sku);

}

# Product::get_last_stock_take_at_stockroom
#
# Retrieves the Product's most recent stock take
# at a particular stockroom.
#
# Stock takes are a hash containing keys datetime, when the stock take
# was made, and qty_counted, which is the number in pieces that
# was counted
#
# stockroom_id: Particular stockroom to find its stock take.
#
# Returns {datetime, qty_counted} hash
sub get_last_stock_take_at_stockroom {
    my $self = shift;
    my $dbh = $self->{dbh};
    my $sku = $self->{sku};
    my $stockroom = shift;

    if (!defined($stockroom)) {
	Carp::confess("stockroom must be defined!");
	
    }

    if (ref($stockroom) ne "DB::Stockroom") {
	Carp::confess("stockroom must be a DB::Stockroom object!");
    }
    
    
    my $stock_takes = DB::StockTakes->new($dbh);


    my %stock_take = $stock_takes->get_last_stock_take_by_sku_at_stockroom($sku, 
									   $self->get_stockroom_id($stockroom));


    return %stock_take;
}



# Product
sub get_qty_on_hand {
    my $self = shift;
    my $dbh = $self->{dbh};


    my $sth = $dbh->prepare("SELECT name
                             FROM Stockrooms");

    if (!$sth->execute()) {
	die "get_qty_on_hand failed at execute!\n";
    }

    my $qty = 0;
    
    while(my ($stockroom_name) = $sth->fetchrow_array()) {
	
	$qty += $self->get_qty_on_hand_at_stockroom(DB::Stockroom->new($stockroom_name));
    }
    
                                   
    return $qty;
}

    
    









   



# Product
sub update_product_info {
    my $self = shift;

    my $product_info = shift;

    my $dbh = $self->{dbh};
   

    my $sku = $self->{sku};




    my $sth;


    $sth = $dbh->prepare("UPDATE Products
                          SET item_no  = ?,
                             description = ?,
                             unit = ?,
                             case_pack = ?,
                             eoq = ?,
                             cost = ?,
                             unit_cost = ?,
                             upc = ?,
                             dep_no = ?,
                             par = ?,
                             loc = ?,
                             units_in_bx = ?
                          WHERE SKU = ?");

    $sth->bind_param(1, $product_info->get_item_no());
    $sth->bind_param(2, $product_info->get_description(), DBI::SQL_VARCHAR);
    $sth->bind_param(3, $product_info->get_unit());
    $sth->bind_param(4, $product_info->get_case_pack());
    $sth->bind_param(5, $product_info->get_eoq());
    $sth->bind_param(6, $product_info->get_cost());
    $sth->bind_param(7, $product_info->get_unit_cost());


    if ($product_info->get_upc()) {
	$sth->bind_param(8, $product_info->get_upc()->str(), DBI::SQL_VARCHAR);
    } else {
	$sth->bind_param(8, undef);
    }

    $sth->bind_param(9, $product_info->get_department_no());
    $sth->bind_param(10, $product_info->get_par());
    $sth->bind_param(11, $product_info->get_location());
    $sth->bind_param(12, $product_info->get_units_in_bx());
    $sth->bind_param(13, $sku);

    if (!$sth->execute()) {

	die "update_product_info failed at execute!\n";
    }

    
}


sub set_unit {
    my $self = shift;
    my $unit = shift;

    my $dbh = $self->{dbh};
    my $sku = $self->{sku};


    if ($unit <= 0) {
	die "unit must be postive not " . $unit . "\n";
    }


    my $sth;

    $sth = $dbh->prepare("UPDATE Products
                          SET unit = ?
                          WHERE SKU = ?");


    $sth->bind_param(1, $unit);
    $sth->bind_param(2, $sku);


    if (!$sth->execute()) {
	die "set_unit failed at execute!\n";

    }


}



sub get_unit {
    my $self = shift;

    my $dbh = $self->{dbh};

    my $sku = $self->{sku};


    my $sth;


    $sth = $dbh->prepare("SELECT unit
                          FROM Products
                          WHERE SKU = ?");


    $sth->bind_param(1, $sku);

    if (!$sth->execute()) {
	die "get_unit failed at execute\n";
    }

    my $unit;

    while(my ($u) = $sth->fetchrow_array()) {
	$unit = $u;                # Should execute only once

    }


    return $unit;
}

# Product
sub set_product_info {
    my $self = shift;
    my $product_info = shift;

    my $dbh = $self->{dbh};
    my $sku = $self->{sku};

    if (!defined($dbh)) {

	die "dbh not defined\n";
    }

    my $sth = $dbh->prepare("UPDATE Products
                             SET upc = ?, description = ?,
                             unit = ?, case_pack = ?, dep_no = ?,
                             cost = ?, unit_cost = ?, par = ?,
                             item_no = ?, category_id = ?, loc = ?,
                             units_in_bx = ?, eoq = ?
                      WHERE SKU = ?");

#    print $product_info->get_upc()->str() . "\n";
#    print $product_info->get_description() . "\n";
#    print $product_info->get_unit() . "\n";
#    print $product_info->get_case_pack() . "\n";
#    print $product_info->get_department_no() . "\n";
#    print $product_info->get_cost() . "\n";
#    print $product_info->get_unit_cost() . "\n";
#    print $product_info->get_par() . "\n";
#    print $product_info->get_item_no() . "\n";
#    print $product_info->get_category_id() . "\n";
#    print $product_info->get_location() . "\n";
#    print $product_info->get_units_in_bx() . "\n";
#    print $product_info->get_eoq() . "\n";

#    print $product_info->get_department_no() . "\n";

    $sth->bind_param(1, $product_info->get_upc()->str(), DBI::SQL_VARCHAR);
    $sth->bind_param(2, $product_info->get_description(), DBI::SQL_VARCHAR);
    $sth->bind_param(3, $product_info->get_unit(), DBI::SQL_INTEGER);
    $sth->bind_param(4, $product_info->get_case_pack(), DBI::SQL_INTEGER);
    $sth->bind_param(5, $product_info->get_department_no(), DBI::SQL_INTEGER);
    $sth->bind_param(6, $product_info->get_cost(), DBI::SQL_DECIMAL);
    $sth->bind_param(7, $product_info->get_unit_cost(), DBI::SQL_DECIMAL);
    $sth->bind_param(8, $product_info->get_par(), DBI::SQL_INTEGER);
    $sth->bind_param(9, $product_info->get_item_no(), DBI::SQL_INTEGER);
    $sth->bind_param(10, $product_info->get_category_id(), DBI::SQL_INTEGER);
    $sth->bind_param(11, $product_info->get_location(), DBI::SQL_INTEGER);
    $sth->bind_param(12, $product_info->get_units_in_bx(), DBI::SQL_INTEGER);
    $sth->bind_param(14, $product_info->get_eoq(), DBI::SQL_INTEGER);
    $sth->bind_param(15, $sku, DBI::SQL_INTEGER);



    if (!$sth->execute()) {
	die "set_product_info failed at execute!\n";
    }


}


sub get_product_info {
    my $self = shift;
    my $dbh = $self->{dbh};

    my $sku = $self->{sku};

    my $sth;


    $sth = $dbh->prepare("SELECT SKU, upc, description, unit, case_pack,
                                 dep_no, cost, unit_cost, par, item_no,
                                 category_id, loc, units_in_bx, price,
                                 eoq 
                          FROM Products
                          WHERE SKU = ?");

    $sth->bind_param(1, $sku);


    if (!$sth->execute()) {
	die "get_product_info failed at execute!\n";
    }



    my $product_info;

    while(my ($SKU, $upc_str, $description, $unit,
              $case_pack, $dep_no, $cost, $unit_cost,
              $par, $item_no, $category_id,
              $loc, $units_in_bx, $price, $eoq) = $sth->fetchrow_array()) {


	my $retail;
	my $category_id;

	my $pi = ProductInfo->new($item_no, $description,
				  $unit, $case_pack, $eoq,
				  $cost, $unit_cost, $retail,
				  Core::Upc->new($upc_str), $dep_no, $par,
				  $loc, $units_in_bx, $category_id);

	$product_info = $pi;
    }
    
    return $product_info;
}


sub set_department_no {
    my $self = shift;
    my $dep_no = shift;

    my $dbh = $self->{dbh};

    my $sku = $self->{sku};

    my $sth = $dbh->prepare("UPDATE Products
                          SET dep_no = ?");

    $sth->bind_param(1, $dep_no);

    if (!$sth->execute()) {
	die "set_department_no failed at execute!\n";
    }

}


sub get_department_no {
    my $self = shift;
    my $dbh = $self->{dbh};

    my $sku = $self->{sku};


    my $sth = $dbh->prepare("SELECT dep_no
                          FROM Products
                          WHERE SKU = ?");

    $sth->bind_param(1, $sku);

    
    if (!$sth->execute()) {
	die "get_department_no failed at execute!\n";

    }

    
    my $dep_no;

    while(my ($department_no) = $sth->fetchrow_array()) {
	$dep_no = $department_no; # Should execute only once

    }

    
    return $dep_no;
}


sub get_case_pack {
    my $self = shift;
    my $dbh = $self->{dbh};
    my $sku = $self->{sku};

    my $sth = $dbh->prepare("SELECT case_pack
                             FROM Products
                             WHERE SKU = ?");


    $sth->bind_param(1, $sku);


    if (!$sth->execute()) {
	die "get_case_pack failed at execute!\n";
    }



    my $case_pack;
    my $cp;

    while(($cp) = $sth->fetchrow_array()) {
	$case_pack = $cp;
    }
                              
    return $case_pack;
}

# Product
sub set_case_pack {
    my $self = shift;
    my $case_pack = shift;

    my $dbh = $self->{dbh};
    my $sku = $self->{sku};

    my $sth = $dbh->prepare("UPDATE Products
                             SET case_pack = ?
                             WHERE SKU = ?");

    $sth->bind_param(1, $case_pack);
    $sth->bind_param(2, $sku);

    if (!$sth->execute()) {
	die "set_case_pack failed at execute!\n";
    }


    

}

# Product
sub get_error_msg {


}

sub get_cost {
    my $self = shift;
    my $dbh = $self->{dbh};
    my $sku = $self->{sku};


    my $sth = $dbh->prepare("SELECT cost
                             FROM Products
                             WHERE SKU = ?");

    $sth->bind_param(1, $sku);

    if (!$sth->execute()) {
	die "get_cost failed at execute!\n";
    }


    my $cost;
    my $c;

    while(($c) = $sth->fetchrow_array()) {
	$cost = $c;
    }


    return $cost;
}

sub set_cost {
    my $self = shift;
    my $cost = shift;
    my $dbh = $self->{dbh};
    my $sku = $self->{sku};


    my $sth = $dbh->prepare("UPDATE Products
                             SET cost = ?
                             WHERE SKU = ?");


    $sth->bind_param(1, $cost);
    $sth->bind_param(2, $sku);


    if (!$sth->execute()) {
	die "set_cost failed at execute!\n";
    }
}


sub get_unit_cost {
    my $self = shift;
    my $dbh = $self->{dbh};
    my $sku = $self->{sku};


    my $sth = $dbh->prepare("SELECT unit_cost
                          FROM Products
                          WHERE SKU = ?");

    $sth->bind_param(1, $sku);

    if (!$sth->execute()) {
	die "get_unit_cost failed at execute!\n";

    }

    my $unit_cost;
    my $uc;

    while(($uc) = $sth->fetchrow_array()) {

	$unit_cost = $uc;
    }



    return $unit_cost;
}


sub set_unit_cost {
    my $self = shift;
    my $unit_cost = shift;
    my $dbh = $self->{dbh};
    my $sku = $self->{sku};


    my $sth = $dbh->prepare("UPDATE Products
                          SET unit_cost = ?
                          WHERE SKU = ?");

    $sth->bind_param(1, $unit_cost);
    $sth->bind_param(2, $sku);

    if (!$sth->execute()) {
	die "set_unit_cost failed at execute!\n";
    }
}


sub get_par {
    my $self = shift;
    my $dbh = $self->{dbh};
    my $sku = $self->{sku};


    my $sth = $dbh->prepare("SELECT par
                             FROM Products
                             WHERE SKU = ?");

    $sth->bind_param(1, $sku);


    if (!$sth->execute()) {
	die "get_par failed at execute!\n";
    }


    my $par;

    my $p;

    while(($p) = $sth->fetchrow_array()) {

	$par = $p;
    }


    return $par;

}


sub set_par {
    my $self = shift;
    my $par = shift;


    my $dbh = $self->{dbh};
    my $sku = $self->{sku};


    my $sth = $dbh->prepare("UPDATE Products
                             SET par = ?
                             WHERE sku = ?");


    $sth->bind_param(1, $par);
    $sth->bind_param(2, $sku);

    

    if (!$sth->execute()) {
	die "set_par failed at execute!\n";

    }

}

sub get_item_no {
    my $self = shift;
    my $dbh = $self->{dbh};
    my $sku = $self->{sku};


    my $sth = $dbh->prepare("SELECT item_no 
                             FROM Products
                             WHERE sku = ?");

    $sth->bind_param(1, $sku);


    if (!$sth->execute()) {
	die "get_item_no failed at execute!\n";
    }


    my $ino;
    my $item_no;

    while(($ino) = $sth->fetchrow_array()) {
	$item_no = $ino;

    }


    return $item_no;
}

sub set_item_no {
    my $self = shift;
    my $item_no = shift;


    my $dbh = $self->{dbh};
    my $sku = $self->{sku};


    my $sth = $dbh->prepare("UPDATE Products
                             SET item_no = ?
                             WHERE SKU = ?");

    $sth->bind_param(1, $item_no);
    $sth->bind_param(2, $sku);

    if (!$sth->execute()) {
	die "set_item_no failed at execute!\n";

    }

}



sub get_category_id {
    my $self = shift;

    my $dbh = $self->{dbh};
    my $sku = $self->{sku};


    my $category_id;

    my $sth = $dbh->prepare("SELECT category_id
                             FROM Products
                             WHERE SKU = ?");

    $sth->bind_param(1, $sku);

    if (!$sth->execute()) {

	die "get_category_id failed at execute!\n";
    }

    my $ci;

    while(($ci) = $sth->fetchrow_array()) {

	$category_id = $ci;
    }



    return $category_id;
}


sub set_category_id {
    my $self = shift;
    my $category_id = shift;
    my $dbh = $self->{dbh};
    my $sku = $self->{sku};


    my $sth = $dbh->prepare("UPDATE Products
                             SET category_id = ?
                             WHERE SKU = ?");


    $sth->bind_param(1, $category_id);
    $sth->bind_param(2, $sku);


    if (!$sth->execute()) {
	die "set_category_id failed at execute!\n";
    }

}

# Product
sub get_loc {
    my $self = shift;
    my $dbh = $self->{dbh};
    my $sku = $self->{sku};


    my $sth = $dbh->prepare("SELECT loc
                             FROM Products
                             WHERE SKU = ?");


    $sth->bind_param(1, $sku);


    if (!$sth->execute()) {
	die "get_loc failed at get_loc!\n";
    }

    my $loc;
    my $lc;

    while(($lc) = $sth->fetchrow_array()) {
	$loc = $lc;
    }


    return $loc;
    
}

# Product
sub set_loc {
    my $self = shift;
    my $loc = shift;
    my $dbh = $self->{dbh};
    my $sku = $self->{sku};

    my $sth = $dbh->prepare("UPDATE Products
                             SET loc = ?
                             WHERE SKU = ?");

    $sth->bind_param(1, $loc);
    $sth->bind_param(2, $sku);


    if (!$sth->execute()) {
	die "set_loc failed at execute!\n";
    }

}

# Product
sub get_units_in_bx {
    my $self = shift;
    my $dbh = $self->{dbh};
    my $sku = $self->{sku};


    my $sth = $dbh->prepare("SELECT units_in_bx 
                             FROM Products
                             WHERE sku = ?");

    $sth->bind_param(1, $sku);

    if (!$sth->execute()) {
	die "get_units_in_bx failed at execute!\n";

    }


    my $units_in_box;
    my $ub;

    while(($ub) = $sth->fetchrow_array()) {
	$units_in_box = $ub;

    }

    return $units_in_box;
}

# Product
sub set_units_in_bx {
    my $self = shift;
    my $units_in_bx = shift;

    my $dbh = $self->{dbh};
    my $sku = $self->{sku};



    my $sth = $dbh->prepare("UPDATE Products
                             SET units_in_bx = ?
                             WHERE sku = ?");

    $sth->bind_param(1, $units_in_bx);
    $sth->bind_param(2, $sku);

    if (!$sth->execute()) {
	die "set_units_in_bx failed at execute!\n";

    }

}

# Product
sub get_price {
    my $self = shift;
    my $dbh = $self->{dbh};
    my $sku = $self->{sku};



    my $sth = $dbh->prepare("SELECT price
                             FROM Products
                             WHERE SKU = ?");
    
    $sth->bind_param(1, $sku);

    if (!$sth->execute()) {
	die "get_price failed at execute!\n";
    }


    my $price;
    my $p;

    while(($p) = $sth->fetchrow_array()) {

	$price = $p;
    }


    return $price;
}

# Product
sub set_price {
    my $self = shift;
    my $price = shift;

    my $dbh = $self->{dbh};
    my $sku = $self->{sku};


    my $sth = $dbh->prepare("UPDATE Products
                             SET price = ?
                             WHERE SKU = ?");

    $sth->bind_param(1, $price);
    $sth->bind_param(2, $sku);

    if (!$sth->execute()) {
	die "set_price failed at execute!\n";
    }

}

# Product
sub get_eoq {
    my $self = shift;
    my $dbh = $self->{dbh};
    my $sku = $self->{sku};


    my $sth = $dbh->prepare("SELECT eoq
                             FROM Products
                             WHERE SKU = ?");


    $sth->bind_param(1, $sku);

    if (!$sth->execute()) {
	die "get_eoq failed at execute!\n";
	
    }


    my $eoq;
    my $e;

    while(($e) = $sth->fetchrow_array()) {

	$eoq = $e;
    }


    return $eoq;
}

# Product
sub set_eoq {
    my $self = shift;
    my $eoq = shift;

    my $dbh = $self->{dbh};
    my $sku = $self->{sku};



    my $sth = $dbh->prepare("UPDATE Products
                             SET eoq = ?
                             WHERE SKU = ?");


    $sth->bind_param(1, $eoq);
    $sth->bind_param(2, $sku);

    if (!$sth->execute()) {
	die "set_eoq failed at execute!\n";
    }

}

# Product
sub get_upc {
    my $self = shift;
    my $dbh = $self->{dbh};
    my $sku = $self->{sku};


    my $sth = $dbh->prepare("SELECT upc
                             FROM Products
                             WHERE SKU =  ?");

    $sth->bind_param(1, $sku);


    if (!$sth->execute()) {
	die "get_upc failed at execute!\n";
    }


    my $upc_str;
    my $upc;

    while(($upc_str) = $sth->fetchrow_array()) {
	
	if (defined($upc_str)) {
	    $upc = Core::Upc->new($upc_str);
	}
    }


    return $upc;
}

# Product
sub set_upc {
    my $self = shift;
    my $upc = shift;
    my $dbh = $self->{dbh};
    my $sku = $self->{sku};

    my $sth = $dbh->prepare("UPDATE Products
                             SET upc = ?
                             WHERE SKU = ?");

    $sth->bind_param(1, $upc->str());
    $sth->bind_param(2, $sku);


    if (!$sth->execute()) {
	die "set_upc failed at execute!\n";
    }

}


# Product 
# Set Vendor
sub set_vendor {


}

# Product
# Get Vendor
sub get_vendor {


}

# 

# Product
sub get_retail {
    return undef;
}


# Product
sub set_retail {
    my $self = shift;

}


1
