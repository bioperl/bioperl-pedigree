# $Id$
#
# BioPerl module for Bio::Pedigree::VariationI
#
# Cared for by Jason Stajich <jason@chg.mc.duke.edu>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Pedigree::VariationI - DESCRIPTION of Object

=head1 SYNOPSIS

Give standard usage here

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


package Bio::Pedigree::VariationI;
use strict;
use vars qw(@ISA);
use Bio::Pedigree::MarkerI;

use Carp;
@ISA = qw(Bio::Pedigree::MarkerI);

sub _abstractDeath {
  my $self = shift;
  my $package = ref $self;
  my $caller = (caller)[1];
  
  confess "Abstract method '$caller' defined in interface Bio::Pedigree::VariationI not implemented by pacakge $package. Not your fault - author of $package should be blamed!";
}

=head2 chrom

 Title   : chrom
 Usage   : my $chrom = $variation->chrom
 Function: Get/Set chromosome for Variation
 Returns : string representing chromosome
 Args    : (optional) string representing chromosome

=cut

sub chrom{
    $_[0]->_abstractDeath;
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
    $_[0]->_abstractDeath;
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
    $_[0]->_abstractDeath;
}

=head2 Bio::Pedigree::MarkerI methods

=head2 display_name

 Title   : display_name
 Usage   : my $name = $variation->display_name;
 Function: Get/Set Variation Display name
 Returns : string
 Args    : (optional) string to set

=head2 name

 Title   : name
 Usage   : my $name = $variation->name;
 Function: Get/Set Variation name
 Returns : string
 Args    : (optional) string to set

=head2 type

 Title   : type
 Usage   : my $type = $variation->type;
 Function: Get marker type - valid types are defined by 
           implementing classes
 Returns : type value
 Args    : none

=head2 description

 Title   : description
 Usage   : my $desc = $marker->description();
 Function: Get/Set description for a marker
 Returns : Description string 
 Args    : (optional) string to set as description

=head2 num_of_alleles

 Title   : num_of_alleles
 Usage   : my $count = $variation->num_of_alleles
 Function: returns the number of alleles known for this Variation
 Returns : integer
 Args    : none

=head2 known_alleles

 Title   : known_alleles
 Usage   : @alleles = $variation->known_alleles
 Function: Get list of the known alleles for this marker
 Returns : @array of known alleles
 Args    : none

=head2 num_of_result_alleles

 Title   : num_of_result_alleles
 Usage   : my $num_alleles_for_result = $marker->num_of_result_alleles;
 Function: returns the number of result alleles for a marker - entirely
           dependant on the marker type.
 Returns : Either '1' or '2' in almost all cases
 Args    : none

=head2 add_allele

 Title   : add_allele
 Usage   : $marker->add_allele($name, $freq);
 Function: Adds an allele and frequency for a Marker
 Returns : none
 Args    : name  => Allele name 
           freq  => (optional) allele frequency     

=head2 remove_allele

 Title   : remove_allele
 Usage   : $marker->remove_allele($name);
 Function: Remove an allele from a Marker
 Returns : none
 Args    : name -> allele name

=head2 get_allele_frequency

 Title   : get_allele_frequency
 Usage   : my $freq = $marker->get_allele_frequency('171');
 Function: Returns the allele frequency for a specific allele, 
           undef if allele is not known
 Returns : frequency of an allele
 Args    : allele name

=cut

1;
