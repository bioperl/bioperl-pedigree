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
    eval { require Tie::IxHash;
	   require Bio::Pedigree::Pedigree;
	   require Bio::Pedigree::Group;
	   require Bio::Pedigree::Person;
	   require Bio::Pedigree::Result;
       };
    if( $@ ) {
	print STDERR "skipping tests because Tie::IxHash is not installed\n";
	$error = 1;
    }

}

END { 
    for ( $Test::ntest..$NUMTESTS ) {
	skip("Skipping rest of Pedigree tests",1);
    }
}

if( $error == 1 ) { exit(0); }

my @r = ( new Bio::Pedigree::Result(-name    => 'D1S234',
				    -alleles => [100,102] ),
	  new Bio::Pedigree::Result(-name    => 'CFDX',
				    -alleles => ['A'] ),		
	  );

my @p;
 
push @p, ( new Bio::Pedigree::Person(-personid => 1,
				     -father => 0,
				     -mother => 0,
				     -gender   => 'M',
				     -results  => [@r]) );

@r = ( new Bio::Pedigree::Result(-name    => 'D1S234',
				 -alleles => [110,105] ),
       new Bio::Pedigree::Result(-name    => 'CFDX',
				 -alleles => ['U'] ),		
       );
push @p, ( new Bio::Pedigree::Person(-personid => 2,
				     -father   => 0,
				     -mother   => 0,
				     -gender   => 'F',
				     -results  => [@r]) );

@r = ( new Bio::Pedigree::Result(-name    => 'D1S234',
				 -alleles => [110,102] ),
       new Bio::Pedigree::Result(-name    => 'CFDX',
				 -alleles => ['A'] ),		
       );

push @p, ( new Bio::Pedigree::Person(-personid => 3,
				     -father   => 1,
				     -mother   => 2,
				     -gender   => 'M',
				     -results  => [@r] ));

my $group = new Bio::Pedigree::Group( -people  => [@p],
				      -center  => 'DUK',
				      -groupid => 1,
				      -type    => 'FAMILY',
				      -desc    => 'simple example');

my $pedigree = new Bio::Pedigree::Pedigree( -groups => [ $group ]);

ok ($pedigree);
ok ($pedigree->num_of_groups, 1);

ok ($pedigree->get_Group("DUK 1")->center_groupid, $group->center_groupid);

ok ($pedigree->add_Group($group), 1 );
