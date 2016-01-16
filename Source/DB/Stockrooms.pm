#!/usr/bin/perl

use DB::Stockroom;

use warnings;
use strict;


package DB::Stockrooms;


sub new {
    my $class = shift;
    my $self = { dbh => shift };

    bless $self, $class;

}

# Retrieve a stockroom's id from a stockroom's name
sub get_stockroom_id {
    my $self = shift;
    my $name = shift;

    my $dbh = $self->{dbh};
    
    my $sth = $dbh->prepare("SELECT id
                             FROM Stockrooms
                             WHERE name = ?");

    $sth->bind_param(1, $name);

    if (!$sth->execute()) {
	die "get_stockroom_id failed at execute!\n";

    }


    my $stockroom_id;

    ($stockroom_id) = $sth->fetchrow_array();


    if (!defined($stockroom_id)) {
	die "Invalid stockroom";
    }

    return $stockroom_id;
}

sub get_iterator {

    return DB::Stockrooms_iterator->new($dbh);

}



package DB::Stockrooms_iterator;


sub new {
    my $class = shift;
    my $self = { dbh => shift, sth => undef };



    $self->{sth} = $self->{dbh}->prepare("SELECT * FROM Stockrooms");


    if (!$self->{sth}->execute()) {
	die "Execute failed!";

    }
    
    bless $self, $class;

}


sub fetch {



}








1
