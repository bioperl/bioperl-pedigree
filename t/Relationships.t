# -*-Perl-*-

use Test;

BEGIN { 
    use vars qw($NUMTESTS);
    $NUMTESTS = 5;
    plan tests => $NUMTESTS;
}

use Bio::Pedigree;
use Bio::Pedigree::Group;
use Bio::Pedigree::PedIO;
use Bio::Root::IO;

ok(1);

my $pedio = new Bio::Pedigree::PedIO(-format => 'lapis');
my $pedigree = $pedio->read_pedigree(-pedfile => Bio::Root::IO->catfile('t','data', 'test2.lap'));

ok($pedigree->calculate_all_relationships(), 12);
my ($group1) = $pedigree->each_Group;
my $out = new Bio::Pedigree::PedIO(-format => 'xml');
$out->write_pedigree(-pedfile  => '>test.xml',
		     -pedigree => $pedigree);

