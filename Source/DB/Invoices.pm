#!/usr/bin/perl

use warnings;
use strict;

use DateTime::Format::DBI;


package DB::Invoices;


# Invoices
sub new {
    my $class = shift;

    my $self = {
	dbh => shift
    };

    if (!defined($self->{dbh})) {
	die "Database handle must be set correctly!\n";
    }

    bless $self, $class;
}

# Invoices
sub begin_invoice {
    my $self = shift;
    my $datetime_received  = shift;
    my $po = shift;


    if (!defined($datetime_received)) {
	die "Must pass in a correct date when the invoice was received!\n";
    }

    my $dbh = $self->{dbh};


    my $db_parser = DateTime::Format::DBI->new($dbh);

    my $datetime_received_str = $db_parser->format_datetime($datetime_received);



    my $sth = $dbh->prepare("INSERT INTO Invoices(invoice_id, datetime_received, PO)
                             VALUES(NULL, ?, ?)");


    $sth->bind_param(1, $datetime_received_str);
    $sth->bind_param(2, $po);

    if (!$sth->execute()) {
	die "begin_invoice failed at execute!\n";
    }


    my $catalog = undef;
    my $schema = undef;
    my $table = "Invoices";
    my $field = "invoice_id";

    my $invoice_id = $dbh->last_insert_id($catalog, $schema, $table, $field);

    return $invoice_id;
}


# Invoices
sub insert_into {
    my $self = shift;
    my $master_invoice_id = shift;
    my $invoice_info = shift;


    my $dbh = $self->{dbh};


    my $sku = $invoice_info->get_sku();
    my $qty_received = $invoice_info->get_qty_received();


    my $sth = $dbh->prepare("SELECT datetime_received FROM Invoices WHERE invoice_id = ?");
    $sth->bind_param(1, $master_invoice_id);
    
    
    if (!$sth->execute()) {
	die "insert_into failed at execute!\n";
    }


    my $test_datetime;

    ($test_datetime) = $sth->fetchrow_array();

    if (!defined($test_datetime)) {

	die "master_invoice_id has an invalid link!\n";
    }
    

    $sth = $dbh->prepare("INSERT INTO Invoices_detail(id, SKU, qty_received, master_invoice_id)
                                         VALUES(NULL, ?, ?, ?)");

    $sth->bind_param(1, $sku);
    $sth->bind_param(2, $qty_received);
    $sth->bind_param(3, $master_invoice_id);

    
    if (!$sth->execute()) {
	die "insert_into failed at execute!\n";
    }
    
}

1
