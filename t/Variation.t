# -*-Perl-*-

use Test;

BEGIN { 
    use vars qw($NUMTESTS);
    $NUMTESTS = 11;
    plan tests => $NUMTESTS;
}

use Bio::Pedigree::Variation;
use Bio::PrimarySeq;

ok(1);

my $variation = new Bio::Pedigree::Variation
    ( -name => 'D1S234',
      -alleles => { 
	  171 => 0.0500,
	  175 => 0.4500,
	  179 => 0.3100,
	  183 => 0.1200,
	  187 => 0.0700,
      },
      -display => 'D1S234-prod',
      -desc    => 'Study 17Xg71',
      -chrom => 1,      
      -fwdflank => new Bio::PrimarySeq(-seq     =>'CAGATAGGGATAG', 
				       -moltype => 'dna',
				       -id      => 'D1S234_pcrfwd'),
      -revflank => 'GGATAGATAGTA'
      );

ok ($variation);
ok ($variation->isa('Bio::Pedigree::VariationI') && 
    $variation->isa('Bio::Pedigree::MarkerI') );
ok ($variation->name, 'D1S234');
ok ($variation->display_name, 'D1S234-prod');
ok ($variation->description, 'Study 17Xg71');
ok ($variation->chrom, 1);
ok ($variation->upstream_flanking_seq->seq(), 'CAGATAGGGATAG');
ok ($variation->dnstream_flanking_seq->seq(),  'GGATAGATAGTA');
ok ($variation->known_alleles, 5);
ok ($variation->get_allele_frequency('183'), 0.1200 );    

			  
								  
