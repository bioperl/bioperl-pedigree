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

    eval { require XML::Writer };
    if( $@ ) {
	$SKIPXML = 1;
    }
}

END {
    for ($Test::ntest..$NUMTESTS) {
	skip("unable to run all of the ped tests, check your XML::Writer installation",1);
    }
}

if( $error == 1 ) {
    exit(0);
}

use Bio::Root::IO;
use Bio::Pedigree::PedIO;
my $io = new Bio::Root::IO;
# test lapis input
my $lapisio = new Bio::Pedigree::PedIO( -format => 'lapis', -verbose=>2);
ok ($lapisio);
my $pedigree = $lapisio->read_pedigree(-pedfile => $io->catfile('t','data',
								'test1.lap'));

ok ($pedigree);
ok ($pedigree->num_of_groups, 7);
ok ($pedigree->num_of_markers, 5);

my @markers = sort { $a->name cmp $b->name } $pedigree->each_Marker;
ok ( (shift @markers)->name, 'AAA-REC');
ok ( (shift @markers)->name, 'D1S123');
ok ( (shift @markers)->name, 'D1S234');
ok ( (shift @markers)->name, 'D1S987');
ok ( (shift @markers)->name, 'MKR90');
ok ( ! @markers );

my @groups = sort { $a->center_groupid cmp $b->center_groupid } $pedigree->each_Group;

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
ok ( $person->person_id, '2001');
ok ( $person->father_id, '3000');
ok ( $person->mother_id, '3001');
ok ( ! $person->child_id);
ok ( $person->gender, 'F');
ok ( $person->get_Genotypes(), 1);

ok( ($person->get_Genotypes('AAA-REC')->get_Alleles)[0],'N');

$person = $group->get_Person('0001');
ok ( $person);
ok ( $person->person_id, '0001');
ok ( $person->father_id, '1000');
ok ( $person->mother_id, '1001');
ok ( ! $person->child_id );
ok ( $person->gender, 'M');
ok ( $person->get_Genotypes, 5);

ok (($person->get_Genotypes('AAA-REC')->get_Alleles)[0],'A');
ok (($person->get_Genotypes('D1S123')->get_Alleles)[0],'152');
ok (($person->get_Genotypes('D1S123')->get_Alleles)[1],'148');
ok (($person->get_Genotypes('D1S987')->get_Alleles)[0],'134');
ok (($person->get_Genotypes('MKR90')->get_Alleles)[1],'159');

my $pedfmtio = new Bio::Pedigree::PedIO(-format => 'ped');

$pedigree = $pedfmtio->read_pedigree(-pedfile => $io->catfile('t', 'data', 
							      'C14_Comb_B.AFFB4.chr14.pre.txt'),
				     -datfile => $io->catfile('t', 'data', 
							      'C14_Comb.dat'));

($group) = sort { $a->group_id <=> $b->group_id } $pedigree->each_Group;

ok ($group);

ok ($group->center_groupid, "UNK 13");
ok ($group->each_Person, 4);

$person = $group->get_Person(4);

ok ($person->father_id, 1);
ok ( ! $person->father );

$group->calculate_relationships;
ok ( $person->father );
$person = $group->get_Person(3);
ok ( $person->father->person_id, 2);

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
