# -*-Perl-*-

use strict;

BEGIN {
    use vars qw($NUMTESTS $error) ;
    $NUMTESTS = 26;
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

use Bio::PrimarySeq;
use Bio::Pedigree::Group;
use Bio::Pedigree::Marker;

my $variation = new Bio::Pedigree::Marker
    (-name        => 'D1S123',
     -description => 'Chrom 1 msat marker',
     -type        => 'variation',
     -chrom       => 1,
     -alleles     => { 130  => 0.0319,
		       132  => 0.1596,
		       136  => 0.0851,
		       138  => 0.2128,
		       140  => 0.0532,
		       143  => 0.4574 },
     -display     => 'D1S234-prod',
     -fwdflank    => new Bio::PrimarySeq(-seq     =>'CAGATAGGGATAG', 
				      -moltype => 'dna',
				      -id      => 'D1S234_pcrfwd'),
     -revflank    => 'GGATAGATAGTA' );

ok($variation->isa('Bio::Pedigree::Marker') &&
   $variation->isa('Bio::Pedigree::Marker::variation')
   );
ok( $variation->name, 'D1S123' );
ok( $variation->description, 'Chrom 1 msat marker');
ok( $variation->type, 'VARIATION');
ok( $variation->chromosome, 1);
ok( $variation->num_result_alleles, 2);
my @als = $variation->get_Alleles;
ok( scalar @als, 6);

my %af = $variation->get_Allele_Frequencies;

ok( $af{'130'}, 0.0319);

# long hand to add an allele - need to support direct
# deletion of an allele I suppose
# this is to show that we can add back alleles I guess
delete $af{'140'};
$variation->reset_alleles;
foreach my $a ( keys %af ) {
    print "$a \n" if $a == 140;
    $variation->add_Allele_Frequency($a,$af{$a});
}

@als = $variation->get_Alleles;
ok( scalar @als, 5);

ok ($variation->upstream_flanking_seq->seq(), 'CAGATAGGGATAG');
ok ($variation->dnstream_flanking_seq->seq(),  'GGATAGATAGTA');
ok ($variation->display_name(), 'D1S234-prod');

my $dx = new Bio::Pedigree::Marker(-name         => 'ALZAFF',
				   -description  => 'Affected Alz',
				   -type         => 'disease',
				   -frequencies  => [ 0.999, 0.001],
				   -liab_classes => 
				   { 'A' => [ 0.0000, 0.0000, 1.0000] }
				);
ok($dx->isa('Bio::Pedigree::Marker') &&
   $dx->isa('Bio::Pedigree::Marker::disease')
   );
ok( $dx->name, 'ALZAFF' );
ok( $dx->description, 'Affected Alz');
ok( lc $dx->type, 'disease');
ok( scalar $dx->each_Liability_class, 1);
ok( ($dx->get_Penetrance_for_Class('A'))[2], 1.000);
ok( $dx->frequencies, 2);
ok( $dx->num_result_alleles, 1);
    
my $quant = new Bio::Pedigree::Marker(-name        => 'QUANT1',
				      -description => 'Quantitative test marker',
				      -type        => 'quantitative',
				      -comment     => 'This is a test'
				   );
ok($quant->isa('Bio::Pedigree::Marker') &&
   $quant->isa('Bio::Pedigree::Marker::quantitative'));
ok( $quant->name, 'QUANT1' );
ok( $quant->description, 'Quantitative test marker');
ok( $quant->type, 'QUANTITATIVE');
ok( $quant->comment,  'This is a test');
ok( $quant->num_result_alleles, 1);
