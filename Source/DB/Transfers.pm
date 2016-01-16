#!/usr/bin/perl
#
# Nicholas Rusinko
# Email: nicholas.rusinko@gmail.com
#
#
#

use warnings;
use strict;


package DB::Transfers;


sub new {
    my $class = shift;
    my $self = {
	dbh => shift
    };


    if (!$self->{dbh}) {
	die "must pass valid dbh to Transfers new";

    }
    
    bless $self, $class;
}


sub impl_get_stockroom_id {
    my $self = shift;
    my $stockroom_name = shift;

    my $dbh = $self->{dbh};

    my $sth = $dbh->prepare("SELECT id
                             FROM Stockrooms
                             WHERE name = ?");

    $sth->bind_param(1, $stockroom_name);

    if (!$sth->execute()) {
	die "impl_get_stockroom_id failed at execute!";
    }
    

    my $stockroom_id;

    ($stockroom_id) = $sth->fetchrow_array();


    return $stockroom_id;
}


# Transfers::begin_transfer
#
# from_stockroom:     Stockroom transfer is from
# to_stockroom:       Stockroom transfer is going to
# datetime:           Datetime of the transfer  
sub begin_transfer {
    my $self = shift;
    my $from_stockroom = shift;
    my $to_stockroom = shift;
    my $datetime = shift;

    if (ref($from_stockroom) ne "DB::Stockroom") {
	die "from_stockroom must a DB::Stockroom object!";
    }

    if (ref($to_stockroom) ne "DB::Stockroom") {
	die "to_stockroom must be a DB::Stockroom object!";
    }
    
    if (ref($datetime) ne "DateTime") {
	die "datetime must be a DateTime object!";
	
   }
    

    if ($from_stockroom eq $to_stockroom) {
	die "Cannot transfer when both stockrooms are the same stockroom";
    }
    
    my $dbh = $self->{dbh};
    my $sth;

    my $db_parser = DateTime::Format::DBI->new($dbh);


    $sth = $dbh->prepare("INSERT INTO Transfers(id, from_stockroom, 
                                                to_stockroom, datetime)
                                             VALUES(NULL, ?, ?, ?)");

    
    $sth->bind_param(1, $self->impl_get_stockroom_id($from_stockroom->get_name()));
    $sth->bind_param(2, $self->impl_get_stockroom_id($to_stockroom->get_name()));
    $sth->bind_param(3, $db_parser->format_datetime($datetime));
    
    if (!$sth->execute()) {
	die "begin_transfer failed at execute!\n";
    }

    my $catalog = undef;
    my $schema = undef;
    my $table = "Transfers";
    my $field = "id";

    my $transfer_id = $dbh->last_insert_id($catalog, $schema, $table, $field);

    return $transfer_id;

}

# Transfers::insert_into
#
# transfer_id:      id returned from begin_transfer
# sku:              stocking unit of the product were tranfering
# qty_transfered:   transfered quantity in pieces 
sub insert_into {
    my $self = shift;
    
    my $transfer_id = shift;
    my $sku = shift;
    my $qty_in_transfered = shift;
    

    my $dbh = $self->{dbh};


    my $sth = $dbh->prepare("INSERT INTO Transfers_detail(id, master_transfer_id,
                                                          SKU, qty_transfered)
                                         VALUES(NULL, ?, ?, ?)");

    $sth->bind_param(1, $transfer_id);
    $sth->bind_param(2, $sku);
    $sth->bind_param(3, $qty_in_transfered);


    if (!$sth->execute()) {
	die "insert_into failed at execute!\n";
    }
    
}


1
