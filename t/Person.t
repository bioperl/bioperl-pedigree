# -*-Perl-*-

use Test;
use strict;

BEGIN { 
    use vars qw($NUMTESTS $error) ;
    $NUMTESTS = 22;
    $error = 0;
    eval { require Test; };
    if( $@ ) {
	use lib 't';
    }
    use Test;
    plan tests => $NUMTESTS;
    eval { require Tie::IxHash;
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
	skip("Skipping rest of Person tests",1);
    }
}

if( $error == 1 ) { exit(0); }


ok(1);

my @r = ( new Bio::Pedigree::Result(-name    => 'D1S234',
					  -alleles => [100,102] ),
		new Bio::Pedigree::Result(-name    => 'CFDX',
					  -alleles => ['A'] ),		
		);

my $person = new Bio::Pedigree::Person(-personid => 1,
				       -father => 0,
				       -mother => 0,
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
ok ( ($result->alleles)[0], 102);
ok ( ($result->alleles)[1], 100);

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

# results are always returned 
my @expected = qw(170 100);
foreach my $allele ( $results[2]->alleles ) {
    ok ($allele, shift @expected);
}

$result->alleles(110,165);

# test overwriting
$person->add_Result($result,1);
@results = $person->each_Result;
ok (@results, 3);

@expected = qw(165 110);
foreach my $allele ( $results[2]->alleles ) {
    ok ($allele, shift @expected);
}

# add check for remove_Marker
