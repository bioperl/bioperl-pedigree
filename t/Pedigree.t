# -*-Perl-*-
use strict;

BEGIN { 
    use vars qw($NUMTESTS $error) ;
    $NUMTESTS = 4;
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
	skip("Skipping rest of Pedigree tests",1);
    }
}
use Bio::PopGen::Genotype;
use Bio::Pedigree::Person;
use Bio::Pedigree::Group;
use Bio::Pedigree::Pedigree;


if( $error == 1 ) { exit(0); }

my @r = ( new Bio::PopGen::Genotype(-marker_name    => 'D1S234',
				      -alleles => [100,102] ),
	  new Bio::PopGen::Genotype(-marker_name    => 'CFDX',
				      -alleles => ['A'] ),		
	  );

my @p;
 
push @p, ( new Bio::Pedigree::Person(-person_id => 1,
				     -father_id => 0,
				     -mother_id => 0,
				     -gender   => 'M',
				     -genotypes  => [@r]) );

@r = ( new Bio::PopGen::Genotype(-marker_name    => 'D1S234',
				 -alleles => [110,105] ),
       new Bio::PopGen::Genotype(-marker_name    => 'CFDX',
				 -alleles => ['U'] ),		
       );
push @p, ( new Bio::Pedigree::Person(-person_id   => 2,
				     -father_id   => 0,
				     -mother_id   => 0,
				     -gender      => 'F',
				     -genotypes   => [@r]) );

@r = ( new Bio::PopGen::Genotype(-marker_name    => 'D1S234',
				 -alleles => [110,102] ),
       new Bio::PopGen::Genotype(-marker_name    => 'CFDX',
				 -alleles => ['A'] ),		
       );

push @p, ( new Bio::Pedigree::Person(-person_id  => 3,
				     -father_id  => 1,
				     -mother_id  => 2,
				     -gender     => 'M',
				     -genotypes  => [@r] ));

my $group = new Bio::Pedigree::Group( -people  => [@p],
				      -center  => 'DUK',
				      -group_id => 1,
				      -type    => 'FAMILY',
				      -description    => 'simple example');

my $pedigree = new Bio::Pedigree::Pedigree( -groups => [ $group ]);

ok ($pedigree);
ok ($pedigree->num_of_groups, 1);

ok ($pedigree->get_Group("DUK 1")->center_groupid, $group->center_groupid);

ok ($pedigree->add_Group($group), 1 );
