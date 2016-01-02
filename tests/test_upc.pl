#!/usr/bin/perl

use warnings;
use strict;

use Core::Upc;
use Test::More tests => 34;



sub test_is_floating_pt {
    ok(is_floating_pt("5.5"), 'is 5.5 floating point?');
    ok(is_floating_pt(".5"), 'is .5 floating point?');
    ok(is_floating_pt("0.55"), 'is .55 floating point?');
    ok(is_floating_pt("3.14159"), 'is 3.14159 floating point?');
    ok(is_floating_pt("5"), 'is 5 floating point?');
    ok(is_floating_pt("3333"), 'is 3333 floating point?');
}


sub test_is_number {
    ok(is_number("5"), 'is 5 a number?');
    ok(is_number("0"), 'is 0 a number?');
    ok(is_number("25"), 'is 25 a number?');
    ok(is_number("3141159268"), 'is 3141159268 a numbers?');
    ok(is_number("4.4"), 'is 4.4 a number?');
    ok(!is_number("abc"), 'is abc a number?');
}


sub test_upc {
    my $upc1 = Core::Upc->new("1236432");


    ok(!$upc1->is_upc_a(), 'is 1236432 upc a');
    ok($upc1->is_upc_e(), 'is 1236432 upc e');
    is($upc1->str(), "1236432", 'check str()');
    is($upc1->last_6(), "236432", 'check last_6()');

    $upc1->convert_to_upc_a();

    is($upc1->str_no_check(), "01230000064", 'check if convert_to_upc_a works'); 



    my $upc2 = Core::Upc->new("1111111");

    ok(!$upc2->is_upc_a(), 'check that 1111111 is not upc a');
    ok($upc2->is_upc_e(), 'check that 1111111 is upc e');

    $upc2->convert_to_upc_a();

    is($upc2->str_no_check(), "01110000111", 'check that convert_to_upc_a works');


    my @upcas = ('01234500005',
		'01234500006',
		'01234500007',
		'01234500008',
		'01234500009',
                '01200000345',
                '01210000345',
                '01220000345',
                '01230000045',
                '01234000005'
	);


    my @upces = ('123455',
		 '123456',
		 '123457',
		 '123458',
		 '123459',
                 '123450',
                 '123451',
                 '123452',
                 '123453',
                 '123454'
	);


    my $i = 0;
    my $u;
    foreach $u(@upcas) {
	my $v = Core::Upc->new($u);

	$v->convert_to_upc_e();

	is($v->str_no_check(), $upces[$i], "str_no_check $upces[$i]");

    
	my $before = $v->str_no_check();

	$v->convert_to_upc_a();

	is($v->str_no_check(), $u, "str_no_check $u");

	$i++;
    }

		 
# --------------------------------------------------------------------
# 0abcde00005X  abcde5X                                             |
# 0abcde00006X  abcde6X                         \                    |
# 0abcde00007X  abcde7X                                             |
# 0abcde00008X  abcde8X                                             |
# 0abcde00009X 	abcde9X 


    
}




test_is_floating_pt();

test_upc();

