#!/usr/bin/perl

use Parser::StockTakeParser;
use Core::StockTakeInfo;
use DB::StockTakes;


if (!defined($ARGV[0])) {

    die "scan_stock_take.pl [stock_take filename]!";
}



my $dbh = DBI->connect("dbi:SQLite:dbname=p.db", "", "",
		       {RaiseError => 1});

$dbh->{AutoCommit} = 0;



my $stock_take_parser = Parser::StockTakeParser->new();




$stock_take_parser->open($ARGV[0]);


my $stock_takes = DB::StockTakes->new($dbh);


print "get_datetime = " . $stock_take_parser->get_datetime() . "\n";

my $sid = $stock_takes->begin_stock_take($stock_take_parser->get_datetime());

while(!$stock_take_parser->eof()) {
    
    my $stock_take_info = $stock_take_parser->get_stock_take_info();


    if ($stock_take_info->get_qty_counted() =~ m/\d+/) {
	print "Got stock_take info now inserting\n";

	$stock_takes->insert_into($sid, $stock_take_info);
    }
    
    $stock_take_parser->next();
}


$dbh->commit();
