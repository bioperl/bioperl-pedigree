# -*-Perl-*-

use Test;
use strict;

BEGIN {
    use vars qw($NUMTESTS);
    $NUMTESTS = 27;
    plan tests => $NUMTESTS;
}

use Bio::Pedigree::Marker;
use Bio::PrimarySeq;

my $variation = new Bio::Pedigree::Marker
    (-name => 'D1S123',
     -desc => 'Chrom 1 msat marker',
     -type => 'variation',
     -chrom => 1,
     -alleles => { 130  => 0.0319,
		   132  => 0.1596,
		   136  => 0.0851,
		   138  => 0.2128,
		   140  => 0.0532,
		   143  => 0.4574 },
     -display => 'D1S234-prod',
     -fwdflank => new Bio::PrimarySeq(-seq     =>'CAGATAGGGATAG', 
				      -moltype => 'dna',
				      -id      => 'D1S234_pcrfwd'),
     -revflank => 'GGATAGATAGTA' );

ok($variation->isa('Bio::Pedigree::Marker') &&
   $variation->isa('Bio::Pedigree::Marker::variation')
   );
ok( $variation->name, 'D1S123' );
ok( $variation->description, 'Chrom 1 msat marker');
ok( $variation->type, 'VARIATION');
ok( $variation->chrom, 1);
ok( $variation->num_result_alleles, 2);
ok( $variation->known_alleles, 6);
ok( $variation->get_allele_frequency('130'), 0.0319);
ok( $variation->remove_allele('140') );
ok( $variation->known_alleles, 5);
ok ($variation->upstream_flanking_seq->seq(), 'CAGATAGGGATAG');
ok ($variation->dnstream_flanking_seq->seq(),  'GGATAGATAGTA');
ok ($variation->display_name, 'D1S234-prod');

my $dx = new Bio::Pedigree::Marker(-name => 'ALZAFF',
				   -desc => 'Affected Alz',
				   -type => 'disease',
				   -frequencies => [ 0.999, 0.001],
				   -liab_classes => [ qw(A) ],
				   -penetrances => [ '0.0000 0.000 1.000' ]
				);
ok($dx->isa('Bio::Pedigree::Marker') &&
   $dx->isa('Bio::Pedigree::Marker::disease')
   );
ok( $dx->name, 'ALZAFF' );
ok( $dx->description, 'Affected Alz');
ok( $dx->type, 'disease');
ok( scalar $dx->liab_classes, 1);
ok( $dx->frequencies, 2);
ok( $dx->penetrances, 1);
ok( $dx->num_result_alleles, 1);
    
my $quant = new Bio::Pedigree::Marker(-name => 'QUANT1',
				      -desc => 'Quantitative test marker',
				      -type => 'quantitative',
				      -comment => 'This is a test'
				   );
ok($quant->isa('Bio::Pedigree::Marker') &&
   $quant->isa('Bio::Pedigree::Marker::quantitative'));
ok( $quant->name, 'QUANT1' );
ok( $quant->description, 'Quantitative test marker');
ok( $quant->type, 'quantitative');
ok( $quant->comment,  'This is a test');
ok( $quant->num_result_alleles, 1);