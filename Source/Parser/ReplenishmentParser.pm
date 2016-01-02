#!/usr/bin/perl


use warnings;
use strict;

use Spreadsheet::XLSX;
use DateTime::Format::Excel;
use Core::Upc;
use Core::ReplenishmentEntry;


sub is_natural_number {
    my $n = shift;


    return $n =~ m/\d+/;

}


my $upc_map = {
    "022000012111"   => "022000012104",
    "022000009135"   => "022000006677",
    "098000076156"   => "009800007615",
    "098000077214"   => "009800007721",
    "098000076392"   => "009800007639",
    "098000077832"   => "009800007783",
    "098000074008"   => "009800007400",
    "098000076774"   => "009800007677",
    "098000076088"  => "009800007608",
    "0980000764610" => "098000007646",
    "040000009771"   => "040000004325",
    "040000009788"   => "040000004318",
    "10040000017315" => "040000017318",
    "855919003136"   => "855919033136",
    "034000471522"   => "034000003303",
    "022200003322"   => "022200940207",
    "073852096507"   => "352800658661",
    "10076828047029" => "076828046551",
    "016500537755"   => "016500555278",
    "016500545446"   => "016500537649",
    "312546050006"   => "312546637580",
    "312843024717"   => "5128430247147",
    "363824008363"   => "363824056364",
    "307660739197"   => "307660741206",
    "307660740605"   => "307660740650",
    
    "035000551009"   => "035000555403",
    "312547427036"   => "312547427951",
    "10040822011997" => "040822011990",
    "602652172199"   => "602652170195",
    "028400037594"   => "028400086400",

    "077975022337"   => "077975083413",
    
    "098008000566"   => "009800800056",

    "014054320281"   => "014054330280",
    "014054320397"   => "014054330396",
    "014054320373"   => "014054330372",
    "014054320250"   => "014054330358",
    "851659003184"   => "851659003788",
    "851659003191"   => "851659003771",
    "021000000227"   => "021000019786",
    "079944921016"   => "070330902831",
    "830961001484"   => "830961011315",
    "070462035988"   => "70462098662",
    "70462035988"    => "70462098679"




};




package Parser::ReplenishmentParser;

# ReplenishmentParser
#
# Return true if at end of file, false otherwise
#
sub eof {
    my $self = shift;
    my $sheet = $self->{sheet};

    return $self->{row} >= $sheet->{MaxRow} + 1;

}


# Replenishment Parser
#
#
# Create new replenishment parser
sub new {
    my $class = shift;

    my $self = { 
	row => undef,
	excel => undef,
	sheet => undef,
	current_dep => undef,
	current_depno => undef,
	beginning_date => undef,
	ending_date => undef
    };



    bless $self, $class;

}


# Replenishment Parser
#
# Go to next replenishment entry
#
sub next {
    my $self = shift;
    my $val;

    my $sheet = $self->{sheet};

    $self->{row}++;
    

    $val = $sheet->{Cells}[$self->{row}][$sheet->{MinCol}]->{Val};


    if (defined($val) && $val eq "Department Subtotal:") {
	$self->read_subtotal_header();


	$val = $sheet->{Cells}[$self->{row}][$sheet->{MinCol}]->{Val};

	if ($val eq "Department") {
	    $self->read_department_header();
	} else {
	    $self->{row} = $sheet->{MaxRow} + 1;
	}
	
    }

    
	

}

# ReplenishmentParser
#
# Get the current replenishment entry
#
sub get_replenishment_entry {
    my $self = shift;

    my @data;
    my $sheet = $self->{sheet};

    foreach my $col ($sheet->{MinCol}..$sheet->{MaxCol}) {
	my $val = $sheet->{Cells}[$self->{row}][$col]->{Val};

	push @data, $val;

    }

    my $vendor_no;
    my $vendor_name;
    my $description;
    my $units_sold;
    my $product_no;
    my $product_upc;
    my $color;
    my $size;
    my $price;

    $vendor_no  = $data[0];

    $_ = $data[0];
    s/&apos;/'/g;
    s/&quot;/"/g;
    s/&amp;/&/g;

    $vendor_name = $_;


    $_ = $data[2];
    s/&apos;/'/g;
    s/&quot;/"/g;
    s/&amp;/&/g;

    $description = $_;


    $units_sold = $data[3];
    $product_no = $data[4];


    my $upc_text = $data[5];
    if (defined($upc_text)) {
	my $len = length($upc_text);

	if ($len < 12 && $len > 8) {
	    $upc_text = "0"*(12-$len) . $upc_text;
	}

	if ($len == 8) {
	    if ($upc_text =~ /^0(\d\d\d\d\d\d\d)$/) {

		$upc_text = $1;
	    }

	}

	$product_upc = Core::Upc->new($upc_text);



	$product_upc->convert_to_upc_a();



	if ($upc_map->{$product_upc->str()}) {
	    $product_upc = Core::Upc->new($upc_map->{$product_upc->str()});

	}

    }




    $color = $data[6];
    $size = $data[7];
    $price = $data[8];

    my $re = Core::ReplenishmentEntry->new();

    $re->set_upc($product_upc);
    $re->set_price($price);

    $re->set_description($description);
    $re->set_qty_sold($units_sold);



    $re->set_depno($self->{current_depno});

    return $re;
}


# ReplenishmentParser
#
# Read the header, or starting line, of the replenishment
#
sub read_header {
    my $self = shift;
    
    my $sheet = $self->{sheet};

    my $header_row = $sheet->{MinRow};
    my @header;
    my $report_date;
    my $location;
    my $from_date;
    my $thru_date;
    my $total_report_sales;


    $sheet->{MaxCol} ||= $sheet->{MinCol};

    foreach my $col ($sheet->{MinCol}..$sheet->{MaxCol}) {
	my $val = $sheet->{Cells}[$header_row][$col]->{Val};
	push @header, $val;
    }


    if ($header[0] ne "REPLENISHMENT SUMMARY REPORT") {
	die "(0, 0) must read \"REPLENISHMENT SUMMARY REPORT\"";
	
    }
    
    

    if ($header[1] ne "REPORT DATE:") {
	die "(0, 1) must read \"REPORT DATE\"";
    }

    print "header[2] = $header[2]\n";

    $report_date = DateTime::Format::Excel->parse_datetime($header[2]);
    
#    if (!main::is_in_date_format($report_date)) {
#	print "report date = " . $report_date . "\n";
#	die "Report date must be in the right format";
 #   }


    if ($header[3] ne "LOCATION:") {
	die "(0, 3) must read \"LOCATION:\"";
    }



    $location = $header[4];
    if ($location ne "10199, 10199") {
	die "Location must read \"10199, 10199\"";

    }


    if ($header[5] ne "SALES DATE:") {
	die "(0, 5) must read \"FROM\"";

    }

    my $sales_date = DateTime::Format::Excel->parse_datetime($header[6]);

    $self->{beginning_date} = $sales_date;



    $sales_date->add({hours=>23, minutes=>59, seconds=>59});

    $self->{ending_date} = $sales_date;

    if ($header[7] ne "TOTAL REPORT SALES:") {

	die "(0, 6) must read \"TOTAL REPORT SALES:\"";
    }



    $total_report_sales = $header[7];
}


# ReplenishmentParser
sub read_subtotal_header {
    my $self = shift;
    my @sheader;
    my $sheet = $self->{sheet};
    my $dep_subtotal;

    foreach my $col ($sheet->{MinCol} .. $sheet->{MaxCol}) {
	my $val = $sheet->{Cells}[$self->{row}][$col]->{Val};

	push @sheader, $val;

    }


    if ($sheader[0] ne "Department Subtotal:") {

	die "Expected Department Subtotal:";
    }

    $dep_subtotal = $sheader[1];


    $self->{row}++;
    
}


# ReplenishmentParser
#
# Read one of the department headers
#
sub read_department_header {
    my $self = shift;
    my @dheader;
    my $sheet = $self->{sheet};
    my $depno;
    my $department_name;


#    $sheet->{MinCol} ||= $sheet->{MaxCol};

    foreach my  $col ($sheet->{MinCol}..$sheet->{MaxCol}) {
	my $val = $sheet->{Cells}[$self->{row}][$col]->{Val};

	push @dheader, $val;

    }


    if ($dheader[0] ne "Department") {
	die "Expected \"Department\ not $dheader[0] at " . $self->{row};

    }
    
    $depno = $dheader[1];

    if (!main::is_natural_number($depno)) {
	die "$depno not a natural number";

    }

    $self->{current_depno} = $depno;

    if ($dheader[2] ne "VENDOR #") {

	die "Expected \"VENDOR #\"";
    }
    
    if ($dheader[3] ne "VENDOR NAME") {

	die "Expected \"VENDOR NAME\"";
    }

    if ($dheader[4] ne "PRODUCT DESCRIPTION") {
	die "Expected \"PRODUCT DESCRIPTION\"";
    }

    if ($dheader[5] ne "UNITS") {

	die "Expected \"UNITS\"";
    }

    if ($dheader[6] ne "  PRODUCT #") {

	die "Expected \"  PRODUCT #\"";

    }


    if ($dheader[7] ne "  PRODUCT UPC") {

	die "Expected \"  PRODUCT UPC\"";
    }

    if ($dheader[8] ne "COLOR") {

	die "Expected \"COLOR\"";
    }


    if ($dheader[9] ne "SIZE") {

	die "Expected \"SIZE\"";
    }

    if ($dheader[10] ne "  PRICE") {
	die "Expected \"  PRICE\"";
    }

    
    $self->{row}++;
    

}


# ReplenishmentParser
sub reset {
    my $self = shift;

    my $sheet = $self->{sheet};

    $self->{row} = $sheet->{MinRow};

    $self->read_header();
    $self->{row} = $sheet->{MinRow} + 1;
    
    $self->read_department_header();
    
}


# ReplenishmentParser
#
# Open a replenishment file for reading
#
#
sub open {
    my $self = shift;
    my $fname = shift;


    eval {
	my $excel = Spreadsheet::XLSX->new($fname);

	$self->{excel} = $excel;


	my @sheets = @{$excel->{Worksheet}};

	
	$self->{sheet} = $sheets[0];

	# If MaxRow is false asign it to MinRow
	$self->{sheet}->{MaxRow} ||= $self->{sheet}->{MinRow};


	$self->read_header();
	$self->{row} = $self->{sheet}->{MinRow} + 1;

	$self->read_department_header();


    }; die $@ if $@;



}

# ReplenshmentParser
#
# Retrieve the beginning date of the replenishment
sub get_beginning_date {
    my $self = shift;

    if (!defined($self->{beginning_date})) {
	die "Replenishment file not opened!\n";
    }


    return $self->{beginning_date};

}

# ReplenishmentParser
#
# Retrieve the ending date of the replenishment

sub get_ending_date {
    my $self = shift;

    if (!defined($self->{ending_date})) {
	die "Replenishment file not opened!\n";
    }

    return $self->{ending_date};

}


