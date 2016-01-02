#!/usr/bin/perl


use warnings;
use strict;
use Carp;


package DB::Replenishment_iterator;


sub new {
    my $class = shift;

    my $self = {
	dbh => shift,
	master_id => shift,
	sth => undef
    };


    my $dbh = $self->{dbh};

    $self->{sth} = $dbh->prepare("SELECT id, SKU, qty_sold, master_replenishment_id 
                                  FROM Replenishments_detail
                                  WHERE master_replenishment_id = ?");

  
    my $sth = $self->{sth};


    $sth->bind_param(1, $self->{master_id});


    if (!$sth->execute()) {
	die "Replenishment_iterator::new failed at execute!\n";

    }

    bless $self, $class;


    return $self;
}


sub fetch_entry {
    my $self = shift;

    my $id;
    my $sku;
    my $qty_sold;
    my $master_replenishment_id;


    my $sth = $self->{sth};

    if (($id, $sku, $qty_sold, $master_replenishment_id) = $sth->fetchrow_array()) {
	return {id=>$id, product=>Product->new($sku), qty_sold=>$qty_sold, 
		master_replenishment_id=>$master_replenishment_id};
    }



    return undef;
}







