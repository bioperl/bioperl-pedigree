# TODO 
# use the Bio::Variation classes here


# $Id$
#
# BioPerl module for Bio::Pedigree::Variation
#
# Cared for by Jason Stajich <jason@chg.mc.duke.edu>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Pedigree::Variation - An object to hold data for a Variation that has been genotyped  

=head1 SYNOPSIS

    use Bio::Pedigree::Variation;
    my $variation = new Bio::Pedgiree::Variation( -name => 'D1S234',
						  -display

=head1 DESCRIPTION

Describe the object here

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to
the Bioperl mailing list.  Your participation is much appreciated.

  bioperl-l@bioperl.org            - General discussion
http://bioperl.org/MailList.shtml  - About the mailing lists

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
of the bugs and their resolution. Bug reports can be submitted via
email or the web:

  bioperl-bugs@bioperl.org
  http://bioperl.org/bioperl-bugs/

=head1 AUTHOR - Jason Stajich

Email jason@chg.mc.duke.edu

Describe contact details here

=head1 APPENDIX

The rest of the documentation details each of the object methods.
Internal methods are usually preceded with a _

=cut


# Let the code begin...


package Bio::Pedigree::Variation;
use vars qw(@ISA);
use strict;

use Bio::Pedigree::VariationI;
use Bio::Root::RootI;
use Bio::PrimarySeq;

@ISA = qw(Bio::Pedigree::VariationI Bio::Root::RootI );

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

sub new {
  my($class,@args) = @_;
  
  my $self = $class->SUPER::new(@args);
  
  $self->{'_alleles'} = {};
  
  my ($name,$alleles, $display, 
      $desc, $chrom, $fwd,$rev) = $self->_rearrange([qw(NAME ALLELES DISPLAY
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
  $display && $self->display_name($display);
  $fwd     && $self->upstream_flanking_seq($fwd);
  $rev     && $self->dnstream_flanking_seq($rev);
  $chrom   && $self->chrom($chrom);
  $desc    && $self->description($desc);

  return $self;
}

=head2 Bio::Pedigree::VariationI implemented

=head2 chrom

 Title   : chrom
 Usage   : my $chrom = $variation->chrom
 Function: Get/Set chromosome for Variation
 Returns : string representing chromosome
 Args    : (optional) string representing chromosome

=cut

sub chrom{
    my ($self,$value) = @_;
    if( defined $value ) {
	# we're not going to be selective here so we can have
	# non-human chromosomes here
	$self->{'_chrom'} = $value;
    }
    return $self->{'_chrom'};
}

=head2 upstream_flanking_seq

 Title   : upstream_flanking_seq
 Usage   : my $seq = $variation->upstream_flanking_seq;
 Function: Get/Set upstream flanking seq
 Returns : Bio::PrimarySeqI object
 Args    : (optional) Bio::PrimarySeqI object to set upstream flanking sequence
 Note    : This can be PCR primers or literally flanking sequence

=cut

sub upstream_flanking_seq{
    my ($self, $seq ) = @_;
    if( defined $seq ) {
	if( !ref($seq) ) {
	    my $name = $self->name;
	    $seq = new Bio::PrimarySeq(-seq     => $seq,
				       -moltype => 'DNA',
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

=head2 Bio::Pedigree::MarkerI implemented

=head2 display_name

 Title   : display_name
 Usage   : my $name = $marker->display_name;
 Function: Get/Set Marker Display name
 Returns : string
 Args    : (optional) string to set

=cut

sub display_name {
   my ($obj,$value) = @_;
   if( defined $value) {
       $obj->{'_displayname'} = $value;
   }
   return $obj->{'_displayname'};
}

=head2 name

 Title   : name
 Usage   : my $name = $variation->name;
 Function: Get/Set Variation name
 Returns : string
 Args    : (optional) string to set


=cut

sub name{
   my ($obj,$value) = @_;
   if( defined $value) {
       $obj->{'_name'} = $value;
   }
   return $obj->{'_name'};
}

=head2 type

 Title   : type
 Usage   : my $type = $variation->type;
 Function: Get marker type - valid types are defined by 
           implementing classes
 Returns : type value
 Args    : none

=cut

# I guess this is an okay way to do this

sub type { return 'Variation'; }

=head2 description

 Title   : description
 Usage   : my $desc = $marker->description();
 Function: Get/Set description for a marker
 Returns : Description string 
 Args    : (optional) string to set as description

=cut

sub description{
    my ($self, $value) = @_;
    if( defined $value ) {
	$self->{'_description'} = $value;
    }
    return $self->{'_description'};
}


=head2 num_of_alleles

 Title   : num_of_alleles
 Usage   : my $count = $variation->num_of_alleles
 Function: returns the number of alleles known for this Marker
           In the case of a Dx marker, this will be the different 
           affection states           
 Returns : integer
 Args    : none


=cut

sub num_of_alleles{
    my ($self) = @_;
    return scalar $self->known_alleles;
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
    return keys %{ $self->{'_alleles'} };
}

=head2 num_of_result_alleles

 Title   : num_of_result_alleles
 Usage   : my $num_alleles_for_result = $marker->num_of_result_alleles;
 Function: returns the number of result alleles for a marker - entirely
           dependant on the marker type.
 Returns : Either '1' or '2' in almost all cases
 Args    : none

=cut

sub num_of_result_alleles{
    return 2;
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
    return 0 if( !defined $name); 
    $self->{'_alleles'}->{$name} = $freq || '0.0001';
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


1;
