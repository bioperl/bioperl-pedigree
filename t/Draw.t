# -*-Perl-*-

use Test;
use strict;

BEGIN { 
    use vars qw($NUMTESTS);
    $NUMTESTS = 2;
    plan tests => $NUMTESTS;
}

END {
    unlink('draw3.png');
}
use Bio::Pedigree::Draw;
use Bio::Root::IO;
use Bio::Pedigree::PedIO;
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
my $tmpfile = "draw3.png";
my $draw = new Bio::Pedigree::Draw(-verbose =>$verbose);

ok($draw);
$draw->draw(-pedigree   => $pedigree2,
	    -group      => 4,
	    -rendertype => 'pedplot',
	    -file       => ">$tmpfile",
	    -format     => 'png');

ok ( -s $tmpfile);
