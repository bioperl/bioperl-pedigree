# -*-Perl-*-

use strict;

BEGIN {
    use vars qw($NUMTESTS $error) ;
    
    $NUMTESTS = 17;
    $error = 0;
    eval { require Test; };
    if( $@ ) {
	use lib 't';
    }
    use Test;
    plan tests => $NUMTESTS;
    eval { require Tie::IxHash;
	   require Bio::Pedigree;
	   require Bio::Pedigree::Group;
	   require Bio::Pedigree::Result;
       };
    if( $@ ) {
	print STDERR "skipping tests because Tie::IxHash is not installed\n";
	$error = 1;
    }
}

END { 
    for ( $Test::ntest..$NUMTESTS ) {
	skip("Skipping rest of Group tests",1);
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
				     -father   => 0,
				     -mother   => 0,
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

my @expected = qw(110 105);
foreach my $allele ( $p[1]->get_Result('D1S234')->alleles ) {
    ok ($allele, shift @expected);
}

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

ok ($group);
ok ($group->isa('Bio::Pedigree::GroupI'));

ok ($group->center, 'DUK');
ok ($group->groupid, 1);
ok ($group->type, 'FAMILY');
ok ($group->description, 'simple example');

ok ($group->num_of_people, 3);
ok (($group->each_Person)[0]->personid, 1);

my $person = $group->get_Person(2);
ok ($person);
ok ($person->personid, 2);

@expected = qw(110 105);
foreach my $allele ( $person->get_Result('D1S234')->alleles ) {
    ok ($allele, shift @expected);
}

$group->remove_Marker('D1S234');
ok( ! $group->get_Person(2)->get_Result('D1S234'));

ok ($group->remove_Person(3));
ok ($group->num_of_people, 2);


