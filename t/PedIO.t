# -*-Perl-*-

use strict;
use vars qw($error $NUMTESTS $SKIPXML) ;


BEGIN {
    $error = 0; 
    $SKIPXML = 0;

    eval { require Test; };
    if( $@ ) {
	use lib 't';
    }
    use Test;
    
    $NUMTESTS = 48;
    plan tests => $NUMTESTS;

    eval { require Tie::IxHash;
	   require Bio::Pedigree::PedIO; };
    if( $@ ) {
	print STDERR "No Tie::IxHash installed skipping tests\n";
	$error = 1;
    }

    eval { require XML::Writer };
    if( $@ ) {
	$SKIPXML = 1;
    }
}

END {
    for ($Test::ntest..$NUMTESTS) {
	skip("unable to run all of the Draw tests, check your GD installation",1);
    }
}

if( $error == 1 ) {
    exit(0);
}

use Bio::Root::IO;

my $io = new Bio::Root::IO;
# test lapis input
my $lapisio = new Bio::Pedigree::PedIO( -format => 'lapis', -verbose=>2);
ok ($lapisio);
my $pedigree = $lapisio->read_pedigree(-pedfile => $io->catfile('t','data',
								'test1.lap'));

ok ($pedigree);
ok ($pedigree->num_of_groups, 7);
ok ($pedigree->num_of_markers, 5);

my @markers = $pedigree->each_Marker;
ok ( (shift @markers)->name, 'AAA-REC');
ok ( (shift @markers)->name, 'D1S123');
ok ( (shift @markers)->name, 'D1S234');
ok ( (shift @markers)->name, 'D1S987');
ok ( (shift @markers)->name, 'MKR90');
ok ( ! @markers );

my @groups = $pedigree->each_Group;

ok( ( shift @groups)->center_groupid, 'XXX 2200');
ok( ( shift @groups)->center_groupid, 'XXX 2201');
ok( ( shift @groups)->center_groupid, 'XXX 2202');
ok( ( shift @groups)->center_groupid, 'XXX 2203');
ok( ( shift @groups)->center_groupid, 'XXX 2204');
ok( ( shift @groups)->center_groupid, 'XXX 2205');
ok( ( shift @groups)->center_groupid, 'XXX 2206');

my $group = $pedigree->get_Group('XXX 2201');
ok ($group);

my $person = $group->get_Person(2001);

ok ( $person);
ok ( $person->pid, 4);
ok ( $person->personid, '2001');
ok ( $person->fatherid, '3000');
ok ( $person->motherid, '3001');
ok ( ! defined $person->childid);
ok ( $person->gender, 'F');
ok ( $person->each_Result, 1);

ok (($person->get_Result('AAA-REC')->alleles)[0],'N');

$person = $group->get_Person('0001');
ok ( $person);
ok ( $person->pid, 10);
ok ( $person->personid, '0001');
ok ( $person->fatherid, '1000');
ok ( $person->motherid, '1001');
ok ( ! defined $person->childid );
ok ( $person->gender, 'M');
ok ( $person->each_Result, 5);

ok (($person->get_Result('AAA-REC')->alleles)[0],'A');
ok (($person->get_Result('D1S123')->alleles)[0],'152');
ok (($person->get_Result('D1S123')->alleles)[1],'148');
ok (($person->get_Result('D1S987')->alleles)[0],'134');
ok (($person->get_Result('MKR90')->alleles)[1],'159');

my $pedfmtio = new Bio::Pedigree::PedIO(-format => 'linkage');

$pedigree = $pedfmtio->read_pedigree(-pedfile => $io->catfile('t','data',
							      'example1.pped'),
				     -datfile => $io->catfile('t','data',
							      'example1.pdat')
				     );

($group) = $pedigree->each_Group;

ok ($group);
ok ($group->center_groupid, "CTR 8888");
ok ($group->each_Person, 11);
$person = $group->get_Person(8);
ok ($person->fatherid, 5);
ok ( ! defined $person->father );

$group->calculate_relationships;
ok ( $person->father );
$person = $group->get_Person(8);
ok ( $person->father->personid, 5);

$lapisio->write_pedigree(-pedigree => $pedigree,
			 -pedfile  => \*STDOUT);

unless( $SKIPXML ) { 
    my $xmlio = new Bio::Pedigree::PedIO( -format => 'xml' );
    $xmlio->write_pedigree( -pedigree => $pedigree,
			    -pedfile  => \*STDOUT);
    ok(1);
} else { 
    skip("Skipping XML output since XML::Writer is not installed\n",1);
}
