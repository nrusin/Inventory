#!/usr/bin/perl

use warnings;
use strict;
use Carp;
use Core::Upc;

use Core::ProductInfo;

use Spreadsheet::XLSX;

package Parser::OrderParser;


# OrderParser

sub new {
    my $class = shift;

    my $self = { };

    $self->{excel} = undef;
    $self->{sheet} = undef;
    $self->{row} = undef;
    $self->{header} = undef;
    $self->{at_eof} = undef;


    bless $self, $class;
}

# OrderParser
#
#
sub next {
    my $self = shift;


    $self->{row}++;
}


# OrderParser
#
#
sub reset {
    my $self = shift;
    
    my $sheet = $self->{sheet};

    $self->{at_eof} = 0;

    $self->{row} = $sheet->{MinRow} + 1;

    $self->read_header();
}





# OrderParser
#
#

sub get_order_info {
    my $self = shift;

    my $excel = $self->{excel};

    my @sheets = @{$excel->{Worksheet}};

    my $sheet = $sheets[0];

    my $row = $self->{row};
    my $col;

    my @line;

    foreach $col ($sheet->{MinCol} .. $sheet->{MaxCol}) {
	my $cell = $sheet->{Cells}[$row][$col];

	
	push @line, $cell->{Val};
    }


    my @header = @{$self->{header}};

    my $i = 0;

    my $pi = Core::ProductInfo->new();

    my $qty = undef;
    
    foreach my $field(@header) {
	my $val = $line[$i];

	if ($field eq "Item #") {

	    $pi->set_item_no($val);

	} elsif ($field eq "Quantity") {
	    $qty = $val;
	} elsif ($field eq "Description") {
	    $_ = $val;

	    s/&apos;/'/g;
	    s/&quot;/"/g;
	    s/&amp;/&/g;
	    $pi->set_description($_);

	} elsif ($field eq "Unit") {

	    if (!defined($val)) {

		warn $pi->get_description() . " is supposed to have unit";
	    } else {
		
		$pi->set_unit($val);

	    }

	} elsif ($field eq "Case Pack") {
	    if (defined($val)) {
		$pi->set_case_pack($val);
	    }

	} elsif ($field eq "Cost") {
	    if (defined($val)) {
		$pi->set_cost($val);
	    }

        } elsif ($field eq "Unit Cost") {
	    if (defined($val)) {
		$pi->set_unit_cost($val);
	    }

	} elsif ($field eq "Retail") {
	    if (defined($val)) {
		$pi->set_retail($val);
	    }
        } elsif ($field eq "Unit UPC") {
	    if (defined($val) && ($val =~ /(\d)+/)) {
		$pi->set_upc(Core::Upc->new($val));
	    }

        } elsif ($field eq "EOQ") {
	    if (defined($val)) {
		$pi->set_eoq($val);
	    }

        } elsif ($field eq "Dep#") {
	    if (defined($val)) {
		$pi->set_department_no($val);
	    }

        } elsif ($field eq "Category") {
	    
	} elsif ($field eq "Par") {
	    if (defined($val)) {
		$pi->set_par($val);
	    }

	} elsif ($field eq "Loc") {
	    if (defined($val)) {
		$pi->set_location($val);
	    }

	}

	$i++;
    }

    my %order;


    $order{pi} = $pi;
    $order{qty} = $qty;


 
    return \%order;
}

# OrderParser
#
sub open {
    my $self = shift;
    my $fname = shift;

    eval {
	my $excel = Spreadsheet::XLSX->new($fname);

	$self->{excel} = $excel;

	my @sheets = @{$excel->{Worksheet}};

	my $sheet = $sheets[0];
	$self->{sheet} = $sheet;
	$self->{row} = $sheet->{MinRow} + 1;

	$self->read_header();

    }; die $@ if $@;


}

# OrderParser
#
#

sub at_eof {
    my $self = shift;

    my $sheet = $self->{sheet};

    if (!defined($self->{row})) {
	print "row undefined!\n";
    }

    if (!defined($sheet->{MaxRow})) {
	print "undefined MaxRow!\n";
    }


    return $self->{row} > $sheet->{MaxRow};

}

# OrderParser
#
#
#
sub read_header {
    my $self = shift;
    my $excel = $self->{excel};

    my @sheets = @{$excel->{Worksheet}};
    
    my $sheet = $sheets[0];
    
    my $header_row = $sheet->{MinRow};
    my @header;
    
	
    my $cell = $sheet->{Cells}[$header_row][0];
    
    for my $col ($sheet->{MinCol} .. $sheet->{MaxCol}) {
	$cell = $sheet->{Cells}[$header_row][$col];
	
	push @header, $cell->{Val};
	
    }
    
    $self->{row} = $header_row  + 1;
    $self->{col} = $sheet->{MinCol};
    
    $self->{header} = \@header;
    

#	foreach my $c (@header) {

#	    print $c . "\n";
#	}



}

# OrderParser
sub read_next_row {


}

1
