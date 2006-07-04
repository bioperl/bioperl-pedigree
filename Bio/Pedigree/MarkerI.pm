# $Id$
#
# BioPerl module for Bio::Pedigree::MarkerI
#
# Cared for by Jason Stajich <jason@bioperl.org>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Pedigree::MarkerI - Base interface for Markers in Pedigrees

=head1 SYNOPSIS

    # get a Bio::Pedigree::MarkerI object somehow
    print "name is ", $marker->name, "\n";
    print "display name is ", $marker->display_name, "\n";
    print "type is ", $marker->type, "\n";   
    print "number of alleles are ", $marker->num_of_result_alleles, "\n";
    print "description is ", $marker->description, "\n";

=head1 DESCRIPTION

This interface describes the basic Marker object as required for
describing pedigrees for linkage analysis.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is  an integral part of the evolution  of this and other
Bioperl modules. Send your  comments and suggestions preferably to the
Bioperl mailing list.  Your participation is much appreciated.

  bioperl-l@bioperl.org                  - General discussion
  http://bioperl.org/wiki/Mailing_lists  - About the mailing lists

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
of the bugs and their resolution. Bug reports can be submitted via
the web:

  http://bugzilla.open-bio.org/

=head1 AUTHOR - Jason Stajich

Email jason@bioperl.org

Describe contact details here

=head1 APPENDIX

The rest of the documentation details each of the object methods.
Internal methods are usually preceded with a _

=cut


# Let the code begin...


package Bio::Pedigree::MarkerI;
use strict;
use Bio::Root::RootI;
use vars qw(@ISA);

use Bio::PopGen::MarkerI;
@ISA = qw(Bio::PopGen::MarkerI);


=head2 num_of_result_alleles

 Title   : num_of_result_alleles
 Usage   : my $num_alleles_for_result = $marker->num_of_result_alleles;
 Function: returns the number of result alleles for a marker - entirely
           dependant on the marker type.
 Returns : Either '1' or '2' in almost all cases
 Args    : none

=cut

sub num_of_result_alleles{
    shift->throw_not_implemented();
}

=head2 type_code

 Title   : type_code
 Usage   : my $code_type = $marker->type_code();
 Function: Get marker code type
 Returns : integer
 Args    : none

=cut

sub type_code {
    shift->throw_not_implemented();
}

=head2 annotation

 Title   : annotation
 Usage   : $obj->annotation($seq_obj)
 Function: retrieve the attached annotation object
 Returns : Bio::AnnotationCollectionI or none;

See L<Bio::AnnotationCollectionI> and L<Bio::Annotation::Collection>
for more information. This method comes through extension from
L<Bio::AnnotatableI>.


=cut


sub annotation{
   my ($self,@args) = @_;

}


=head2 get_Alleles

 Title   : get_Alleles
 Usage   : my @alleles = $marker->get_Alleles();
 Function: Get the available marker alleles if they are known and stored
 Returns : Array of strings
 Args    : none


=cut

sub get_Alleles{
   my ($self) = @_;
   $self->throw_not_implemented();
}


=head2 get_Allele_Frequencies

 Title   : get_Allele_Frequencies
 Usage   : my %allele_freqs = $marker->get_Allele_Frequencies;
 Function: Get the alleles and their frequency (set relative to
           a given population - you may want to create different
           markers with the same name for different populations
           with this current implementation
 Returns : Associative array where keys are the names of the alleles
 Args    : none


=cut

sub get_Allele_Frequencies{
   my ($self) = @_;
    $self->throw_not_implemented();
}


=head2 get_Allele_range

 Title   : get_Allele_range
 Usage   : my ($min,$max) = $marker->get_Allele_range;
           my $range = $marker->get_Allele_range; $min = $range->[0];

 Function: If the alleles are number return the Allele range (min-max)

 Returns : Array of min,max in array context or else arrayref of min,max.
 Args    : none


=cut

sub get_Allele_range{
   my ($self) = @_;
   $self->throw_not_implemented();
}


=head2 Inherited from Bio::PopGen::MarkerI

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

=head2 type

 Title   : type
 Usage   : my $type = $marker->type;
 Function: Get marker type - valid types are defined by 
           implementing classes
 Returns : type value
 Args    : none

=cut

=head2 description

 Title   : description
 Usage   : my $desc = $marker->description();
 Function: Get/Set description for a marker
 Returns : Description string 
 Args    : (optional) string to set as description

=cut

=head2 unique_id

 Title   : unique_id
 Usage   : my $id = $marker->unique_id;
 Function: Get the unique marker ID
 Returns : unique ID string
 Args    : [optional ] string


=cut


1;
