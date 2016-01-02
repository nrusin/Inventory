#!/usr/bin/perl
use strict;
use warnings;

use DBI;
use DateTime;

require 'parser.pl';
require 'db.pl';
require 'product_update.pl';


sub replenishment_insert {
    my $replenishments = shift;
    my $rid = shift;
    my $upc_str = shift;
    my $price = shift;
    my $description = shift;
    my $qty_sold = shift;


    my $re = ReplenishmentEntry->new();
    $re->set_upc(Upc->new($upc_str));
    $re->set_price($price);
    $re->set_description($description);
    $re->set_qty_sold($qty_sold);

    $replenishments->insert_into($rid, $re);
}

sub insert_into_invoice {
    my $dbh = shift;
    my $invoices = shift;
    my $invoice_id = shift;
    my $upc_str = shift;
    my $qty_received = shift;


    my $products = Products->new($dbh);

    my $product = $products->lookup_by_upc(Upc->new($upc_str));


    my $invoice_info = InvoiceInfo->new();
    $invoice_info->set_sku($product->get_sku());
    $invoice_info->set_qty_received($qty_received);
    

    $invoices->insert_into($invoice_id, $invoice_info);
    


}



my $dbh = DBI->connect("dbi:SQLite:dbname=p.db", "", "",
		       {RaiseError => 1});

my $sb = SchemaBuilder->new($dbh);
$sb->unbuild();
$sb->build();



my $updater = ProductInfoUpdater->new($dbh);

print "starting update..!\n";



$dbh->{AutoCommit} = 0;

$updater->update_product_info("PRODUCT_LIST.xlsx");

$dbh->commit();
$dbh->{AutoCommit} = 1;

my $replenishments = Replenishments->new($dbh);

my $beginning_date = DateTime->new({month=>11, day=>12, year=>2015});
my $ending_date = DateTime->new({month=>11, day=>13, year=>2015});


my $rid = $replenishments->begin_replenishment($beginning_date, $ending_date);
replenishment_insert($replenishments, $rid, "014054030715", 10.00, "ODWALLA MANGO PROTEIN 15.2Z  !", 1);
replenishment_insert($replenishments, $rid, "014054031088", 10.00, "ODWALLA ORANGE JUICE 15.2Z  !", 2);
replenishment_insert($replenishments, $rid, "014054030883", 10.00, "ODWALLA STRAW BANANA 15.2Z  !", 3);
replenishment_insert($replenishments, $rid, "014054061054", 10.00, "ODWALLA STRAWBERRY C 15.2Z  !", 4);
replenishment_insert($replenishments, $rid, "014054064055", 10.00, "ODWALLA SUPERFOOD 15.2Z   !", 5);
replenishment_insert($replenishments, $rid, "025000000300", 10.00, "ODWALLA CRANBERRY 11.5Z   !", 6);
replenishment_insert($replenishments, $rid, "025000000218", 10.00, "SIMPLY LEMONADE 11.5Z    !", 7);
replenishment_insert($replenishments, $rid, "025000000249", 10.00, "SIMPLY ORANGE 11.5Z   !", 8);
replenishment_insert($replenishments, $rid, "025000000324", 10.00, "SIMPLY ORANGE W/ MANGO 11.5Z!", 9);
replenishment_insert($replenishments, $rid, "025000000188", 10.00, "SIMPLY RASPBERRY LEMNADE 11.5Z", 10);
replenishment_insert($replenishments, $rid, "012300000079", 10.00, "CAMEL BLUE BX", 11);
replenishment_insert($replenishments, $rid, "012300197410", 10.00, "CAMEL CRUSH BX", 12);
replenishment_insert($replenishments, $rid, "028200003577", 10.00, "MARL BX", 13);
replenishment_insert($replenishments, $rid, "028200003638", 10.00, "MARL BX 100", 14);
replenishment_insert($replenishments, $rid, "028200003843", 10.00, "MARL GOLD BX", 15);
replenishment_insert($replenishments, $rid, "028200004659", 10.00, "MARL GOLD BX 100", 16);
replenishment_insert($replenishments, $rid, "028200004772", 10.00, "MARL SILVER BX 100", 17);
replenishment_insert($replenishments, $rid, "075218001965", 10.00, "MATCHES*BOX* 50's", 18);
replenishment_insert($replenishments, $rid, "026100005752", 10.00, "NEWPORT BX", 19);
replenishment_insert($replenishments, $rid, "026100005738", 10.00, "NEWPORT BX 100", 20);
replenishment_insert($replenishments, $rid, "026100005769", 10.00, "NEWPORT MEN GOLD BX", 21);
replenishment_insert($replenishments, $rid, "026100005721", 10.00, "NEWPORT MEN GOLD BX 100", 22);


my $products = Products->new($dbh);

my $product;

$product = $products->lookup_by_upc(Upc->new("014054030715"));
if ($product->get_qty_on_hand() != -1) {
    die "product->get_qty_on_hand() != -1!\n";
}


$product = $products->lookup_by_upc(Upc->new("014054031088"));
if ($product->get_qty_on_hand() != -2) {
    die "product->get_qty_on_hand() != -2!\n";
}


$product = $products->lookup_by_upc(Upc->new("014054030883"));
if ($product->get_qty_on_hand() != -3) {
    die "product->get_qty_on_hand() != -3!\n";
}



$product  = $products->lookup_by_upc(Upc->new("026100005721"));

if ($product->get_qty_on_hand() != -22) {
    die $product->get_qty_on_hand() . " != -22!\n";

}


my $invoices = Invoices->new($dbh);
my $invoice_id = $invoices->begin_invoice(DateTime->new({month=>11, day=>12, year=>2015}), 20011292015);


insert_into_invoice($dbh, $invoices, $invoice_id,  "026100005721", 26);


if ($product->get_qty_on_hand() != 4) {
    die "product->get_qty_on_hand() != 4!\n";
}


$invoice_id = $invoices->begin_invoice(DateTime->new({month=>12, day=>1, year=>2015}), 2001212015);

insert_into_invoice($dbh, $invoices, $invoice_id, "026100005721", 5);


if ($product->get_qty_on_hand() != 9) {
    die "product->get_qty_on_hand() != 9!\n";
}

my $stock_takes = StockTakes->new($dbh);

my $stock_take_info = StockTakeInfo->new();
$stock_take_info->set_upc(Upc->new("026100005721"));
$stock_take_info->set_qty_counted(100);
$stock_take_info->set_description("");

my $stock_id = $stock_takes->begin_stock_take(DateTime->new({month=>12, day=>2, year=>2015}));

$stock_takes->insert_into($stock_id, $stock_take_info);

if ($product->get_qty_on_hand() != 100) {
    die "product->get_qty_on_hand() != 100";

}


my $stock_id = $stock_takes->begin_stock_take(DateTime->new({month=>12, day=>2, year=>2011}));

$stock_take_info->set_upc(Upc->new("028200003843"));
$stock_take_info->set_qty_counted(100);
$stock_take_info->set_description("");
$stock_takes->insert_into($stock_id, $stock_take_info);


$product = $products->lookup_by_upc(Upc->new("028200003843"));
if ($product->get_qty_on_hand() != 85) {
    die "product->get_qty_on_hand() != 85";
}

    
print "Finished tests" . "\n";



1




