#!/usr/bin/perl


use warnings;
use strict;
use Carp;


sub is_floating_pt {
    my $num = shift;


    return ($num =~ /^\d+$/) || ($num =~ /^\d+\.\d+$/)
	|| ($num =~ /^\.\d+$/)
}




package Core::ProductInfo;


sub new {
    my $class = shift;

    my $self = {
	
	item_no        => undef,
	description    => undef,
	unit           => undef,
	case_pack      => undef,
	eoq            => undef,
	cost           => undef,
	unit_cost      => undef,
	retail         => undef,
	upc            => undef,
	department_no  => undef,
	par            => undef,
	location       => undef,
	units_in_bx    => undef,
        category_id    => undef,
	price          => undef

    };

    if (@_ != 0) {
	$self->{item_no} = shift;
	$self->{description}  = shift;
	$self->{unit} = shift;
	$self->{case_pack} = shift;
	$self->{eoq} = shift;
	$self->{cost} = shift;
	$self->{unit_cost} = shift;
	$self->{retail} = shift;
	$self->{upc} = shift;
	$self->{department_no} = shift;
	$self->{par} = shift;
	$self->{location} = shift;
	$self->{units_in_bx} = shift;
        $self->{category_id} = shift;
	$self->{price} = shift;

	if ($self->{unit} =~ m/^\d+$/) {

	    die "ProductInfo: unit must be an integer.";
	}
    }



    bless $self, $class;



    return $self;
}


sub set_price {
    my $self = shift;
    my $price = shift;

    $self->{price} = $price;
}

sub get_price {
    my $self = shift;

    return $self->{price};
}



# ProductInfo::get_item_no
#
# Returns the item_no which is used by the distributor to
# uniquely identify the product.
#
#
sub get_item_no {
    my $self = shift;


    return $self->{item_no};

}

# ProductInfo::set_item_no
#
# item_ no -- String used by the distributor to uniquely
#             identifies the product.
#
sub set_item_no {
    my $self = shift;
    my $item_no = shift;


    $self->{item_no} = $item_no;
}


# ProductInfo::get_description
#
# Returns the product's description
#
sub get_description {
    my $self = shift;
    
    return $self->{description};
}

# ProductInfo::set_description
#
# description -- product's description
#
# Sets the product to the <description>
#
sub set_description {
    my $self = shift;
    my $description = shift;


    $self->{description} = $description;
}

# ProductInfo::get_unit
#
# Returns the product's unit. The product's unit is used as an
# ordering multiple.
#
sub get_unit {
    my $self = shift;
   
    return $self->{unit};
}


# ProductInfo::set_unit
#
# unit -- product's unit which is used as an ordering multiple.
#
# Sets the product's unit to <unit>
sub set_unit {
    my $self = shift;
    my $unit = shift;

    if ($unit =~ /^\d+$/) {
	$self->{unit} = $unit;
    } else {
	Carp::confess "set_unit: unit must be an integer."
    }


}

# ProductInfo::get_case_pack
#
# Returns the product's case pack, which is the number
# of items in a case.
#
sub get_case_pack {
    my $self = shift;


    return $self->{case_pack};

}


# ProductInfo::set_case_pack
#
# Sets the product's case pack, which is the number
# of items in a case.
#
sub set_case_pack {
    my $self = shift;
    my $case_pack = shift;

    if (!($case_pack =~ /^\d+$/)) {
	die "ProductInfo::set_case_pack: case pack must be a number.";

    }

    $self->{case_pack} = $case_pack;
}

# ProductInfo::get_eoq
#
# Returns the product's economic ordering quantity.
#
sub get_eoq {
    my $self = shift;
   
    return $self->{eoq};
}

# ProductInfo::set_eoq
# 
# eoq -- economic ordering quantity
#
# Sets the product's economic ordering quantity.
sub set_eoq {
    my $self = shift;
    my $eoq = shift;


    $self->{eoq} = $eoq;
}


# ProductInfo::get_cost
#
# Returns the product's cost
#
sub get_cost {
    my $self = shift;
    
    return $self->{cost};
}


# ProductInfo::set_cost
#
# Sets the product's cost.
#
sub set_cost {
    my $self = shift;
    my $cost = shift;

    if (!::is_floating_pt($cost)) {
	die "ProductInfo::set_cost: cost must be a floating point";
    }

    $self->{cost} = $cost;
}

# ProductInfo::get_unit_cost
#
# Gets the product's cost per unit.
#
sub get_unit_cost {
    my $self = shift;
    

    return $self->{unit_cost};
}

# ProductInfo::set_unit_cost
#
# Sets the product's cost per unit.

sub set_unit_cost {
    my $self = shift;
    my $unit_cost = shift;


    if (!::is_floating_pt($unit_cost)) {
	die "ProductInfo::set_unit_cost unit_cost must be a floating point.";
    }

    $self->{unit_cost} = $unit_cost;
}

# ProductInfo::get_retail
#
#

sub get_retail {
    my $self = shift;

    return $self->{retail};

}

# ProductInfo::set_retail
#
#
sub set_retail {
    my $self = shift;
    my $retail = shift;

    $self->{retail} = $retail;
}


# ProductInfo::get_upc
#
#
#
#
sub get_upc {
    my $self = shift;

    return $self->{upc};

}


# ProductInfo::set_upc
#
# upc: Core::Upc reference

sub set_upc {
    my $self = shift;
    my $upc = shift;


    $self->{upc} = $upc;
}


sub get_department_no {
    my $self = shift;
    

    return $self->{department_no};

}

sub set_department_no {
    my $self = shift;
    my $department_no = shift;


    $self->{department_no} = $department_no;
}


sub get_par {
    my $self = shift;
    
    return $self->{par};
}


sub set_par {
    my $self = shift;
    my $par = shift;


    $self->{par} = $par;
}

sub get_location {
    my $self = shift;
    

    return $self->{location};
}

sub set_location {
    my $self = shift;
    my $location = shift;


    $self->{location} = $location;
}

sub get_units_in_bx {
    my $self = shift;
    

    return $self->{units_in_bx};
}

sub set_units_in_bx {
    my $self = shift;
    my $units_in_bx = shift;


    $self->{units_in_bx} = $units_in_bx;
}


sub get_category_id {
    my $self = shift;

    return $self->{category_id};
}


sub set_category_id {
    my $self = shift;
    my $category_id = shift;


    $self->{category_id} = $category_id;
}



1
