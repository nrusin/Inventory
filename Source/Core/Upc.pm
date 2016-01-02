#!/usr/bin/perl

use strict;
use warnings;
use Carp;

sub is_number {
    my $num = shift;


    return $num =~ /^\d+$/;
}

sub do_calculate_check_digit {
    my $upc = shift;
    my $check;

    my $a = substr($upc, 0, 1);
    my $b = substr($upc, 1, 1);
    my $c = substr($upc, 2, 1);
    my $d = substr($upc, 3, 1);
    my $e = substr($upc, 4, 1);
    my $f = substr($upc, 5, 1);
    my $g = substr($upc, 6, 1);
    my $h = substr($upc, 7, 1);
    my $i = substr($upc, 8, 1);
    my $j = substr($upc, 9, 1);
    my $k = substr($upc, 10, 1);

    my $odd_sum;


    $odd_sum = $a +$c + $e + $g + $i + $k;
    
    $odd_sum = $odd_sum * 3;

    
    my $even_sum;
    
    $even_sum = $b + $d + $f + $h + $j;
	
	
    $check = $odd_sum + $even_sum;
    
    
    $check = 10 - $check % 10;


    return $check;
}



# 0ab00000cdeX 	abcde0X 	Manufacturer code must have 2 leading digits with 3 trailing zeros and the item number is limited to 3 digits (000 to 999).
# 0ab10000cdeX 	abcde1X 	Manufacturer code must have 3 leading digits ending with "1" and 2 trailing zeros. The item number is limited to 3 digits.
# 0ab20000cdeX 	abcde2X 	Manufacturer code must have 3 leading digits ending with "2" and 2 trailing zeros. The item number is limited to 3 digits.
# 0abc00000deX 	abcde3X 	Manufacturer code must have 3 leading digits and 2 trailing zeros. The item number is limited to 2 digits (00 to 99).
# 0abcd00000eX 	abcde4X 	Manufacturer code must have 4 leading digits with 1 trailing zero and the item number is limited to 1 digit (0 to9).
#
#--------------------------------------------------------------------
# 0abcde00005X  abcde5X                                             |
# 0abcde00006X  abcde6X                                             |
# 0abcde00007X  abcde7X                                             |
# 0abcde00008X  abcde8X                                             |
# 0abcde00009X 	abcde9X 	Manufacturer code has all 5 digits. |
#-------------------------------------------------------------------| 
#





package Core::Upc;

sub new {
    my $class = shift;
    my $self = { upc => shift};


    my $len = length($self->{upc});



#    if (!::is_number($self->{upc})) {
#	die "Upc::new: upc must be a number.";
 #   }


#    if (get_check_digit() ne calculate_check_digit()) {
#	    die "Upc::new: upc does not have the right check digit.";

 #   }

    if (!defined($len)) {
	Carp::confess("len not defined!\n");

    }

    
    if ($len == 11) {
	my $check = ::do_calculate_check_digit($self->{upc});
	
	$self->{upc} = $self->{upc} .  $check;
    }

    bless $self, $class;




}

sub is_upc_a {
    my $self = shift;
    my $upc = $self->{upc};


    if (!defined($upc)) {
	Carp::confess("upc not defined");

    }


    my $len = length($upc);

    if ($len != 12) {
	return 0;
    }


    my $check_digit = $self->get_check_digit();

    return 1;
}


sub is_upc_e {
    my $self = shift;
    my $upc = $self->{upc};


    if (!defined($upc)) {
	Carp::confess("upc not defined");

    }


    my $len = length($upc);

    return $len == 7;
     
}


sub convert_to_upc_a {
    my $self = shift;


    if ($self->is_upc_a()) {
	return;
    }


    my $upc = $self->{upc};
    my $len = length($upc);

    if ($len == 7) {
	my $a = substr($upc, 0, 1);
        my $b = substr($upc, 1, 1);
	my $c = substr($upc, 2, 1);
	my $d = substr($upc, 3, 1);
	my $e = substr($upc, 4, 1);
	my $f = substr($upc, 5, 1);
	my $x = substr($upc, 6, 1);


      
	if ($f eq '0') {
		$upc = "0" . $a . $b . "00000" . $c . $d . $e . $x;

	} elsif ($f eq '1') {
		$upc = "0" . $a . $b . "10000" . $c . $d . $e . $x;
	} elsif ($f eq '2') {
		$upc = "0" . $a . $b . "20000" . $c . $d . $e . $x;
	} elsif ($f eq '3') {
		$upc = "0" . $a . $b . $c . "00000" . $d . $e . $x;
	} elsif ($f eq '4') {
		$upc = "0" . $a . $b . $c . $d . "00000" . $e . $x;
	} elsif ($f eq '5' || $f eq '6' || $f eq '7' || $f eq '8' || $f eq'9') {
		$upc = '0' . $a . $b . $c . $d . $e . "0000" . $f . $x;

	}
	
	$self->{upc} = $upc;

    }

    

}

#'01234500005'
sub convert_to_upc_e {
    my $self = shift;
    my $upc = $self->{upc};
    my $upce;

    if ($self->is_upc_e()) {
	return;
    }

    my $a = substr($upc, 0, 1);
    my $b = substr($upc, 1, 1);
    my $c = substr($upc, 2, 1);
    my $d = substr($upc, 3, 1);
    my $e = substr($upc, 4, 1);
    my $f = substr($upc, 5, 1);
    my $g = substr($upc, 6, 1);
    my $h = substr($upc, 7, 1);
    my $i = substr($upc, 8, 1);
    my $j = substr($upc, 9, 1);
    my $k = substr($upc, 10, 1);
    my $l = substr($upc, 11, 1);

	


    if ($a == '0' && $d == '0' && $e == '0' && $f == '0' && $g == '0' && $h == '0') {
	#       0bc00000ijkl

	$upce = $b . $c . $i . $j . $k . '0' . $l;

    } elsif ($a == '0' && $d == '1' && $e == '0' && $f == '0' && $g == '0' && $h == '0') {
	#       0bc10000ijkl


	$upce = $b . $c . $i . $j . $k . '1' . $l;

    } elsif ($a == '0' && $d == '2' && $e == '0' && $f == '0' && $g == '0' && $h == '0') {
	#       0bc20000ijkl

	$upce = $b . $c . $i . $j . $k . '2' . $l;

    } elsif ($a == '0' && $e == '0' && $f == '0' && $g == '0' && $h == '0') {
	#       0bcd00000jkl

	$upce = $b . $c . $d . $j . $k . '3' . $l;

    } elsif ($a == '0' && $f == '0' && $g == '0' && $h == '0' && $i == '0' && $j == '0') {
	#        0bcde00000kl

	$upce = $b . $c . $d . $e . $k . '4' . $l;
    } elsif ($a == '0' && $g == '0' && $h=='0' && $i=='0' && $j == '0' 
            && ($k == '5' || $k == '6' || $k == '7' || $k == '8' || $k == '9')) {
	#--------------------------------------------------------------------
        # 0abcde00005X  abcde5X                                             |
        # 0abcde00006X  abcde6X                                             |
        # 0abcde00007X  abcde7X                                             |
        # 0abcde00008X  abcde8X                                             |
        # 0abcde00009X 	abcde9X 
	$upce = $b . $c . $d . $e . $f . $k . $l;

    }

    if (defined($upce))  {
	$self->{upc} = $upce;
    }

}


sub str {
    my $self = shift;


    return $self->{upc};
}

sub str_no_check {
    my $self = shift;


    if ($self->is_upc_a()) {
	return substr($self->{upc}, 0, 11);
    }


    return substr($self->{upc}, 0, 6);

}



sub last_6 {
    my $self = shift;
    my $len = length($self->{upc});


    return substr($self->{upc}, $len-6, 6);
    
}



# Upc::calculate_check_digit
#
# Calculate the UPC's checkdigit
#
#
sub calculate_check_digit {
    my $self = shift;
    my $check;
    my $convert_back = 0;


    if (is_upc_e()) {

	convert_to_upc_a();

	$convert_back = 1;
    }

    $check = do_calculate_check_digit(shift->{upc});

    if ($convert_back) {
	convert_to_upc_e();
    }


 
    return $check;
}


# Upc::get_check_digit
#
# Retrievest the check digit from the last digit of the UPC.
#
#
sub get_check_digit {
    my $self = shift;



    return substr($self->{upc}, 12, 1);

}

1
