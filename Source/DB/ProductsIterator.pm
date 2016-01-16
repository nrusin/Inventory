#!/usr/bin/perl

use warnings;
use strict;
use Carp;


package DB::ProductsIterator;

sub new {
    my $class = shift;
    my $dbh = shift;

    my $self = {
        dbh => $dbh,
	sth => undef
	
    };

    
    $self->{sth} = $dbh->prepare("SELECT SKU
                             FROM Products");


    if (!$self->{sth}->execute()) {
	die "ProductsIterator::new failed at execute!\n";
    }



    bless $self, $class;
}



sub fetch_product {
    my $self = shift;
    my $sku;

    
    if (($sku) = $self->{sth}->fetchrow_array()) {

	return DB::Product->new($self->{dbh}, $sku);
    } else {

	return undef;
    }

}


1
