#!/usr/bin/perl



use warnings;
use strict;
use Carp;


package Core::InvoiceInfo;

# InvoiceInfo
sub new {
    my $class = shift;


    my $self = {
	sku           => undef,
	qty_received  => undef,
    };



    bless $self, $class;

    return $self;

}

# InvoiceInfo
sub get_sku {
    my $self = shift;

    return $self->{sku};
}

# InvoiceInfo
sub set_sku {
    my $self = shift;
    my $sku = shift;


    $self->{sku} = $sku;
}

# InvoiceInfo
sub get_qty_received {
    my $self = shift;

    return $self->{qty_received};
}

# InvoiceInfo
sub set_qty_received {
    my $self = shift;
    my $qty_received = shift;

    $self->{qty_received} = $qty_received;

}



1
