# -*-Perl-*-

use strict;

BEGIN {
    use vars qw($NUMTESTS $error) ;
    
    $NUMTESTS = 18;
    $error = 0;
    eval { require Test; };
    if( $@ ) {
	use lib 't';
    }
    use Test;
    plan tests => $NUMTESTS;
}

END { 
    for ( $Test::ntest..$NUMTESTS ) {
	skip("Skipping rest of Group tests",1);
    }
}

if( $error == 1 ) { exit(0); }
use Bio::Pedigree::Pedigree;
use Bio::Pedigree::Group;
use Bio::Pedigree::Person;
use Bio::PopGen::Genotype;

my @r = ( new Bio::PopGen::Genotype(-marker_name    => 'D1S234',
				    -alleles => [100,102] ),
	  new Bio::PopGen::Genotype(-marker_name    => 'CFDX',
				    -alleles => ['A'] ),		
	  );

my @p;
 
push @p, ( new Bio::Pedigree::Person(-person_id   => 1,
				     -father_id   => 0,
				     -mother_id   => 0,
				     -gender      => 'M',
				     -genotypes   => [@r]) );

@r = ( new Bio::PopGen::Genotype(-marker_name    => 'D1S234',
				 -alleles => [110,105] ),
       new Bio::PopGen::Genotype(-marker_name    => 'CFDX',
				 -alleles => ['U'] ),		
       );
push @p, ( new Bio::Pedigree::Person(-person_id  => 2,
				     -father_id  => 0,
				     -mother_id  => 0,
				     -gender     => 'F',
				     -genotypes  => [@r]) );

my @expected = qw(105 110 );
my ($g) = $p[1]->get_Genotypes(-marker => 'D1S234');
ok($g);
foreach my $allele ( sort { $a <=> $b } 
		     $g->get_Alleles ) {
    ok ($allele, shift @expected);
}

@r = ( new Bio::PopGen::Genotype(-marker_name    => 'D1S234',
				 -alleles => [110,102] ),
       new Bio::PopGen::Genotype(-marker_name    => 'CFDX',
				 -alleles => ['A'] ),		
       );

push @p, ( new Bio::Pedigree::Person(-person_id => 3,
				     -father_id => 1,
				     -mother_id => 2,
				     -gender    => 'M',
				     -genotypes => [@r] ));

my $group = new Bio::Pedigree::Group( -people      => [@p],
				      -center      => 'DUK',
				      -group_id    => 1,
				      -type        => 'FAMILY',
				      -description => 'simple example');

ok ($group);
ok ($group->isa('Bio::Pedigree::GroupI'));

ok ($group->center, 'DUK');
ok ($group->group_id, 1);
ok ($group->type, 'FAMILY');
ok ($group->description, 'simple example');

ok ($group->num_of_people, 3);
ok (($group->each_Person)[0]->person_id, 1);

my $person = $group->get_Person(2);
ok ($person);
ok ($person->person_id, 2);

@expected = qw(105 110);
foreach my $allele ( sort { $a <=> $b } 
		     $person->get_Genotypes('D1S234')->get_Alleles ) {
    ok ($allele, shift @expected);
}

$group->remove_Marker('D1S234');
ok( ! $group->get_Person(2)->get_Genotypes('D1S234'));

ok ($group->remove_Person(3));
ok ($group->num_of_people, 2);


