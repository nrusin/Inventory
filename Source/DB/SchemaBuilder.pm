#!/usr/bin/perl
use warnings;
use strict;
use DBI;


package DB::SchemaBuilder;


# Create a new Schema Builder passing in a valid database connection
sub new {
    my $class = shift;

    my $self = {
	dbh => shift
    };


    bless $self, $class;
    

    return $self;
}

sub connect_to_sqlite {
    my $class = shift;
    my $dbname = shift;

    print "dbname = " . $dbname . "\n";
    
    my $dbh = DBI->connect("dbi:SQLite:dbname=$dbname", "", "",
			   { RaiseError => 1});

    $dbh->{AutoCommit} = 0;


    return $dbh;
}

# Returns true if the table exists in the database, false otherwise
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


    if (!$self->does_table_exist("Unit_types")) {
	$sth = $dbh->prepare("CREATE TABLE Unit_types (
                                  id INTEGER NOT NULL PRIMARY KEY,
                                  unit_type VARCHAR(128))");

	if (!$sth->execute()) {
	    die "Building the database failed!";
	}


	$sth = $dbh->prepare("INSERT INTO Unit_types 
                             VALUES (0, 'pc(s)')");

	if (!$sth->execute()) {
	    die "Building the database failed!";
	}


	$sth = $dbh->prepare("INSERT INTO Unit_types 
                              VALUES(1, 'box(s)')");
	
	if (!$sth->execute()) {
	    die "Building the database failed!";
	}

	$sth = $dbh->prepare("INSERT INTO Unit_types 
                              VALUES(2, 'case-pack(s)')");

	if (!$sth->execute()) {
	    die "Building the database failed!";
	}
	
    }
    
    if (!$self->does_table_exist("Stockrooms")) {
	$sth = $dbh->prepare("CREATE TABLE Stockrooms (
                              id INTEGER NOT NULL PRIMARY KEY,
                              name VARCHAR(256),
                              purpose)");

	if (!$sth->execute()) {
	    die "Building stockroom failed";
	}


	$sth = $dbh->prepare("INSERT INTO Stockrooms(id, name, purpose)
                              VALUES(NULL, 'Airport', 'Secondary')");

	if (!$sth->execute()) {
	    die "Building stockroom failed!";
	}


	$sth = $dbh->prepare("INSERT INTO Stockrooms(id, name, purpose)
                              VALUES(NULL, 'Genco', 'Primary')");

	if (!$sth->execute()) {
	    die "Building stockroom failed!";
	}
	
    }

    
	
	

    if (!$self->does_table_exist("Department_groups")) {
	$sth = $dbh->prepare("CREATE TABLE Department_groups (
                                             id INTEGER NOT NULL PRIMARY KEY,
                                             name VARCHAR(128))");

	if (!$sth->execute()) {
	    die "Building the database failed!";
	}
    }
    


    if (!$self->does_table_exist("Departments")) {

	$sth = $dbh->prepare("CREATE TABLE Departments (
                                            id INTEGER NOT NULL,
                                            depno INTEGER,
                                            department VARCHAR(128),
                                            default_unit_type INTEGER,
                                            PRIMARY KEY(id),
                                            FOREIGN KEY(default_unit_type) 
                                               REFERENCES Unit_types)

                                 ");


	if (!$sth->execute()) {
	    die "Building the database failed!";

	}

    }

    if (!$self->does_table_exist("Vendors")) {
	$sth = $dbh->prepare("CREATE TABLE Vendors (
                                    vendor_id INTEGER PRIMARY KEY,
                                    vendor_name VARCHAR(128),
                                    telno VARCHAR(10),
                                    faxno VARCHAR(10),
                                    city VARCHAR(128),
                                    state VARCHAR(128),
                                    street VARCHAR(128))");


	if (!$sth->execute()) {
	    die "Building the database failed!\n";
	}
    }


    if (!$self->does_table_exist("Vendors_alternate_ids")) {
	$sth = $dbh->prepare("CREATE TABLE Vendors_alternate_ids (
                                 alternate_vendor_id INTEGER PRIMARY KEY,
                                 master_vendor_id INTEGER,
                                 FOREIGN KEY(master_vendor_id) REFERENCES Vendors)");

	if (!$sth->execute()) {
	    die "Building the database failed!\n";
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


    if (!$self->does_table_exist("Stock_takes")) {
	$sth = $dbh->prepare("CREATE TABLE Stock_takes (
                                            id INTEGER PRIMARY KEY NOT NULL,
                                            datetime_counted DATETIME,
                                            stockroom_id INTEGER,
                                            FOREIGN KEY(stockroom_id) REFERENCES Stockrooms)");
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
                                             PRIMARY KEY(id),
                                             FOREIGN KEY(SKU) REFERENCES Products,
                                             FOREIGN KEY(master_id) REFERENCES Stock_takes)");
	if (!$sth->execute()) {
	    die "Building the database failed!\n";
	}
	

    }



    if (!$self->does_table_exist("Transfers")) {
	$sth = $dbh->prepare("CREATE TABLE Transfers (
                              id INTEGER PRIMARY KEY NOT NULL,
                              from_stockroom, 
                              to_stockroom,
                              datetime DATETIME,
                              FOREIGN KEY(from_stockroom) REFERENCES Stockrooms,
                              FOREIGN KEY(to_stockroom) REFERENCES Stockrooms
                              )");

	if (!$sth->execute()) {
	    die "Building the database failed!";
	}

    }

    if (!$self->does_table_exist("Transfers_detail")) {
	$sth = $dbh->prepare("CREATE TABLE Transfers_detail (
                                  id INTEGER PRIMARY KEY NOT NULL,
                                  master_transfer_id REFERENCES Transfers,
                                  SKU INTEGER NOT NULL,
                                  qty_transfered INTEGER NOT NULL,
                                  FOREIGN KEY(master_transfer_id) REFERENCES Transfers,
                                  FOREIGN KEY(sku) REFERENCES Products
                                              ON UPDATE CASCADE
                               )");


	if (!$sth->execute()) {
	    die "Building the database failed!";
	}
                                  
    }
                           
    if (!$self->does_table_exist("Invoices_detail")) {
	$sth = $dbh->prepare("CREATE TABLE Invoices_detail (
                                 id INTEGER NOT NULL PRIMARY KEY,
                                 SKU INTEGER NOT NULL,
                                 qty_received INTEGER,
                                 master_invoice_id INTEGER NOT NULL,
                                 FOREIGN KEY(SKU) REFERENCES Products
                             )");

	if (!$sth->execute()) {
	    die "Building the database failed\n";
	    
	}
    }




    if (!$self->does_table_exist("Invoices")) {
	$sth = $dbh->prepare("CREATE TABLE Invoices (
                                  invoice_id INTEGER NOT NULL PRIMARY KEY,
                                  datetime_received DATETIME,
                                  PO INTEGER,
                                  stockroom_id INTEGER,
                                  FOREIGN KEY(stockroom_id) REFERENCES Stockrooms)");
                                  
	
	if (!$sth->execute()) {
	    die "Building the database failed\n";
	}
    }


    if (!$self->does_table_exist("Replenishments_detail")) {
	$sth = $dbh->prepare("CREATE TABLE Replenishments_detail (
                                id INTEGER NOT NULL PRIMARY KEY,
                                SKU INTEGER NOT NULL,
                                qty_sold INTEGER,
                                master_replenishment_id INTEGER NOT NULL,
                                FOREIGN KEY(SKU) REFERENCES Products)");


	if (!$sth->execute()) {
	    die "Building the database failed!\n";

	}
    }



    if (!$self->does_table_exist("Replenishments")) {
	$sth = $dbh->prepare("CREATE TABLE Replenishments (
                                id INTEGER PRIMARY KEY NOT NULL,
                                begin_datetime DATETIME,
                                end_datetime DATETIME,
                                stockroom_id INTEGER,
                                FOREIGN KEY(stockroom_id) 
                                    REFERENCES Stockrooms)");
                             
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

    $sth = $dbh->prepare("DROP TABLE IF EXISTS Vendors");
    $sth->execute();

    $sth = $dbh->prepare("DROP TABLE IF EXISTS Vendors_alternate_id");
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

    $sth = $dbh->prepare("DROP TABLE IF EXISTS Transfers");
    $sth->execute();

    $sth = $dbh->prepare("DROP TABLE IF EXISTS Transfers_detail");
    $sth->execute();
}


sub get_error_message {


}

1
