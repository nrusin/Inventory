#!/usr/bin/perl -I ../

use strict;
use warnings;


package DB::Stockroom;

sub new {
    my $class = shift;
    my $self = {
	name => shift
    };


    bless $self, $class;
}


sub get_name {
    my $self = shift;
   
    return $self->{name};
}



1
  
