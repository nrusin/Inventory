#!/usr/bin/perl
use strict;
use warnings;

use Parser::ProductInfoParser;
use DB::SchemaBuilder;
use DB::Products;
use DB::Product;


package ProductInfoUpdater;



sub new {
    my $class = shift;
    my $self = {
	dbh => shift
    };


    bless $self, $class;

}


sub update_product_info {
    my $self = shift;

    my $fname = shift;

    my $dbh = $self->{dbh};
    
    my $save_old = $dbh->{AutoCommit};

    $dbh->{AutoCommit} = 0;

    my $products = DB::Products->new($self->{dbh});

    my $parser = Parser::ProductInfoParser->new();


    $parser->open($fname);


    while(!$parser->at_eof()) {
	my $product_info = $parser->get_product_info();
	
	$products->update_products_info($product_info);

	$parser->next();
    }

    $dbh->commit;
    $dbh->{AutoCommit} = $save_old;
}

my $dbh = DBI->connect("dbi:SQLite:dbname=p.db", "","",
                       { RaiseError => 1});


my $sb = DB::SchemaBuilder->new($dbh);
#$sb->unbuild();
$sb->build();


my $updater = ProductInfoUpdater->new($dbh);

$updater->update_product_info("PRODUCT_LIST.xlsx");


1
