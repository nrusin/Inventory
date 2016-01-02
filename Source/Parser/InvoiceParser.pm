# !/usr/bin/perl

use strict;
use warnings;
use Spreadsheet::XLSX;
use Carp;
use DateTime::Format::Excel;
use DateTime;
use Core::InvoiceInfo;


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

sub get_datetime {
    my $self = shift;


    if (!defined($self->{datetime_of_invoice})) {
	die "datetime_of_invoice must be defined";
    }
    

    return $self->{datetime_of_invoice};
}


sub open {
    my $self = shift;
    my $fname = shift;

    eval {
	$self->{excel} = Spreadsheet::XLSX->new($fname);
	
	my $excel = $self->{excel};
	
	my @sheets = @{$excel->{Worksheet}};
	
	$self->{sheet} = $sheets[0];


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

    my $invoice_entry = Core::InvoiceInfo->new();

    my $col = $self->{sheet}->{MinCol};


    my @headers = @{$self->{headers}};


    my %invoice_entry;
    

    foreach my $header (@headers) {
	my $val = $self->elem($self->{row}, $col);

	if ($header eq "Item #") {
	    $invoice_entry{item_no} = $val;

	} elsif ($header eq "Description") {
	    $invoice_entry{description} = $val;

	} elsif ($header eq "UPC") {
	    $invoice_entry{upc_str} = $val;

	} elsif ($header eq "Unit") {
	    $invoice_entry{unit} = $val;

	} elsif ($header eq "Quantity Received") {
	    $invoice_entry{qty_received} = $val;

	} elsif ($header eq "Cost per Unit") {
	    $invoice_entry{cost_per_unit} = $val;
	} elsif ($header eq "Cost") {
	    $invoice_entry{cost} = $val;

	}


	$col++;

    }

    return %invoice_entry;
}

sub read_department_header {
    my $self = shift;

    my $col = $self->{sheet}->{MinCol};

    if ($self->elem($self->{row}, $col) ne "Department:") {
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


    $self->{row}++;
}



sub read_header {
    my $self = shift;

    my $sheet = $self->{sheet};

    if ($self->elem($self->{row}, $sheet->{MinCol}) ne "Datetime:") {
	die "Invoice in wrong format";
    }


    my $date_str = $self->elem($self->{row}, $sheet->{MinCol} + 1);
    
    print "date_str = $date_str\n";


    $self->{datetime_of_invoice} = DateTime::Format::Excel->parse_datetime($date_str);
    

    $self->{row}++;
    
    foreach my $col ($sheet->{MinCol}..$sheet->{MaxCol}) {


	push @{$self->{headers}}, $self->elem($self->{row}, $col);
    }


    my @neccessary_headers = ["Item #", "Description", "UPC", "Unit", "Quantity Received",
			      "Cost per Unit", "Cost"];



    foreach my $neccessary (@neccessary_headers) {

	if (!defined(grep {$_ eq $neccessary} $self->{headers})) {
	    
	    die "Invoice must have $neccessary!\n";
	}


    } 

    $self->{row}++;

}


sub eof {
    my $self = shift;
    return $self->{row} > $self->{sheet}->{MaxRow};

}

sub next {
    my $self = shift;

    $self->{row}++;


    if (!defined($self->elem($self->{row}, $self->{sheet}->{MinCol}))) {
	return;
    }
    
    
    if ($self->elem($self->{row}, $self->{sheet}->{MinCol}) eq "Department:") {
	$self->read_department_header();
	
    }

}



1
