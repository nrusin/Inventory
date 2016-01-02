#!/usr/bin/perl


use Text::CSV;
use DBI;

$file = "chngdsc.csv";

my $dbh = DBI->connect("dbi:SQLite:dbname=p.db", "", "",
		       { RaiseError => 1});

$dbh->{AutoCommit} = 0;

my @rows;

my $csv = Text::CSV->new ({ binary => 1, eol => $/ });

while(<>) {
    $csv->parse($_);

    my @fields = $csv->fields();

    if (@fields != 3) {

	die "Number of fields must be 3";
    }


    my $sku = $fields[0];
    my $description = $fields[1];
    my $unit = $fields[2];

    print "updating...$sku, $description, $unit\n";

    my $sth = $dbh->prepare("UPDATE Products
                             SET description = ?,
                                 unit = ?
                             WHERE SKU = ?");
    $sth->bind_param(1, $description);
    $sth->bind_param(2, $unit);
    $sth->bind_param(3, $sku);

    if (!$sth->execute()) {
	die "Error executing update!";
    }


                             
}


$dbh->commit();


#while (my $row = $csv->getline (*ARGV)) {
#     my @fields = @$row;
#     print "here\n";

#     print @fields . "\n";

#}
