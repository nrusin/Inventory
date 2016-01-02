#!/usr/bin/perl
use warnings;
use strict;



package DB::SchemaBuilder;

sub new {
    my $class = shift;

    my $self = {
	dbh => shift
    };


    bless $self, $class;
    

    return $self;
}


sub does_table_exist {
    my $self = shift;
    my $tname = shift;



    my $dbh = $self->{dbh};


    my $schema = undef;
    my $sth = $dbh->table_info("", $schema, $tname, "TABLE");

    if (!$sth->fetch) {
	return 0;
    } 


    return 1;

}


sub build {
    my $self = shift;
    my $dbh = $self->{dbh};


    my $sth;


    if (!$self->does_table_exist("Stock_takes")) {
	$sth = $dbh->prepare("CREATE TABLE Stock_takes (
                                            id INTEGER PRIMARY KEY NOT NULL,
                                            datetime_counted DATETIME)");
	if (!$sth->execute()) {
	    die "Building the datebase failed\n";
	    
	}
    }


    if (!$self->does_table_exist("Stock_takes_detail")) {

	$sth = $dbh->prepare("CREATE TABLE Stock_takes_detail (
                                             id INTEGER NOT NULL,
                                             master_id INTEGER NOT NULL,
                                             SKU INTEGER NOT NULL,
                                             qty_counted INTEGER NOT NULL,
                                             PRIMARY KEY(id))");
	if (!$sth->execute()) {
	    die "Building the database failed!\n";
	}


    }



    if (!$self->does_table_exist("Departments")) {

	$sth = $dbh->prepare("CREATE TABLE Departments (
                                            id INTEGER NOT NULL,
                                            depno INTEGER,
                                            department VARCHAR(128),
                                            PRIMARY KEY(id))");

	if (!$sth->execute()) {
	    die "Building the database failed\n";
	}
    }

                    

    if (!$self->does_table_exist("Categories")) {
	$sth = $dbh->prepare("CREATE TABLE Categories (
                                          category_id INTEGER NOT NULL,
                                          category VARCHAR(128),
                                          PRIMARY KEY(category_id))");
	if (!$sth->execute()) {
	    die "Building the database failed\n";
	}
    }



    if (!$self->does_table_exist("Products")) {
	$sth = $dbh->prepare("CREATE TABLE Products (
                           SKU          INTEGER PRIMARY KEY,
                           upc          VARCHAR(14),
                           description  VARCHAR(128),
                           unit         INTEGER,
                           case_pack    INTEGER,
                           dep_no       INTEGER,
                           cost         DECIMAL,
                           unit_cost    DECIMAL,
                           par          INTEGER,
                           item_no      INTEGER,
                           category_id  INTEGER,
                           loc          INTEGER,
                           units_in_bx  INTEGER,
                           price        DECIMAL,
                           eoq          INTEGER
                   )");

    
	if (!$sth->execute()) {
	    die "Building the database failed\n";
	    
	}
    }





    if (!$self->does_table_exist("Invoices_detail")) {
	$sth = $dbh->prepare("CREATE TABLE Invoices_detail (
                                 id INTEGER NOT NULL PRIMARY KEY,
                                 SKU INTEGER NOT NULL,
                                 qty_received INTEGER,
                                 master_invoice_id INTEGER NOT NULL)");

	if (!$sth->execute()) {
	    die "Building the database failed\n";
	    
	}
    }




    if (!$self->does_table_exist("Invoices")) {
	$sth = $dbh->prepare("CREATE TABLE Invoices (
                                  invoice_id INTEGER NOT NULL PRIMARY KEY,
                                  datetime_received DATETIME,
                                  PO INTEGER)");
                                  
	
	if (!$sth->execute()) {
	    die "Building the database failed\n";
	}
    }


    if (!$self->does_table_exist("Replenishments_detail")) {
	$sth = $dbh->prepare("CREATE TABLE Replenishments_detail (
                                id INTEGER NOT NULL PRIMARY KEY,
                                SKU INTEGER NOT NULL,
                                qty_sold INTEGER,
                                master_replenishment_id INTEGER NOT NULL)");


	if (!$sth->execute()) {
	    die "Building the database failed!\n";

	}
    }



    if (!$self->does_table_exist("Replenishments")) {
	$sth = $dbh->prepare("CREATE TABLE Replenishments (
                                id INTEGER PRIMARY KEY NOT NULL,
                                begin_datetime DATETIME,
                                end_datetime DATETIME)");
                             
	if (!$sth->execute()) {
	    die "Building the database failed\n";
	    
	}
    }

                           

}


sub unbuild {
    my $self = shift;

    my $sth;
    my $dbh = $self->{dbh};

    $sth = $dbh->prepare("DROP TABLE IF EXISTS Stock_takes");
    $sth->execute();

    $sth = $dbh->prepare("DROP TABLE IF EXISTS Stock_takes_detail");
    $sth->execute();

    $sth = $dbh->prepare("DROP TABLE IF EXISTS Departments");
    $sth->execute();


    $sth = $dbh->prepare("DROP TABLE IF EXISTS Categories");
    $sth->execute();


    $sth = $dbh->prepare("DROP TABLE IF EXISTS Products");
    $sth->execute();


    $sth = $dbh->prepare("DROP TABLE IF EXISTS Invoices_detail");
    $sth->execute();


    $sth = $dbh->prepare("DROP TABLE IF EXISTS Invoices");
    $sth->execute();


    $sth = $dbh->prepare("DROP TABLE IF EXISTS Replenishments_detail");
    $sth->execute();

    $sth = $dbh->prepare("DROP TABLE IF EXISTS Replenishments");
    $sth->execute();

}


sub get_error_message {


}

1
