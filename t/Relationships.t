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
use Bio::Pedigree::Group;
use Bio::Pedigree::PedIO;

my $pedio = new Bio::Pedigree::PedIO(-format => 'lapis');
my $pedigree = $pedio->read_pedigree(-pedfile => 
				     Bio::Root::IO->catfile('t','data', 
							    'test2.lap'));

ok($pedigree->calculate_all_relationships(), 9);
unless ( $SKIPXML ) {
    my $out = new Bio::Pedigree::PedIO(-format => 'xml');
    ok($out->write_pedigree(-pedfile  => '>test.xml',
			    -pedigree => $pedigree));
} else { 
    skip("Skipping XML output since XML writer does not exist",1);
}

my ($group1) = $pedigree->get_Groups;
my $person   = $group1->get_Person('0101');
my $child    = $group1->get_Person($person->child_id);
ok (defined $child);
ok ($child->patsib_id, '9002');
ok ($child->patsib->person_id, '9002');
my (@founders) = $group1->find_founders;
ok ( @founders, 1);
ok ($founders[0]->[0]->person_id, '2000');
ok ($founders[0]->[1]->person_id, '2001');
