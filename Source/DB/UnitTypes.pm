#!/usr/bin/perl


package DB::UnitTypes;



sub new {
    my $class = shift;
    my $self = {
	dbh => shift
    };
    


    bless $self, $class;
}


sub get_units {
    my $self = shift;
    my $dbh = $self->{dbh};
    my @units;
    

    my $sth = $dbh->prepare("SELECT * FROM Unit_types");


    if (!$sth->execute()) {
	die "Execute failed!";

    }


    while(my ($id, $unit_type) =  $sth->fetchrow_array()) {
	push @units, $unit_type;
    }
    
    return @units;
}



1

    

