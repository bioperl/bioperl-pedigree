# -*-Perl-*-

use Test;

BEGIN { 
    use vars qw($NUMTESTS);
    $NUMTESTS = 9;
    plan tests => $NUMTESTS;
}

END { 
    unlink('test.xml');
}
use Bio::Pedigree::Pedigree;
use Bio::Pedigree::Group;
use Bio::Pedigree::PedIO;
use Bio::Root::IO;

ok(1);

my $pedio = new Bio::Pedigree::PedIO(-format => 'lapis');
my $pedigree = $pedio->read_pedigree(-pedfile => Bio::Root::IO->catfile('t','data', 'test2.lap'));

ok($pedigree->calculate_all_relationships(), 12);
my $out = new Bio::Pedigree::PedIO(-format => 'xml');
ok($out->write_pedigree(-pedfile  => '>test.xml',
		     -pedigree => $pedigree));


my ($group1) = $pedigree->each_Group;
my $person   = $group1->get_Person('0101');
my $child    = $group1->get_Person($person->childid);
ok (defined $child);
ok ($child->patsibid, '9001');
ok ($child->patsib->personid, '9001');
my (@founders) = $group1->find_founders;
ok ( @founders, 1);
ok ($founders[0]->[0]->personid, '2000');
ok ($founders[0]->[1]->personid, '2001');
