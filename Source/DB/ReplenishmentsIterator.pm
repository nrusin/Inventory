#!/usr/bin/perl

use DB::Replenishment;


package ReplenishmentsIterator;







sub new {
    my $class = shift;


    my $self = {
	dbh => shift,
	sth => undef
    };

    my $dbh = $self->{dbh};


    my $sth = $self->{sth} = $dbh->prepare("SELECT *
                             FROM Replenishments
                             ORDER BY begin_datetime DESC");


    if (!$sth->execute()) {
	die "ReplenishmentsIterator failed at new!\n";

    }


    bless $self, $class;
}


sub fetch_replenishment {
    my $self = shift;

    if (my ($id, $begin_datetime, $end_datetime) = $self->{sth}->fetchrow_array()) {
	return DB::Replenishment->new($self->{dbh}, $id);

    }

    
    return undef;
}





1
