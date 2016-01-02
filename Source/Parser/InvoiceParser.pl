# !/usr/bin/perl

use strict;
use warnings;
use Spreadsheet::XLSX;
use Carp;
use DateTime::Format::Excel;
use DateTime;

require 'core.pl';



package Parser::InvoiceParser;


sub new {
    my $class = shift;

    my $self =  { 
	row                 => undef,
	excel               => undef,
	sheet               => undef,
	datetime_of_invoice => undef,
	current_depno       => undef,
	headers             => [ ]
    };



   


    bless $self, $class;
}



sub open {
    my $self = shift;
    my $fname = shift;

    eval {
	$self->{excel} = Spreadsheet::XLSX->new($fname);
	

	$self->{sheet} = (@$self->{excel}->{Worksheet})[0];


	$self->{row} = $self->{sheet}->{MinRow};
    }; die $@ if $@;

    $self->read_header();
    $self->read_department_header();

}

sub elem {
    my $self = shift;
    my $row = shift;
    my $col = shift;


    return $self->{sheet}->{Cells}[$row][$col]->{Val};
}

sub get_invoice_entry {
    my $self = shift;

    my $invoice_entry = InvoiceInfo->new();

    my $col = $self->{sheet}->{MinCol};
    foreach $header ($self->{headers}) {
	my $val = elem($self->{row}, $col);

	if ($header eq "Item #") {
	    $invoice_entry->set_item_no($val);

	} elsif ($header eq "Description") {
	    $invoice_entry->set_description($val);

	} elsif ($header eq "UPC") {
	    $invoice_entry->set_upc($val);

	} elsif ($header eq "Unit") {
	    $invoice_entry->set_unit($val);

	} elsif ($header eq "Quantity Received") {
	    $invoice_entry->set_qty_received($val);

	} elsif ($header eq "Cost per Unit") {
	    $invoice_entry->set_cost_per_unit($val);
	} elsif ($header eq "Cost") {
	    $invoice_entry->set_cost($val);

	}


	$col++;

    }

}

sub read_department_header {
    my $self = shift;

    my $col = $self->{sheet}->{MinCol};

    if ($self->elem($self->{row}, $col) ne "Department") {
	die "Expected Department: at $self->{row}";
    }
    
    if ($col + 1 > $self->{sheet}->{MaxCol}) {
	die;
    }

    
    my $depno = $self->elem($self->{row}, $col + 1);

    if ($depno =~ /^\d+$/) {
	$self->{current_depno} = $depno;	
    } else {
	print "Department number not an integer!\n";
    }



}



sub read_header {
    my $self = shift;

    my $sheet = $self->{sheet};

    foreach my $col ($sheet->{MinCol}..$sheet->{MaxCol}) {
	push $self->{headers}, $self->{excel}->{Cells}[$self->{row}][$col]->{Val};
    }


    my @neccessary_headers = ["Item #", "Description", "UPC", "Unit", "Quantity Received",
			      "Cost per Unit", "Cost"];



    foreach my $neccessary (@neccessary_headers) {

	if (!defined(grep {$_ eq $neccessary} $self->{headers})) {
	    
	    die "Invoice must have $neccessary!\n";
	}


    } 


}


sub eof {
    my $self = shift;
    return $self->{row} > $self->{sheet}->{MaxRow};

}

sub next {
    my $self = shift;

    $self->{row}++;


    if ($self->elem($self->{row}, $self->{sheet}->{MinCol}) eq "Department") {
	$self->read_department_header();
	
    }

}



1
