# -*-Perl-*-

use Test;

BEGIN { 
    use vars qw($NUMTESTS);
    $NUMTESTS = 3;
    plan tests => $NUMTESTS;
}
use Bio::Pedigree;
use Bio::Pedigree::Group;
use Bio::Pedigree::Person;
use Bio::Pedigree::Result;

my @r = ( new Bio::Pedigree::Result(-name    => 'D1S234',
				    -alleles => [100,102] ),
	  new Bio::Pedigree::Result(-name    => 'CFDX',
				    -alleles => ['A'] ),		
	  );

my @p;
 
push @p, ( new Bio::Pedigree::Person(-personid => 1,
				     -fatherid => 0,
				     -motherid => 0,
				     -gender   => 'M',
				     -results  => [@r]) );

@r = ( new Bio::Pedigree::Result(-name    => 'D1S234',
				 -alleles => [110,105] ),
       new Bio::Pedigree::Result(-name    => 'CFDX',
				 -alleles => ['U'] ),		
       );
push @p, ( new Bio::Pedigree::Person(-personid => 2,
				     -fatherid => 0,
				     -motherid => 0,
				     -gender   => 'F',
				     -results  => [@r]) );

@r = ( new Bio::Pedigree::Result(-name    => 'D1S234',
				 -alleles => [110,102] ),
       new Bio::Pedigree::Result(-name    => 'CFDX',
				 -alleles => ['A'] ),		
       );

push @p, ( new Bio::Pedigree::Person(-personid => 3,
				     -fatherid => 1,
				     -motherid => 2,
				     -gender   => 'M',
				     -results  => [@r] ));

my $group = new Bio::Pedigree::Group( -people  => [@p],
				      -center  => 'DUK',
				      -groupid => 1,
				      -type    => 'FAMILY',
				      -desc    => 'simple example');

my $pedigree = new Bio::Pedigree( -groups => [ $group ]);

ok ($pedigree);
ok ($pedigree->num_of_groups, 1);

ok ($pedigree->get_Group("DUK 1")->center_groupid, $group->center_groupid);
