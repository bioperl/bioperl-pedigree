# -*-Perl-*-

use Test;

BEGIN { 
    use vars qw($NUMTESTS);
    $NUMTESTS = 22;
    plan tests => $NUMTESTS;
}

use Bio::Pedigree::Person;
use Bio::Pedigree::Result;

ok(1);

my @r = ( new Bio::Pedigree::Result(-name    => 'D1S234',
					  -alleles => [100,102] ),
		new Bio::Pedigree::Result(-name    => 'CFDX',
					  -alleles => ['A'] ),		
		);

my $person = new Bio::Pedigree::Person(-personid => 1,
				       -fatherid => 0,
				       -motherid => 0,
				       -gender   => 'M',
				       -results  => [@r]);
ok ($person);
ok ($person->isa('Bio::Pedigree::PersonI'));

# test initialization from new
ok ($person->personid, 1);
ok ($person->fatherid, 0);
ok ($person->motherid, 0);
ok ($person->gender, 'M');
my @results = $person->each_Result;
ok (@results, 2);

my $result = shift @results;
ok ($result->alleles, 2);
ok ($result->name, 'D1S234');
ok ( ($result->alleles)[0], 100);
ok ( ($result->alleles)[1], 102);

$result = shift @results;
ok (scalar ($result->alleles), 1);
ok ($result->name, 'CFDX');
ok (($result->alleles)[0], 'A');

# test that gender translate numeric to char code
$person->gender('2');
ok ($person->gender, 'F');

$result = new Bio::Pedigree::Result(-name => 'D2S111',
				    -alleles => [ 170,100 ] );
$person->add_Result($result);

@results = $person->each_Result;
ok (@results, 3);
# this is the order they are returned in, 
# since the order results are returned in from each_Result is
# not guaranteed to be anything I had to figure this out
# experimentally.  Typically marker order is NOT important
# because individuals will be queried one marker at a time.
ok (($results[1]->alleles)[0], 100);
ok (($results[1]->alleles)[1], 170);

$result->alleles(110,165);
$person->add_Result($result,1);

@results = $person->each_Result;
ok (@results, 3);
ok (($results[1]->alleles)[0], 110);
ok (($results[1]->alleles)[1], 165);

# add check for remove_Marker
