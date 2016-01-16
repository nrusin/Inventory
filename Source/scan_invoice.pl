#!/usr/bin/perl



use Parser::InvoiceParser;
use DB::Invoices;


sub usage {
    die "scan_invoice.pl [invoice_filename]";

}


my $dbh = DBI->connect("dbi:SQLite:dbname=../Data/p.db", "", "",
		       { RaiseError => 1});

$dbh->{AutoCommit} = 0;

my $invoices = DB::Invoices->new($dbh);

my $filename = $ARGV[0];


if (!defined($filename)) {
    usage();
}





my $invoice_parser = Parser::InvoiceParser->new();


$invoice_parser->open($filename);

my $invoice_id = $invoices->begin_invoice($invoice_parser->get_datetime());

					  
while(!$invoice_parser->eof()) {
    my $invoice_entry = $invoice_parser->get_invoice_entry();


   
    $invoices->insert_into($invoice_id, $invoice_entry);

    $invoice_parser->next();
}


$dbh->commit();


