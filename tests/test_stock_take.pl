#!/usr/bin/perl


use warnings;
use strict;

use Excel::Writer::XLSX;
use Test::More tests => 6;
use DateTime;
use Parser::StockTakeParser;
use Core::StockTakeInfo;


sub build_s1 {
    my $workbook = Excel::Writer::XLSX->new('test_stock_take1.xlsx');
    

    my $worksheet = $workbook->add_worksheet();


    $worksheet->write('A1', "Date Time:");
    $worksheet->write('B1', DateTime->new({month=>11, day=>5, year=>2015}));

    $worksheet->write('A2', "Description");
    $worksheet->write('B2', "UPC");
    $worksheet->write('C2', "Quantity");
    $workbook->close();
}


sub build_s2 {
    my $workbook = Excel::Writer::XLSX->new('test_stock_take2.xlsx');

    my $worksheet = $workbook->add_worksheet();


    $worksheet->write('A1', "Date Time:");
    $worksheet->write('B1', DateTime->new({month=>4, day=>7, year=>2015}));
    
    $worksheet->write('A2', "Description");
    $worksheet->write('B2', "UPC");
    $worksheet->write('C2', "Quantity");

    $worksheet->write('A3', "Cheez Its");
    $worksheet->write_string('B3', "087076241711");
    $worksheet->write('C3', 101);

    $workbook->close();
}

sub build_s3 {
    my $workbook = Excel::Writer::XLSX->new('test_stock_take3.xlsx');
    my $worksheet = $workbook->add_worksheet();

    $workbook->close();
}




build_s1();
build_s2();
build_s3();

my $stp = Parser::StockTakeParser->new();

$stp->open('test_stock_take1.xlsx');

ok($stp->eof(), "stp is at eof");


is($stp->get_datetime(), DateTime->new({month=>11, day=>5, year=>2015}));


my $stp2 = Parser::StockTakeParser->new();

$stp2->open('test_stock_take2.xlsx');

is($stp2->get_datetime(), DateTime->new({month=>4, day=>7, year=>2015}));

while(!$stp2->eof()) {
    my $stock_take_info = $stp2->get_stock_take_info();
    
    is($stock_take_info->get_upc()->str(), "087076241711");
    is($stock_take_info->get_qty_counted(), 101);
    is($stock_take_info->get_description(), "Cheez Its");

    $stp2->next();
}


    # description, upc, qty
