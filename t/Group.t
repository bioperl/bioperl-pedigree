# -*-Perl-*-

use Test;

BEGIN {
    use vars qw($NUMTESTS);
    $NUMTESTS = 17;
    plan tests => $NUMTESTS;
}

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

ok (($p[1]->get_Result('D1S234')->alleles)[1], 110);
ok (($p[1]->get_Result('D1S234')->alleles)[0], 105);

@r = ( new Bio::Pedigree::Result(-name    => 'D1S234',
				 -alleles => [110,102] ),
       new Bio::Pedigree::Result(-name    => 'CFDX',
				 -alleles => ['A'] ),		
       );

ok (($p[1]->get_Result('D1S234')->alleles)[0], 105);

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
ok (($person->get_Result('D1S234')->alleles)[0], 105);

$group->remove_Marker('D1S234');
ok( ! $group->get_Person(2)->get_Result('D1S234'));

ok ($group->remove_Person(3));
ok ($group->num_of_people, 2);

