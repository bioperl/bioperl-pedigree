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

Bio::Pedigree::Marker::variation - module for managing variations (SNP, msat) 

=head1 SYNOPSIS

    use Bio::Pedigree::Marker;
    my $variation = new Bio::Pedigree::Marker(-name => 'D1S123',
					   -desc => 'Chrom 1 marker',
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

Email jason@bioperl.org

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

    my ($name,$alleles, $desc, $chrom, 
	$fwd,$rev) = $self->_rearrange([qw(NAME ALLELES
					   DESC CHROM FWDFLANK
					   REVFLANK)], @args);
    if( ! defined $name ) {
	$self->throw("Did not specify a valid name for the marker");
    }
    $self->name($name);

    if( ! defined $alleles || ref($alleles) !~ /hash/i ) {
	$self->throw("Did not specify alleles as a hash ref");
    }
    while( my($allele, $freq) = each  %{$alleles} ) {
	$self->add_allele( $allele, $freq);
    }
    # optional fields
    $fwd     && $self->upstream_flanking_seq($fwd);
    $rev     && $self->dnstream_flanking_seq($rev);
    $chrom   && $self->chrom($chrom);
    $desc    && $self->description($desc);

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

=head2 chrom

 Title   : chrom
 Usage   : my $chrom = $marker->chrom();
 Function: Get/Set chrom
 Returns : chrom (string)
 Args    : [optional] chrom value to set

=cut

sub chrom {
    my ($self, $value) = @_;
    if( defined $value ) {
	$self->{'_chrom'} = $value;
    }
    return $self->{'_chrom'};
}


=head2 known_alleles

 Title   : known_alleles
 Usage   : @alleles = $marker->known_alleles
 Function: Get list of the known alleles 
 Returns : @array of known alleles
 Args    : none

=cut 

sub known_alleles {
    my($self) = @_;
    my @a = sort { $b <=> $a || $b cmp $a } keys %{ $self->{'_alleles'} } ;
    return @a;
}

=head2 add_allele

 Title   : add_allele
 Usage   : $marker->add_allele($name, $freq);
 Function: Adds an allele and frequency for a Marker
 Returns : none
 Args    : name  => Allele name 
           freq  => (optional) allele frequency     

=cut

sub add_allele{
    my ($self,$name,$freq) = @_;
    return 0 if( !defined $name || ! defined $freq); 
    $self->{'_alleles'}->{$name} = $freq;
    return scalar keys %{ $self->{'_alleles'} };
}


=head2 remove_allele

 Title   : remove_allele
 Usage   : $marker->remove_allele($name);
 Function: Remove an allele from a Marker
 Returns : none
 Args    : name -> allele name

=cut

sub remove_allele {
    my ($self,$name) = @_;
    delete $self->{'_alleles'}->{$name};
}


=head2 get_allele_frequency

 Title   : get_allele_frequency
 Usage   : my $freq = $marker->get_allele_frequency('171');
 Function: Returns the allele frequency for a specific allele, 
           undef if allele is not known
 Returns : frequency of an allele
 Args    : allele name

=cut

sub get_allele_frequency{
    my ($self,$name) = @_;
    # will return undef if $name DNE
    return $self->{'_alleles'}->{$name};
}

__END__

1;
