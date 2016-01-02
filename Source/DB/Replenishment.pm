#!/usr/bin/perl

use strict;
use warnings;



package DB::Replenishment;

sub new {
    my $class = shift;
   

    my $self = {
	dbh => shift,
        replen_id => shift
    };

    bless $self, $class;

    return $self;
}


sub get_beginning_datetime {
    my $self = shift;


    my $dbh = $self->{dbh};
    my $replen_id = $self->{replen_id};


    my $sth = $dbh->prepare("SELECT begin_datetime
                             FROM Replenishments
                             WHERE id = ?");

    $sth->bind_param(1, $replen_id);


    if (!$sth->execute()) {

	die "get_beginning_datetime failed at execute!\n";
    }

    my $beginning_datetime_str;
    my $beginning_datetime;



    ($beginning_datetime_str)  = $sth->fetchrow_array();
    if (!defined($beginning_datetime_str)) {
	return undef;
    }



    my $db_parser = DateTime::Format::DBI->new($dbh);


    $beginning_datetime = $db_parser->parse_datetime($beginning_datetime_str);



    return $beginning_datetime;
}


sub get_ending_datetime {
    my $self = shift;


    my $dbh = $self->{dbh};
    my $replen_id = $self->{replen_id};


    my $sth = $dbh->prepare("SELECT end_datetime
                             FROM Replenishments
                             WHERE id = ?");

    $sth->bind_param(1, $replen_id);


    if (!$sth->execute()) {

	die "get_beginning_datetime failed at execute!\n";
    }

    my $ending_datetime_str;
    my $ending_datetime;



    ($ending_datetime_str)  = $sth->fetchrow_array();
    if (!defined($ending_datetime_str)) {
	return undef;
    }



    my $db_parser = DateTime::Format::DBI->new($dbh);


    $ending_datetime = $db_parser->parse_datetime($ending_datetime_str);



    return $ending_datetime;

}


1
