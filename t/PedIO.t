# $Id$

# -*-Perl-*-

use strict;
use Test;

BEGIN {
	use vars qw($NUMTESTS);
	$NUMTESTS = 40;
	plan tests => $NUMTESTS;
}

use Bio::Pedigree::PedIO;

# test lapis input
my $lapisio = new Bio::Pedigree::PedIO( -format => 'lapis');
ok ($lapisio);
my $pedigree = $lapisio->read_pedigree(-pedfile => 't/data/test1.lap');

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
ok ( $person->childid, undef);
ok ( $person->gender, 'F');
ok ( $person->each_Result, 1);

ok (($person->get_Result('AAA-REC')->alleles)[0],'N');

$person = $group->get_Person('0001');
ok ( $person);
ok ( $person->pid, 10);
ok ( $person->personid, '0001');
ok ( $person->fatherid, '1000');
ok ( $person->motherid, '1001');
ok ( $person->childid, undef);
ok ( $person->gender, 'M');
ok ( $person->each_Result, 5);

ok (($person->get_Result('AAA-REC')->alleles)[0],'A');
ok (($person->get_Result('D1S123')->alleles)[0],'152');
ok (($person->get_Result('D1S123')->alleles)[1],'148');
ok (($person->get_Result('D1S987')->alleles)[0],'134');
ok (($person->get_Result('MKR90')->alleles)[1],'159');


$lapisio->write_pedigree(-pedigree => $pedigree,
			 -pedfile  => \*STDOUT);