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
    eval { require Bio::Pedigree::Person;
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

use Bio::PopGen::Genotype;

ok(1);

my @r = ( new Bio::PopGen::Genotype(-marker_name    => 'D1S234',
				    -alleles => [100,102] ),
	  new Bio::PopGen::Genotype(-marker_name    => 'CFDX',
				    -alleles => ['A'] ),		
	  );

my $person = new Bio::Pedigree::Person(-person_id   => 1,
				       -father_id  => 0,
				       -mother_id  => 0,
				       -gender     => 'M',
				       -genotypes  => [@r]);
ok ($person);
ok ($person->isa('Bio::Pedigree::PersonI'));

# test initialization from new
ok ($person->person_id, 1);
ok ($person->father_id, 0);
ok ($person->mother_id, 0);
ok ($person->gender, 'M');
# order will be CFDX then D1S234
my @results = sort { $a->marker_name cmp $b->marker_name } 
              $person->get_Genotypes;
ok (@results, 2);

my $result = shift @results;
ok (scalar ($result->get_Alleles), 1);
ok ($result->marker_name, 'CFDX');
ok (($result->get_Alleles)[0], 'A');

$result = shift @results;
ok ($result->get_Alleles, 2);
ok ($result->marker_name, 'D1S234');
ok ( ($result->get_Alleles)[1], 102);
ok ( ($result->get_Alleles)[0], 100);


# test that gender translate numeric to char code
$person->gender('2');
ok ($person->gender, 'F');

$result = new Bio::PopGen::Genotype(-marker_name => 'D2S111',
				    -alleles => [ 170,100 ] );
$person->add_Genotype($result);

@results = sort { $a->marker_name cmp $b->marker_name } $person->get_Genotypes;
ok (@results, 3);
# results are always returned 
my @expected = qw(100 170);
foreach my $allele ( sort { $a <=> $b } $results[2]->get_Alleles ) {
    ok ($allele, shift @expected);
}
$result->reset_Alleles;
$result->add_Allele(110,165);

# test overwriting
$person->add_Genotype($result);
@results = sort { $a->marker_name cmp $b->marker_name} $person->get_Genotypes;
ok (@results, 3);

@expected = qw(110 165);
foreach my $allele ( sort { $a <=> $b } $results[2]->get_Alleles ) {
    ok ($allele, shift @expected);
}

# add check for remove_Marker
