#!/usr/bin/perl
use strict;
use warnings;

my $doc;


$doc = <<END;
<!DOCTYPE html>
<html lang="en">
   <head>
       <title>Inventory Use Cases</title>
       <meta charset="utf-8">
       <link rel="stylesheet" type="text/css" href="styles/tasks.css" media="screen" />
   </head>
   <body>
       <h1 class="nav">Use Cases</h1>
       <div class"nav">
       <ol>
END

    print $doc;

      

my $directory = "./";

opendir(DIR, $directory) or die $!;


my @files;

while(my $file = readdir(DIR)) {
    if (!($file =~ /^\./ || $file =~ /~$/)) {
	if ($file ne "index.html" && $file ne "generate.pl" && $file ne "Template.html") {
	    push @files, $file;
	}
    }

}

@files = sort {return $a cmp $b}  @files;


foreach my $file (@files) {
    $_ = $file;
    s/\.html//;
    
    print "            <li><a href = \"$file\">$_</a></li>\n";
}

$doc = <<END;
        </ol>
        </div>
    </body>
</html>
    
END

print $doc;
    

# at  end


