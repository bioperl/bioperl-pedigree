# -*-Perl-*-

use strict;
my $tmpfile = "draw3";
BEGIN { 
    use vars qw($error $NUMTESTS);
    $error = 0;

    eval { require Test; };
    if( $@ ) {
	use lib 't';
    }
    use Test;

    $NUMTESTS = 2;
    plan tests => $NUMTESTS;
    eval { require GD; 
       };
    if( $@ ) {
	print STDERR "Cannot load GD, skipping tests\n";
	$error = 1;
   }
}

END {
    for ($Test::ntest..$NUMTESTS) {
	skip("unable to run all of the Draw tests, check your GD installation",1);
    }
    unlink($tmpfile);
}
if( $error == 1 ) {
    exit(0);
}

use Bio::Root::IO;
use Bio::Pedigree::PedIO;
use Bio::Pedigree::Draw;
my $verbose = 0;
my $io = new Bio::Root::IO;

my $pedio = new Bio::Pedigree::PedIO(-format => 'linkage');

my $pedigree = $pedio->read_pedigree(-datfile => $io->catfile('t','data',
							      'example1.pdat'),
				     -pedfile => $io->catfile('t','data',
							      'example1.pped'));
$pedio = new Bio::Pedigree::PedIO(-format => 'lapis');

my $pedigree2 = $pedio->read_pedigree(-pedfile => $io->catfile('t','data','test1.lap'));

#my ($fh,$tmpfile) = $io->tempfile();
my $draw = new Bio::Pedigree::Draw(-verbose =>$verbose);

ok($draw);

my $gd = new GD::Image(1,1);
my $type = $gd->can('png') ? 'png' : 'gif';

$draw->draw(-pedigree   => $pedigree2,
	    -group      => 4,
	    -rendertype => 'pedplot',
	    -file       => ">$tmpfile",
	    -format     => $type);

ok ( -s $tmpfile);
