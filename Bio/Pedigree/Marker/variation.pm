# $Id$
#
# module for Bio::Pedigree::Marker::variation
#
# Cared for by Jason Stajich  <jason@bioperl.org>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Pedigree::Marker::variation - module for managing variations (SNP, microsat) 

=head1 SYNOPSIS

    use Bio::Pedigree::Marker;
    my $variation = new Bio::Pedigree::Marker(-name => 'D1S123',
					      -description => 'Chrom 1 marker',
					      -type => 'Variation',
					      -chrom => 1,
					      -alleles => { 130  => 0.0319,
							    132  => 0.1596,
							    136  => 0.0851,
							    138  => 0.2128,
							    140  => 0.0532,
						          },
					      -fwdflank => $seqfwd,
					      -revflank => $seqrev
);

=head1 DESCRIPTION

This module manages Lapis Variation (Allele) Marker information.

=head1 AUTHOR - Jason Stajich

Email jasona-at-bioperl-dot-org

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

# Let the code begin...

package Bio::Pedigree::Marker::variation;
use vars qw(@ISA);
use strict;

use Bio::Pedigree::Marker;
use Bio::PrimarySeq;

@ISA = qw(Bio::Pedigree::Marker);

=head2 new

 Title   : new
 Usage   : my $variation = new Bio::Pedigree::Variation
			   ( -name    => $name,
			     -desc    => $desc,
			     -display => $disp,
			     -alleles => { 171 => 0.0500,
					   175 => 0.4500,
					   179 => 0.3100,
					   183 => 0.1200,
					   187 => 0.0700 },
			     -fwdflank => $seqfwd,
			     -revflank => $seqrev,
			     );

 Function: build a Bio::Pedigree::Variation object
 Returns : Bio::Pedigree::Variation
 Args    : All fields are required unless specified as optional
           -name     => name of the marker, this is expected to be unique
           -alleles  => hash ref of available alleles for this marker with
			associated frequencies for each allele
           -display  => (optional) a display name for the marker if 
                        preferred over 'name' when displaying
                        available markers 
           -desc     => (optional) description text for marker
           -chrom    => (optional) chromsome
           -fwdflank => Bio::PrimarySeqI object or DNA string for the 
			forward flanking sequence of the marker  
			(optional)
           -revflank => Bio::PrimarySeqI object or DNA string for the
			reverse flanking sequence of the marker
			(optional)

=cut

sub _initialize { 
    my ($self, @args) = @_;
    $self->SUPER::_initialize(@args);

    $self->{'_alleles'} = {};

    my ($alleles,$chrom,
	$fwd,$rev) = $self->_rearrange([qw(ALLELES
					   CHROM FWDFLANK
					   REVFLANK)], @args);
    if( ! defined $alleles || ref($alleles) !~ /hash/i ) {
	$self->throw("Did not specify alleles as a hash ref");
    }
    while( my($allele, $freq) = each  %{$alleles} ) {
	$self->add_Allele_Frequency( $allele, $freq);
    }
    # optional fields
    $fwd     && $self->upstream_flanking_seq($fwd);
    $rev     && $self->dnstream_flanking_seq($rev);
    defined $chrom   && $self->chromosome($chrom);
    return;
}

=head2 name

 Title   : name
 Usage   : my $name = $marker->name();
 Function: Get/Set marker name
 Returns : string
 Args    : [optional] marker name to set

=cut


=head2 type

 Title   : type
 Usage   : my $type = $variation->type;
 Function: Get marker type - valid types are defined by 
           implementing classes
 Returns : type value
 Args    : none

=cut

# I guess this is an okay way to do this

sub type { return 'VARIATION'; }

=head2 description

 Title   : description
 Usage   : my $desc = $marker->description();
 Function: Get/Set marker description
 Returns : string
 Args    : [optional] marker description to set

=cut

=head2 num_result_alleles

 Title   : num_result_alleles
 Usage   : my $numalleles = $marker->num_result_alleles();
 Function: Get number of results for this type of marker           
 Returns : integer
 Args    : none

=cut

sub num_result_alleles {
    # by default 2 allele value for a variation marker,
    my ($self, $value) = @_;
    if( defined $value ) {
	$self->{'_numresultalleles'} = $value;
    }
    return $self->{'_numresultalleles'} || 2;
}

=head2 type_code

 Title   : type_code
 Usage   : my $code_type = $marker->type_code();
 Function: Get marker code type
 Returns : integer
 Args    : none

=cut

sub type_code { return 3 }


=head1 Bio::Pedigree::Marker::variation specific methods 

=head2 upstream_flanking_seq

 Title   : upstream_flanking_seq
 Usage   : my $seq = $variation->upstream_flanking_seq;
 Function: Get/Set upstream flanking seq
 Returns : Bio::PrimarySeqI object
 Args    : (optional) Bio::PrimarySeqI object to set upstream flanking sequence
 Note    : This can be PCR primers or literally flanking sequence

=cut

sub upstream_flanking_seq {
    my ($self, $seq ) = @_;
    if( defined $seq ) {
	if( !ref($seq) ) {
	    my $name = $self->name;
	    $seq = new Bio::PrimarySeq(-seq     => $seq,
				       -moltype => 'dna',
				       -desc    => "upstream seq for variation $name",
				       -id      => "upstrm_$name");
	}
	if( ! $seq || ! $seq->isa('Bio::PrimarySeqI' ) ) {
	    $self->throw("Trying to call upstream_flanking_seq with a value ($seq) that is neither a Bio::PrimarySeqI nor a valid DNA sequence");	    
	}
	$self->{'_upstrmflank'} = $seq;
    }
    return $self->{'_upstrmflank'};
}

=head2 dnstream_flanking_seq

 Title   : dnstream_flanking_seq
 Usage   : my $seq = $variation->dnstream_flanking_seq;
 Function: Get/Set dnstream flanking seq
 Returns : Bio::PrimarySeqI object
 Args    : (optional) Bio::PrimarySeqI object to set dnstream flanking sequence
 Note    : This can be PCR primers or literally flanking sequence

=cut

sub dnstream_flanking_seq{
    my ($self, $seq ) = @_;
    if( defined $seq ) {
	if( !ref($seq) ) {
	    my $name = $self->name;
	    $seq = new Bio::PrimarySeq(-seq     => $seq,
				       -moltype => 'dna',
				       -desc    => "dnstream seq for variation $name",
				       -id      => "dnstrm_$name");
	}
	if( ! $seq || ! $seq->isa('Bio::PrimarySeqI' ) ) {
	    $self->throw("Trying to call dnstream_flanking_seq with a value ($seq) that is neither a Bio::PrimarySeqI nor a valid DNA sequence");	    
	}
	$self->{'_dnstrmflank'} = $seq;
    }
    return $self->{'_dnstrmflank'};
}


# Okay this should be changed - only Mapped Markers should have a chromosome
# field

=head2 chromosome

 Title   : chromosome
 Usage   : my $chrom = $marker->chromosome();
 Function: Get/Set chromosome
 Returns : chrom (string)
 Args    : [optional] chrom value to set

=cut

sub chromosome {
    my $self = shift;
    $self->{'_chrom'} = shift if @_;
    return $self->{'_chrom'};
}


__END__

1;
