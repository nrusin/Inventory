#!/usr/bin/perl

use warnings;
use strict;
use Carp;

package Core::ReplenishmentEntry;

sub new {
    my $class = shift;

    my $self = {upc         => undef,
		price       => undef,
		description => undef,
		qty_sold    => undef,
		depno       => undef
    };


    
    if (@_ != 0) {

	my $upc_str = shift;

	$self->{upc} = Upc->new($upc_str);
	$self->{price} = shift;
	$self->{description} = shift;
	$self->{qty_sold} = shift;
    }




    bless $self, $class;
}

sub get_depno {
    my $self = shift;


    return $self->{depno};
}

sub set_depno {
    my $self = shift;
    my $depno = shift;
    
    $self->{depno} = $depno;
}




sub get_upc {
    my $self = shift;

    return $self->{upc};

}

sub set_upc {
    my $self = shift;

    my $upc = shift;

    $self->{upc} = $upc;

}


sub get_price {
    my $self = shift;

    return $self->{price};

}

sub set_price {
    my $self = shift;
    my $price = shift;

    $self->{price} = $price;
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

    

sub  get_qty_sold {
    my $self = shift;
    return $self->{qty_sold};

}

sub set_qty_sold {
    my $self = shift;
    my $qty_sold = shift;

    $self->{qty_sold} = $qty_sold;
}

1
