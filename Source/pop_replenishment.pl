#!/usr/bin/perl


use warnings;
use strict;

use DBI;
use DB::SchemaBuilder;

my $dbh = DBI->connect("dbi:SQLite:dname=p.db", "", "",
		       {RaiseError => 1});


my $sb = DB::SchemaBuilder->new($dbh);

$sb->build();

my $sth;


$dbh->{AutoCommit} = 0;


$sth = $dbh->prepare("SELECT id 
                         FROM Replenishments 
                         WHERE end_datetime = (SELECT max(end_datetime) FROM Replenishments)");

if (!$sth->execute()) {

    die "Error executing pop_replenishment!\n";
}


my ($id) = $sth->fetchrow_array();


if (defined($id)) {
    $sth = $dbh->prepare("DELETE FROM Replenishments_detail
                          WHERE master_replenishment_id=?");

    $sth->bind_param(1, $id);


    if (!$sth->execute()) {

	die "Error executing pop_replenishment!\n";
    }


    $sth = $dbh->prepare("DELETE FROM Replenishments
                          WHERE id = ?");

    $sth->bind_param(1, $id);

    if (!$sth->execute()) {
	die "Error executing pop_replenishment!\n";

    }

}

$dbh->commit();

                         
