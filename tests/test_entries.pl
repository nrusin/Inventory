#!/usr/bin/perl

use warnings;
use strict;

use Core::Upc;
use Core::InvoiceInfo;
use Core::ReplenishmentEntry;
use Core::StockTakeInfo;
use Core::ProductInfo;

use Test::More tests => 18;


my $re = Core::ReplenishmentEntry->new();


$re->set_qty_sold(20);
$re->set_price(33.30);
$re->set_description("Cheez Its");


is($re->get_qty_sold(), 20, 'get_qty_sold() == 20');
is($re->get_price(), 33.30, 'get_price() == 33.30');
is($re->get_description(), "Cheez Its", 'get_description() eq Cheez Its');

my $invoice_info =  Core::InvoiceInfo->new();

$invoice_info->set_sku(3034);
is($invoice_info->get_sku(), 3034, 'get_sku() == 3034');

$invoice_info->set_qty_received(100);
is($invoice_info->get_qty_received(), 100, 'get_qty_received()==100');

my $sti = Core::StockTakeInfo->new();


$sti->set_upc(Core::Upc->new("041364086767"));
is($sti->get_upc()->str(), "041364086767", 'upc == 04136408676');


$sti->set_qty_counted(120);
is($sti->get_qty_counted(), 120, 'get_qty_counted==120');

$sti->set_description('Chex Mix');
is($sti->get_description(), 'Chex Mix', 'get_description() ne Chex Mix');



my $product_info = Core::ProductInfo->new();

$product_info->set_price(200.00);
is($product_info->get_price(), 200.00, 'product_info->get_price()==200.00');


$product_info->set_item_no(2001);
is($product_info->get_item_no(), 2001, 'get_item_no()==2001');

$product_info->set_description('Snickers');
is($product_info->get_description(), 'Snickers',
   'get_description()==Snickers');


$product_info->set_unit(12);
is($product_info->get_unit(), 12, 'product_info->get_unit');


$product_info->set_case_pack(144);
is($product_info->get_case_pack(), 144, 'get_case_pack() == 144');

$product_info->set_eoq(288);
is($product_info->get_eoq(), 288, 'get_eoq() == 288');

$product_info->set_cost(10.00);
is($product_info->get_cost(), 10.00, 'get_cost() == 10');

$product_info->set_unit_cost(3.00);
is($product_info->get_unit_cost(), 3.00, 'get_unit_cost() == 3.00');


$product_info->set_retail(20.00);
is($product_info->get_retail(), 20.00, 'get_retail() == 20.00');
           

$product_info->set_upc(Core::Upc->new('041364820156'));
is($product_info->get_upc()->str(), '041364820156', 
   'upc equals 041364820156');





