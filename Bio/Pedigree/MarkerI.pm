# $Id$
#
# BioPerl module for Bio::Pedigree::MarkerI
#
# Cared for by Jason Stajich <jason@chg.mc.duke.edu>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Pedigree::MarkerI - DESCRIPTION of Object

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


package Bio::Pedigree::MarkerI;
use strict;

use Carp;

sub _abstractDeath {
  my $self = shift;
  my $package = ref $self;
  my $caller = (caller)[1];
  
  confess "Abstract method '$caller' defined in interface Bio::Pedigree::MarkerI not implemented by pacakge $package. Not your fault - author of $package should be blamed!";
}

=head2 display_name

 Title   : display_name
 Usage   : my $name = $marker->display_name;
 Function: Get/Set Marker Display name
 Returns : string
 Args    : (optional) string to set

=cut

=head2 name

 Title   : name
 Usage   : my $name = $marker->name;
 Function: Get/Set Marker name
 Returns : string
 Args    : (optional) string to set


=cut

sub name{
    $_[0]->_abstractDeath;
}

=head2 type

 Title   : type
 Usage   : my $type = $marker->type;
 Function: Get marker type - valid types are defined by 
           implementing classes
 Returns : type value
 Args    : none

=cut

sub type{
    $_[0]->_abstractDeath;
}

=head2 description

 Title   : description
 Usage   : my $desc = $marker->description();
 Function: Get/Set description for a marker
 Returns : Description string 
 Args    : (optional) string to set as description

=cut

sub description{
    $_[0]->_abstractDeath;
}


=head2 num_of_alleles

 Title   : num_of_alleles
 Usage   : my $count = $marker->num_of_alleles
 Function: returns the number of alleles known for this Marker
 Returns : integer
 Args    : none


=cut

sub num_of_alleles{
    $_[0]->_abstractDeath;
}

=head2 known_alleles

 Title   : known_alleles
 Usage   : @alleles = $marker->known_alleles
 Function: returns a list of the known alleles for this marker
 Returns : @array of known alleles
 Args    : none

=cut 

sub known_alleles {
    $_[0]->_abstractDeath;
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
    $_[0]->_abstractDeath;

}

=head2 add_allele

 Title   : add_allele
 Usage   : $marker->add_allele($name, $freq);
 Function: Adds and allele and frequency for a Marker
 Returns : none
 Args    : name  => Allele name 
           freq  => (optional) allele frequency     
=cut

sub add_allele{
    $_[0]->_abstractDeath;
}

=head2 remove_allele

 Title   : remove_allele
 Usage   : $marker->remove_allele($name);
 Function: Remove an allele from a Marker
 Returns : none
 Args    : name -> allele name

=cut

sub remove_allele {
    $_[0]->_abstractDeath;
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
    $_[0]->_abstractDeath;
}

1;
