# -*-Perl-*-

use strict;

BEGIN { 
    use vars qw($NUMTESTS $error $SKIPXML) ;
    
    $NUMTESTS = 8;
    $error = 0;
    eval { require Test; };
    if( $@ ) {
	use lib 't';
    }
    use Test;
    plan tests => $NUMTESTS;
    eval { require Tie::IxHash;
	   require Bio::Pedigree::Group;
	   require Bio::Pedigree::PedIO;
       };
    if( $@ ) {
	print STDERR "skipping tests because Tie::IxHash is not installed\n";
	$error = 1;
    }
    eval { require XML::Writer };
    if( $@ ) {
	$SKIPXML = 1;
    }
}

if( $error == 1 ) { exit(0); }
END { 
    for ( $Test::ntest..$NUMTESTS ) {
	skip("Skipping rest of Relationship tests",1);
    }
    unlink('test.xml');
}
use Bio::Root::IO;

my $pedio = new Bio::Pedigree::PedIO(-format => 'lapis');
my $pedigree = $pedio->read_pedigree(-pedfile => Bio::Root::IO->catfile('t','data', 'test2.lap'));

ok($pedigree->calculate_all_relationships(), 12);
unless ( $SKIPXML ) {
    my $out = new Bio::Pedigree::PedIO(-format => 'xml');
    ok($out->write_pedigree(-pedfile  => '>test.xml',
			    -pedigree => $pedigree));
} else { 
    skip("Skipping XML output since XML writer does not exist",1);
}

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
