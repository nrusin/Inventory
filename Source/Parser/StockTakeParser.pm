#!/usr/bin/perl


use warnings;
use strict;
use Spreadsheet::XLSX;
use DateTime::Format::Excel;
use Core::Upc;


package Parser::StockTakeParser;

# StockTakeParser
sub new {
    my $class = shift;
    
    my $self = {
	row => undef,
	excel => undef,
	sheet => undef,
	st_datetime => undef
    };



    

    bless $self, $class;

}

sub get_datetime {
    my $self = shift;


    return $self->{st_datetime};
}



# StockTakeParser
sub open {
    my $self = shift;
    my $fname = shift;

    
    eval {


	my $excel = Spreadsheet::XLSX->new($fname);

	$self->{excel} = $excel;


	my @sheets = @{$excel->{Worksheet}};
	
	my $sheet = $sheets[0];

	$self->{sheet} = $sheet;

	$self->{row} = 0;

	$self->read_header();

       
    }; die $@ if $@;

}


# StockTakeParser
sub next {
    my $self = shift;



    $self->{row}++;
}



# StockTakeParser
sub eof {
    my $self = shift;
    my $sheet = $self->{sheet};
    return $self->{row} > $sheet->{MaxRow};
    
}


# StockTakeParser
sub read_header {
    my $self = shift;

    my $row = $self->{row};
    my $sheet = $self->{sheet};

    if ($sheet->{MinCol} + 2 > $sheet->{MaxCol}) {
	die "Invalid Stock take format!\n";
    }


    if ($sheet->{Cells}[$row][$sheet->{MinCol}]->{Val} ne "Date Time:") {
	die "Invalid Stock take format!\n";
    }


    my $datetime;

    $datetime = $sheet->{Cells}[$row][$sheet->{MinCol}+1]->{Val};


    
    $self->{st_datetime} = DateTime::Format::Excel->parse_datetime($datetime);

    
    $self->{row}++;
    
    if ($sheet->{Cells}[$self->{row}][$sheet->{MinCol}]->{Val} ne "Description") {

	die "Invalid Stock take format!\n";
    }

    if ($sheet->{Cells}[$self->{row}][$sheet->{MinCol}+1]->{Val} ne "UPC") {
	die "Invalid Stock take format!\n";
    }



    if ($sheet->{Cells}[$self->{row}][$sheet->{MinCol}+2]->{Val} ne "Quantity") {
	die "Invalid Stock take format!\n";

    }


    $self->{row}++;
}


# StockTakeParser 
sub get_header {
    my $self = shift;

}


# StockTakeParser
sub get_stock_take_info {
    my $self = shift;


    my $stock_take_info = Core::StockTakeInfo->new();


    my $row = $self->{row};


    my $sheet = $self->{sheet};


    if ($sheet->{MinCol} + 2 > $sheet->{MaxCol}) {

	die "Invalid stock take format!\n";
    }

    my $description = $sheet->{Cells}[$row][$sheet->{MinCol}]->{Val};
    my $upc = $sheet->{Cells}[$row][$sheet->{MinCol} + 1]->{Val};
    my $qty = $sheet->{Cells}[$row][$sheet->{MinCol} + 2]->{Val};


    
    if ($description eq "") {
	return undef;
    }
    

    if (defined($upc) && $upc =~ m/\d+/) {
	$stock_take_info->set_upc(Core::Upc->new($upc));
    }

    if (defined($qty) && $qty =~ m/\d+/) {
	$stock_take_info->set_qty_counted($qty);
    }

    $stock_take_info->set_description($description);
    

    return $stock_take_info;
}

1
