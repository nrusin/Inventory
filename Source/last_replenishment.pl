#!/usr/bin/perl
use DBI;
use DB::Replenishments;
use DB::Replenishment;
use DB::Products;
use DateTime;


sub usage {
    die "last_replenishment [number of days] [department]";
}

sub is_jetway {
    my $desc = shift;
    my $result = 0;

   
    if ($desc =~ m/DIRTY CHIPS|SIMPLY 7|POPCHIPS|POPCORNERS|PRETZEL CRISPS|PRETZEL PETE|ROCKY MOUNTAIN|EDAMAME|SNAPEA|APPLE CRISP/i) {

	$result = 1;
    } elsif ($desc =~ m/PEELED SNACKS|BROWNIE BRITTLE|BLUE DIAMOND/i) {
	$result = 1;
    }



    return $result;
	

}

sub is_snkclub {
    my $desc = shift;


    return $desc =~ m/SNKCLUB/i;
}


sub is_downstairs {
    my $desc = shift;

    return is_jetway($desc) || is_snkclub($desc);
}


sub is_upstairs {
    my $depno = shift;



    return $depno == 7 || $depno == 8 || $depno == 12 || $depno == 13 || $depno == 17;
}



my $no_of_days = $ARGV[0];

if (!defined($no_of_days)) {
    usage();
}


if (!($no_of_days =~ m/\d+/)) {
    usage();

}


my $department = $ARGV[1];

if ($department =~ m/newspaper/i) {
    $depaertment = 1;
} elsif ($department =~ m/mag/i) {
    $department = 2;
} elsif ($department =~ m/bev/i) {
    $department = 3;
} elsif ($department =~ m/candy/i) {
    $department = 6;
} elsif ($department =~ m/snacks/i) {
    $department = 19;
} elsif ($department =~ m/hba/i) {
    $department = 14;
} elsif ($department =~ m/souvenir/i) {
    $department = 7;
} elsif ($department =~ m/apparel/i) {
    $department = 8;
} elsif ($department =~ m/travel/i) {
    $department = 12;
} elsif ($department =~ m/toys/i) {
    $department = 13;
} elsif ($department =~ m/electronics/i) {
    $department = 15;
} elsif ($department =~ m/stationary/i) {
    $department = 17;
} elsif ($department =~ m/food/i) {
    $department = 18;
}






my $dbh = DBI->connect("dbi:SQLite:dbname=../Data/p.db", "", "",
		       { RaiseError => 1 });


my $replenishments = DB::Replenishments->new($dbh);

my $replenishment;

my $iter = $replenishments->get_iterator();


$iter->fetch_replenishment();

while($replenishment = $iter->fetch_replenishment()) {
    print $replenishment->get_beginning_datetime() . "\n";
    print $replenishment->get_ending_datetime() . "\n";
}

my $products = DB::Products->new($dbh);

my $piter = $products->get_iterator();



my $datetime = DateTime->now();

$datetime->subtract(days => $no_of_days);



printf("%-40s%15s%17s", "Description", "Qty Sold", "Qty(units)\n");
print("-"x100 . "\n");


my @items;

while(my $product = $piter->fetch_product) {
    my $description = $product->get_description();

    if ($department =~ m/jetway/i) {
	if (!is_jetway($description)) {
	    next;
	}

    } elsif ($department =~ m/snkclub/i) {
	if (!is_snkclub($description)) {
	    next;
	}

    } elsif ($department =~ m/downstairs/i) {
	if (!is_downstairs($description)) {
	    next;
	}
	

    } elsif ($department =~ m/upstairs/i) {
	if (!is_upstairs($product->get_department_no())) {
	    next;
	}
	
    } elsif (defined($department) && $product->get_department_no() != $department) {
	next;
    }

    my $qty_sold = $product->get_qty_sold_since($datetime);
    print "qty_sold = $qty_sold\n";
    
    #if (!defined($qty_sold)) {

#	print "qty sold not defined\n";
 #   }

    my $units = $product->get_unit();
    
    my $qty_in_units = $qty_sold/$units if $units > 0;

    $qty_in_units = "" if $units <= 0;


    my %item;

    my $upc_str = defined($product->get_upc())? $product->get_upc()->str() : "";

    $item{sku} =  $product->get_sku();
    $item{description} = $product->get_description();
    $item{qty_sold} = $qty_sold;
    $item{qty_in_units} = $qty_in_units;
    $item{upc_str} = $upc_str;
    $item{depno} = $product->get_department_no();
    $item{avg_sold} = $product->get_avg_sold();

    push @items, \%item;
}

@items = sort {

    if ($a->{depno} == $b->{depno}) {
	return $a->{description} cmp $b->{description};
    }

    return $a->{depno} <=> $b->{depno};
	

} @items;


my $cur_depno;
my $old_depno;
      
foreach $item (@items) {
    $cur_depno = $item->{depno};

    if ($cur_depno != $old_depno) {
	
	print "Department #: " . $cur_depno . "\n";
	$old_depno = $cur_depno;
    }

    printf("%5s %-50s%15d%15.3f %s\n", $item->{sku}, $item->{description}, $item->{qty_sold}, 
	   $item->{qty_in_units}, $item->{upc_str}) if $item->{qty_sold} != 0;

    printf("Avg Sold Daily: %.3f\n", $item->{avg_sold}) if $item->{qty_sold} != 0;

    print "-"x100 . "\n" if $item->{qty_sold} != 0;

 
}



