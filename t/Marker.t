# -*-Perl-*-

use strict;

BEGIN {
    use vars qw($NUMTESTS $error) ;
    $NUMTESTS = 27;
    $error = 0;
    eval { require Test; };
    if( $@ ) {
	use lib 't';
    }
    use Test;
    plan tests => $NUMTESTS;
    eval { require Tie::IxHash;
	   require Bio::Pedigree::Group;
	   require Bio::Pedigree::Result;
	   require Bio::Pedigree::Marker;
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
ok( $variation->chromosome, 1);
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
