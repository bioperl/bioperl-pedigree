# -*-Perl-*-

use Test;
use strict;

BEGIN { 
    use vars qw($NUMTESTS);
    $NUMTESTS = 10;
    plan tests => $NUMTESTS;
}

use Bio::Pedigree::Result;

ok(1);

my $result = new Bio::Pedigree::Result(-name => 'D1S123',
				       -alleles => [ 100, 102 ] );

ok ($result);
ok ($result->isa('Bio::Pedigree::ResultI'));
ok ($result->name, 'D1S123' );
my @alleles = $result->alleles;
ok (@alleles, 2);

ok ($alleles[0], 100);
ok ($alleles[1], 102);

$result->name('NEWNAME');
ok ($result->name, 'NEWNAME');

$result->alleles(306,300);
@alleles = $result->alleles;

ok ($alleles[0], 300);
ok ($alleles[1], 306);
