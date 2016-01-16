#!/usr/bin/perl


use warnings;
use strict;

use DateTime;
use DBI;
use Core::Upc;
use Core::ReplenishmentEntry;
use DB::SchemaBuilder;
use DB::Product;
use DB::Replenishments;



my $dbh = DBI->connect("dbi:SQLite:dbname=test_database.db","","",
                 { RaiseError => 1});

$dbh->{RaiseError}  = 1;


eval {
    print "dbh = $dbh\n";

    if (!defined($dbh)) {
	die "dbh not defined\n";
    }


    my $sb = new DB::SchemaBuilder($dbh);


    $sb->unbuild();
    $sb->build();



    my $sku = DB::Product->make_product($dbh);


    my $product = DB::Product->new($dbh, $sku);



    my $description = "M&M Peanut KS";
    my $unit = 101;
    my $dep_no = 19;

    $product->set_description($description);

    if ($description ne $product->get_description) {
	die "test_db failed at set_description";

    }

    $product->set_unit($unit);

    if ($unit != $product->get_unit()) {

	die "test_db failed at set_unit";
    }

    $product->set_unit($unit + 10);

    if ($unit + 10 != $product->get_unit()) {
	die "test db failed at set_unit";
    }

    $product->set_unit($unit);

    if ($unit != $product->get_unit()) {
	die "test_db failed at set_unit!\n";
    }


    $product->set_department_no($dep_no);

    if ($dep_no != $product->get_department_no()) {
	die "test_db failed at set_department_no!\n";

    }


    my $case_pack = 200;

    $product->set_case_pack($case_pack);

    if ($case_pack != $product->get_case_pack()) {
	die "test_db failed at set_case_pack!\n";
    }

    my $cost = 100.20;

    $product->set_cost($cost);
    if ($cost != $product->get_cost()) {
	print "cost = " . $product->get_cost() . "\n";

	die "test_db failed at set_cost!\n";
    }


    my $unit_cost = 4.80;

    $product->set_unit_cost($unit_cost);
    if ($unit_cost != $product->get_unit_cost()) {
	die "test_db failed at set_unit_cost!\n";
    }


    my $par = 30;

    $product->set_par($par);
    if ($par != $product->get_par()) {
	die "test_db failed at set_par!\n";
    }

    my $category_id = 101;

    $product->set_category_id($category_id);

    if ($category_id != $product->get_category_id()) {
	die "test_db failed at set_category_id!\n";
    }

    my $upc_str = "040000000327";
    my $upc = Core::Upc->new($upc_str);

    $product->set_upc($upc);

    if ($product->get_upc()->str() ne $upc_str) {

	print "upc_str = " . $upc_str . "\n";
	print "get_upc() = " . $product->get_upc()->str() . "\n";
	die "test_db failed at get_upc()->str() ne upc_str!\n";
    }



    my $loc = 400;

    $product->set_loc($loc);

    if ($loc != $product->get_loc()) {
	die "test_db failed at set_loc!\n";
    }



    my $units_in_bx = 12;

    $product->set_units_in_bx($units_in_bx);

    if ($units_in_bx != $product->get_units_in_bx()) {
	die "test_db failed at set_units_in_bx!\n";
    }


    my $price = 25.00;

    $product->set_price($price);

    if ($price != $product->get_price()) {
	die "test_db failed at set_price!\n";

    }


    my $eoq = 12;

    $product->set_eoq($eoq);

    if ($eoq != $product->get_eoq()) {
	die "test_db failed at set_eoq!\n";
    }

    my $item_no = 288;
    $product->set_item_no($item_no);
    if ($item_no != $product->get_item_no()) {
	die "test_db failed at set_item_no!\n";
    }




    my $product_info = $product->get_product_info();


    if ($product_info->get_item_no() != $item_no) {

	die "test_db failed at get_item_no() != item_no!\n";
    }


    if ($product_info->get_description() ne $description) {
	die "test_db failed at get_description() ne description!\n";
    }


    if ($product_info->get_unit() != $unit) {
	print "get_unit = " . $product_info->get_unit() . "\n";
	print "unit = " . $unit . "\n";

	die "test_db failed at get_unit != unit!\n";
    }

    if ($product_info->get_case_pack() != $case_pack) {
	die "test_db failed at get_case_pack() != case_pack!\n";

    }

    if ($product_info->get_eoq() != $eoq) {
	die "test_db failed at get_eoq() != eoq!\n";
    }

    if ($product_info->get_cost() != $cost) {
	die "test_db failed at get_cost() != cost\n";
    }


    if ($product_info->get_unit_cost() != $unit_cost) {
	die "test_db failed at get_unit_cost() != unit_cost\n";
    }

#$product_info->get_retail() != $


    if ($product_info->get_upc()->str() ne $upc->str()) {
	die "test_db failed at get_upc ne upc!\n";
    }


    if ($product_info->get_department_no() != $dep_no) {
	die "test_db failed at get_department_no() != dep_no!\n";
    }

    if ($product_info->get_par() != $par) {
	die "test_db failed at get_par() != par!\n";

    }

    if ($product_info->get_location() != $loc) {
	die "test_db failed at get_location() != loc!\n";

    }

    if ($product_info->get_units_in_bx() != $units_in_bx) {
	die "test_db failed at get_units_in_bx() != units_in_bx!\n";
    }



    $product_info = $product->get_product_info();


    if ($product_info->get_item_no() != $item_no) {

	die "test_db failed at get_item_no() != item_no!\n";
    }


    if ($product_info->get_description() ne $description) {
	die "test_db failed at get_description() ne description!\n";
    }


    if ($product_info->get_unit() != $unit) {
	print "get_unit = " . $product_info->get_unit() . "\n";
	print "unit = " . $unit . "\n";

	die "test_db failed at get_unit != unit!\n";
    }

    if ($product_info->get_case_pack() != $case_pack) {
	die "test_db failed at get_case_pack() != case_pack!\n";

    }

    if ($product_info->get_eoq() != $eoq) {
	die "test_db failed at get_eoq() != eoq!\n";
    }

    if ($product_info->get_cost() != $cost) {
	die "test_db failed at get_cost() != cost\n";
    }


    if ($product_info->get_unit_cost() != $unit_cost) {
	die "test_db failed at get_unit_cost() != unit_cost\n";
    }

#$product_info->get_retail() != $


    if ($product_info->get_upc()->str() ne $upc->str()) {
	die "test_db failed at get_upc ne upc!\n";
    }


    if ($product_info->get_department_no() != $dep_no) {
	die "test_db failed at get_department_no() != dep_no!\n";
    }

    if ($product_info->get_par() != $par) {
	die "test_db failed at get_par() != par!\n";

    }

    if ($product_info->get_location() != $loc) {
	die "test_db failed at get_location() != loc!\n";

    }

    if ($product_info->get_units_in_bx() != $units_in_bx) {
	die "test_db failed at get_units_in_bx() != units_in_bx!\n";
    }

    $product_info->set_item_no(213);
    $product_info->set_description("M&M Chocolate");
    $product_info->set_unit(24);
    $product_info->set_case_pack(120);
    $product_info->set_eoq(24);
    $product_info->set_cost(10.00);
    $product_info->set_unit_cost(14.05);

    $product_info->set_upc(Core::Upc->new("123456789999"));

    $product_info->set_department_no(14);
    $product_info->set_par(30);
    $product_info->set_location(60);

    $product_info->set_units_in_bx(120);



    $product->set_product_info($product_info);

if ($product_info->get_item_no() != 213) {
    die "test_db failed at get_item_no() != 213";
}

if ($product_info->get_description() ne "M&M Chocolate") {
    die "test_db failed at get_description() ne M&M Chocolate\n";
}


if ($product_info->get_unit() != 24) {
    die "test_db failed at get_unit() != 24";
}

if ($product_info->get_case_pack() != 120) {
    die "test_db failed at get_case_pack() != 120";
}

if ($product_info->get_eoq() != 24) {
    die "test_db failed at get_eoq() != 24";
}

if ($product_info->get_cost() != 10.00) {
    die "test_db failed at get_cost() != 10.00!\n";
}

if ($product_info->get_unit_cost() != 14.05) {
    die "test_db failed at get_unit_cost() != 14.05\n";
}


if ($product_info->get_upc()->str() ne "123456789999") {
    die "test_db failed at get_upc()->str ne 123456789999";
}

if ($product_info->get_department_no() != 14) {
    die "get_department() != 14\n";
}

if ($product_info->get_par() != 30) {
    die "get_par != 30!\n";

}

if ($product_info->get_location() != 60) {
    die "get_location() != 60!\n";
}

if ($product_info->get_units_in_bx() != 120) {
    die "get_units_in_bx() != 120!\n";
}






#Item Description	Unit	Case Pack	Cost	Unit Cost	Unit UPC
my @data = (52050, "ODWALLA MANGO PROTEIN 15.2Z  !", 6, 4, 11.92, 1.9867, "014054030715",
            52051, "ODWALLA ORANGE JUICE 15.2Z   !", 6,	4, 11.92, 1.9867, "014054031088",
            52053, "ODWALLA STRAW BANANA 15.2Z   !", 6,	4, 11.92, 1.9867, "014054030883",
            52054, "ODWALLA STRAWBERRY C 15.2Z   !", 6,	4, 11.92, 1.9867, "014054061054",
            52052, "ODWALLA SUPERFOOD 15.2Z     !",  6,	4, 11.92, 1.9867, "014054064055",
            52099, "SIMPLY CRANBERRY 11.5Z       !", 12,1, 14.65, 1.2208, "025000000300",
            52012, "SIMPLY LEMONADE 11.5Z        !", 12,1, 14.65, 1.2208, "025000000218",
            52101, "SIMPLY ORANGE 11.5Z          !", 12,1, 14.65, 1.2208, "025000000249",
            52098, "SIMPLY ORANGE W/ MANGO 11.5Z !", 12,1, 14.65, 1.2208, "025000000324",
            52013, "SIMPLY RASPBERRY LEMNADE 11.5Z", 12,1, 14.65, 1.2208, "025000000188",
            6701,  "CAMEL BLUE BX",                   1,60,40.94, 40.94,  "012300000079",
            13215, "CAMEL CRUSH BX",                  1,60,40.94,40.94,   "012300197410",
            5714,  "MARL BX",                         1,60,41.14,41.14,   "028200003577",
	    5716,  "MARL BX 100",                     1,60,41.14,41.14,   "028200003638",
            5715,  "MARL GOLD BX",                    1,60,41.14,41.14,   "028200003843",
            5717,  "MARL GOLD BX 100",                1,60,41.14,41.14,   "028200004659",
            5718,  "MARL SILVER BX",                  1,60,41.14,41.14,   "028200004772",
            5719,  "MARL SILVER BX 100",	      1,60,41.14,41.14,   "028200004789",
            29346, "MATCHES*BOX* 50'S            !",  1,40,0.75,0.75,	  "075218001965",
            12933, "NEWPORT BX	",	            1,  60, 45.24,45.24,  "026100005752",
            12937, "NEWPORT BX 100",                  1, 60,45.24,45.24,  "026100005738",
            12949, "NEWPORT MEN GOLD BX",           1, 60, 45.24, 45.24,    "026100005769",
            12954, "NEWPORT MEN GOLD BX 100",         1, 60, 45.24,45.24, "026100005721",
            17786, "100 GRAND KING SIZE 2.8Z     !", 24, 6, 26.55, 1.1063,"028000206604",
            18023, "3 MUSKETEERS KING SIZE 3.28Z !", 24, 6, 26.93, 1.1221,"040000006039",
            17789, "ALMOND JOY KING SIZE",           18, 8, 19.83, 1.1017,"034000005222");


my $i = 0;
$item_no = undef;
$description = undef;
$unit = undef;
$case_pack = undef;
$cost = undef;
$unit_cost = undef;
$upc = undef;


#print "at 416 dbh = $dbh\n";

my $products = new DB::Products($dbh);


#$product_info = ProductInfo->new();
#$product_info->set_item_no(17789);
#$product_info->set_description("ALMOND JOY KING SIZE");
#$product_info->set_unit(18);
#$product_info->set_case_pack(8);
#$product_info->set_cost(19.83);
#$product_info->set_unit_cost(1.1017);
#$product_info->set_upc(Upc->new("034000005222"));

#$products->insert($product_info);


foreach my $d (@data) {
    print "d = $d, i = $i\n";

    if ($i == 0) {
	$item_no = $d;

	print "item_no = $item_no\n";

    } elsif ($i == 1) {
	$description = $d;

	print "description=$description\n";
    } elsif ($i == 2) {
	$unit = $d;
	print "unit=$unit\n";
    } elsif ($i == 3) {

	$case_pack = $d;

	print "case_pack = $case_pack\n";

    } elsif ($i == 4) {
	$cost = $d;
	print "cost=$cost\n";
    } elsif ($i == 5) {
	$unit_cost = $d;
	print "unit_cost = $unit_cost\n";
    } elsif ($i == 6) {
	$upc = $d;

	print "upc = $upc\n";

	my $product_info = DB::ProductInfo->new();

	$product_info->set_item_no($item_no);
	$product_info->set_description($description);
	$product_info->set_unit($unit);
	$product_info->set_case_pack($case_pack);
	$product_info->set_cost($cost);
	$product_info->set_unit_cost($unit_cost);
	$product_info->set_upc(Core::Upc->new($upc));

	$products->insert($product_info);

	$i = -1;

    }
   
    $i++;

}


my $p = $products->lookup_by_upc(Core::Upc->new("014054030715"));
if ($p->get_description() ne  "ODWALLA MANGO PROTEIN 15.2Z  !") {
    die "test_db failed at get_description() ne ODWALLA MANGO PROTEIN 15.2Z   !\n";
}



my $prdt = $products->lookup_by_upc(Core::Upc->new("028200004659"));

if (defined($prdt)) {
    print "The description = " . $prdt->get_description() . "\n";
} else {
    print "not defined\n";
}

};


my $replenishments = DB::Replenishments->new($dbh);


my $rid;


$rid = $replenishments->begin_replenishment(DateTime->new(
						{month=>3, day=>1, year=>2015}),
					    DateTime->new(
						{month=>4, day=>4, year=>2015}));

my $re;
my @items = (["ODWALLA MANGO PROTEIN 15.2Z",    "014054030715", 1],
	     ["ODWALLA ORANGE JUICE 15.2Z   !", "014054031088", 2],
	     ["ODWALLA STRAW BANANA 15.2Z   !", "014054030883", 3],
	     ["ODWALLA STRAWBERRY C 15.2Z   !", "014054061054", 4],
	     ["ODWALLA SUPERFOOD 15.2Z     !",  "014054064055", 5],
	     ["SIMPLY CRANBERRY 11.5Z       !", "025000000300", 6],
	     ["SIMPLY LEMONADE 11.5Z        !", "025000000218", 7],
	     ["SIMPLY ORANGE 11.5Z          !", "025000000249", 8],
	     ["SIMPLY ORANGE W/ MANGO 11.5Z !", "025000000324", 9],
	     ["SIMPLY RASPBERRY LEMNADE 11.5Z", "025000000188", 10],
	     ["CAMEL BLUE BX",                  "012300000079", 11],
	     ["CAMEL CRUSH BX",                 "012300197410", 12],
	     ["MARL BX",                        "028200003577", 13],
	     ["MARL BX 100",                    "028200003638", 14],
	     ["MARL GOLD BX",                   "028200003843", 15],
	     ["MARL GOLD BX 100",               "028200004659", 16]);

foreach my $item (@items) {
    my @item_arry = @{$item};

    $re = Core::ReplenishmentEntry->new($item_arry[1], 10.00, 
				  $item_arry[0], $item_arry[2]);

    print "inserting into replenishments $rid, " . $re->get_upc()->str() . "\n";
    
    $replenishments->insert_into($rid, $re);
}

foreach my $item (@items) {
    my @item_arry = @{$item};

    my $qty_sold = $replenishments->lookup_qty_sold_by_upc(
	Core::Upc->new($item_arry[1]), DateTime->new(
	    {month=>3, day=>1, year=>2015}));


    if ($qty_sold != $item_arry[2]) {
	die "test_db failed at $qty_sold != $item_arry[2] $item_arry[1],  $item_arry[0]";

    }

}




$rid = $replenishments->begin_replenishment(DateTime->new(
						   {month=>4, day=>5, year=>2015}),
					       DateTime->new(
						   {month=>5, day=>5, year=>2015}));


$re = ReplenishmentEntry->new("028000206604", 24.00, "Sample", 25);



$replenishments->insert_into($rid, $re);



$re = ReplenishmentEntry->new("014054030715", 12.00, "ODWALLA MANGO PROTEIN 15.2Z", 44);

$replenishments->insert_into($rid, $re);



my $qtysold = $replenishments->lookup_qty_sold_by_upc(Upc->new("014054030715"),
					DateTime->new({month=>4, day=>5, year=>2015}));

if ($qtysold != 44) {
    die "test_db failed at $qtysold != 44";

}

$qtysold = $replenishments->lookup_qty_sold_by_upc(Upc->new("028000206604"),
						   DateTime->new({month=>4, 
								  day=>5, 
								  year=>2015}));

if ($qtysold != 25) {
    die "test_db failed at $qtysold != 25";
}


my $soldsince;

$soldsince = $replenishments->get_qty_sold_since_by_upc(Upc->new("028000206604"),
							DateTime->now()) . "\n";

if ($soldsince != 25) {
    die "soldsince != 25!\n";
}

$rid = $replenishments->begin_replenishment(DateTime->new({month=>5,
                                                           day=>6,
                                                           year=>2015}),
    DateTime->new({month=>5, day=>6, year=>2015}));


$re = ReplenishmentEntry->new("028000206604", 12.00, "Sample", 30);


$replenishments->insert_into($rid, $re);


$soldsince = $replenishments->get_qty_sold_since_by_upc(Upc->new("028000206604"),
    DateTime->now());


if ($soldsince != 55) {
    die "soldsince != 55!\n";
}


$soldsince = $replenishments->get_qty_sold_since_by_upc(Upc->new("028000206604"),
							DateTime->new({month=>5, day=>5,
								       year=>2015}));

if ($soldsince != 0) {
    die "soldsince != 0!\n";
}


$soldsince = $replenishments->get_qty_sold_since_by_upc(Upc->new("028000206604"),
							DateTime->new({month=>5, day=>6,
								       year=>2015}));

if ($soldsince != 25) {
    die "soldsince != 25!\n";
}


$dbh->{AutoCommit} = 0;

my $updater = ProductInfoUpdater->new($dbh);

$updater->update_product_info("PRODUCT_LIST.xlsx");

$dbh->commit();

$dbh->{AutoCommit} = 1;




my $stock_takes = StockTakes->new($dbh);

my $stock_take_id = $stock_takes->begin_stock_take(DateTime->now());

my $stock_take_info = StockTakeInfo->new();

$stock_take_info->set_upc(Upc->new("307667393057"));
$stock_take_info->set_qty_counted(12);
$stock_take_info->set_description("Foo bar");

$stock_takes->insert_into($stock_take_id, $stock_take_info);

$stock_take_info->set_upc(Upc->new("009800007653"));
$stock_take_info->set_qty_counted(14);
$stock_take_info->set_description("TIC TAC BIG PACK MELN MANGO 1Z");


$stock_takes->insert_into($stock_take_id, $stock_take_info);

my %stock_take 
    = $stock_takes->get_last_stock_take_by_upc(Upc->new("009800007653"));



if ($stock_take{qty_counted} != 14) {

    die $stock_take{qty_counted} . " != 14 failed!\n";
}


$stock_take_id = $stock_takes->begin_stock_take(DateTime->now());

$stock_take_info->set_upc(Upc->new("009800007653"));
$stock_take_info->set_qty_counted(15);
$stock_take_info->set_description("TIC TAC BIG PACK MELN MANGO 1Z");

$stock_takes->insert_into($stock_take_id, $stock_take_info);

%stock_take 
    = $stock_takes->get_last_stock_take_by_upc(Upc->new("009800007653"));



if ($stock_take{qty_counted} != 15) {
    die $stock_take{qty_counted} . " != 15 failed!\n";
}



                                              

if ($@) {
    Carp::confess( "Test Failed: " . $@ . " " . $dbh->errstr() . "\n");
} else {
    print "Tests finished\n";
}



