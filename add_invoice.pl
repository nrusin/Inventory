# !/usr/bin/perl

use strict;
use warnings;
use DBI;
use Carp;
use Parser::InvoiceParser;
use DB::Invoices;
use DB::Products;
use Core::InvoiceInfo;

sub usage {
    die "add_invoice [invoice filename]";
}


my $invoice_filename = $ARGV[0];

if (!defined($invoice_filename)) {
    usage();

}


my $invoice_parser = Parser::InvoiceParser->new();


my $dbh = DBI->connect("dbi:SQLite:dbname=p.db", "", "",
		       {RaiseError => 1});

$dbh->{AutoCommit} = 0;

my $invoices = DB::Invoices->new($dbh);



$invoice_parser->open($invoice_filename);


my $datetime_of_invoice = $invoice_parser->get_datetime();

my $invoice_id = $invoices->begin_invoice($datetime_of_invoice);


my $products = DB::Products->new($dbh);

while (!$invoice_parser->eof()) {
    my %parser_entry = $invoice_parser->get_invoice_entry();


    my $item_no = $parser_entry{item_no};
    my $qty_received = $parser_entry{qty_received};
    

    my $product = $products->lookup_by_item_no($item_no);


    if (!defined($product)) {
	$invoice_parser->next();
	
	next;
    }
    




    my $invoice_entry = Core::InvoiceInfo->new();

    $invoice_entry->set_sku($product->get_sku());
    $invoice_entry->set_qty_received($qty_received);
    
    $invoices->insert_into($invoice_id, $invoice_entry);
    
    
    $invoice_parser->next();
    
}


$dbh->commit();
