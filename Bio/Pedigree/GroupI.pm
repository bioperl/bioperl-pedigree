
#
# BioPerl module for Bio::Pedigree::GroupI
#
# Please direct questions and support issues to <bioperl-l@bioperl.org> 
#
# Cared for by Jason Stajich <jason@bioperl.org>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Pedigree::GroupI - Group Interface definition

=head1 SYNOPSIS

    # get a Group object somehow
    print "group is ", $group->center, " ", $group->group_id, "\n";

=head1 DESCRIPTION

This interface defines the minimum methods needed to create a Group of
individuals in a Pedigree.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to
the Bioperl mailing list.  Your participation is much appreciated.

  bioperl-l@bioperl.org                  - General discussion
  http://bioperl.org/wiki/Mailing_lists  - About the mailing lists

=head2 Support 
 
Please direct usage questions or support issues to the mailing list:
  
L<bioperl-l@bioperl.org>
  
rather than to the module maintainer directly. Many experienced and 
reponsive experts will be able look at the problem and quickly 
address it. Please include a thorough description of the problem 
with code and data examples if at all possible.

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


package Bio::Pedigree::GroupI;
use strict;
use Bio::PopGen::PopulationI;
use vars qw(@ISA);

@ISA = qw(Bio::PopGen::PopulationI);

=head2 center

 Title   : center
 Usage   : my $center = $group->center()
 Function: Get/Set research center name for this group
 Returns : string
 Args    : string (optional) string to set the center name to

=cut

sub center{
    shift->throw_not_implemented();
}

=head2 group_id

 Title   : group_id
 Usage   : my $id = $group->group_id()
 Function: Get/Set Group ID number for this group
 Returns : integer
 Args    : integer (optional) integer to set the group id to

=cut

sub group_id {
    shift->name(@_);
}

=head2 center_groupid

 Title   : center_groupid
 Usage   : my $id = $group->center_groupid;
 Function: Convience function which returns the string of
           the tuple "center groupid" - which should be unique
           for a data source.
 Returns : string
 Args    : none


=cut

sub center_groupid{
   my ($self) = @_;
   return $self->center . " ". $self->group_id;
}


=head2 type

 Title   : type
 Usage   : my $ftype = $group->type;
 Function: Get/Set Family type usually "GROUP" OR "FAMILY"
           This indicates if everyone in the group is related.
           As it is possible to a defined a group which is not 
           a complete pedigree, but instead more than 1 set of
           nuclear families or singletons.
 Returns : string
 Args    : string (optional) string to set group type to 

=cut

sub type {
    shift->throw_not_implemented();
}

=head2 Inherited from Bio::PopGen::PopulationI

These are methods which inherit from Bio::PopGen::PopulationI

=head2 name

 Title   : name
 Usage   : my $name = $pop->name
 Function: Get the population name
 Returns : string representing population name
 Args    : [optional] string representing population name


=cut

sub name{
   my ($self,@args) = @_;
   $self->throw_not_implemented();
}

=head2 description

 Title   : description
 Usage   : my $description = $pop->description
 Function: Get the population description
 Returns : string representing population description
 Args    : [optional] string representing population description


=cut

sub description{
   my ($self,@args) = @_;
   $self->throw_not_implemented();
}

=head2 source

 Title   : source
 Usage   : my $source = $pop->source
 Function: Get the population source
 Returns : string representing population source
 Args    : [optional] string representing population source


=cut

sub source{
   my ($self,@args) = @_;
   $self->throw_not_implemented();
}

=head2 get_Individuals

 Title   : get_Individuals
 Usage   : my @inds = $pop->get_Individuals();
 Function: Return the individuals, alternatively restrict by a criteria
 Returns : Array of Bio::PopGen::IndividualI objects
 Args    : none if want all the individuals OR,
           -unique_id => To get an individual with a specific id
           -marker    => To only get individuals which have a genotype specific
                        for a specific marker name


=cut

sub get_Individuals{
    shift->throw_not_implemented();
}

=head2 get_Genotypes

 Title   : get_Genotypes
 Usage   : my @genotypes = $pop->get_Genotypes(-marker => $name)
 Function: Get the genotypes for all the individuals for a specific
           marker name
 Returns : Array of Bio::PopGen::GenotypeI objects
 Args    : -marker => name of the marker


=cut

sub get_Genotypes{
    shift->throw_not_implemented;
}

=head2 get_Marker

 Title   : get_Marker
 Usage   : my $marker = $population->get_Marker($name)
 Function: Get a Bio::PopGen::Marker object based on this population
 Returns : Bio::PopGen::MarkerI object
 Args    : name of the marker


=cut

sub get_Marker{
    shift->throw_not_implemented();
}

=head2 get_marker_names

 Title   : get_marker_names
 Usage   : my @names = $pop->get_marker_names;
 Function: Get the names of the markers
 Returns : Array of strings
 Args    : none


=cut

sub get_marker_names{
    my ($self) = @_;
    $self->throw_not_implemented();
}

=head2 get_Markers

 Title   : get_Markers
 Usage   : my @markers = $pop->get_Markers();
 Function: Will retrieve a list of instantiated MarkerI objects 
           for a population.  This is a convience method combining
           get_marker_names with get_Marker
 Returns : List of array of Bio::PopGen::MarkerI objects
 Args    : none


=cut

sub get_Markers{
    my ($self) = shift;
    return map { $self->get_Marker($_) } $self->get_marker_names();
}


=head2 number_individuals

 Title   : number_individuals
 Usage   : my $count = $pop->number_individuals;
 Function: Get the count of the number of individuals
 Returns : integer >= 0
 Args    : [optional] marker name, will return a count of the number
           of individuals which have this marker


=cut

sub get_number_individuals{
   my ($self) = @_;
   $self->throw_not_implemented();
}

1;


