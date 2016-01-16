#!/usr/bin/perl

use warnings;
use strict;
use Carp;


package Core::StockTakeInfo;

sub new {
    my $class = shift;
    my $self = { 
	upc => undef,
	qty => undef,
	description => undef
    };



    bless $self, $class;

}


sub get_upc {
    my $self = shift;


    return $self->{upc};
}


sub set_upc {
    my $self = shift;
    my $upc = shift;

    if (ref($upc) ne "Core::Upc") {
	Carp::confess("upc must be Core::Upc object");

    }
    
    $self->{upc} = $upc;

}


sub get_qty_counted {
    my $self = shift;


    return $self->{qty};
}


sub set_qty_counted {
    my $self = shift;
    my $qty = shift;

    $self->{qty} = $qty;

}

sub get_description {
    my $self = shift;


    return $self->{description};
}


sub set_description {
    my $self = shift;

    my $description = shift;



    $self->{description} = $description;
    
}


1
