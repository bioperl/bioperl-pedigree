
#
# BioPerl module for Bio::Pedigree::GroupI
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
    print "group is ", $group->center, " ", $group->groupid, "\n";

=head1 DESCRIPTION

This interface defines the minimum methods needed to create a Group of
individuals in a Pedigree.

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

Email jason@bioperl.org

Describe contact details here

=head1 APPENDIX

The rest of the documentation details each of the object methods.
Internal methods are usually preceded with a _

=cut


# Let the code begin...


package Bio::Pedigree::GroupI;
use strict;
use Bio::Root::RootI;
use vars qw(@ISA);
@ISA = qw(Bio::Root::RootI);

=head2 add_Person

 Title   : add_Person
 Usage   : $group->add_Person($person, $overwrite);
 Function: adds a person to the group
 Returns : count of number of people, 
 Args    : person    - Bio::Pedigree::PersonI object to add
           overwrite - overwrite the person currently stored for a specific
                       id.
 Throws  : Exception if a person with the id $person->id  already exists
           unless $overwrite is true

=cut

sub add_Person{
    shift->throw_not_implemented();
}

=head2 remove_Person

 Title   : remove_Person
 Usage   : $group->remove_Person($person->id );
 Function: Removes a person with the specified id
 Returns : boolean if person was removed, false if no person
           exists for that id

           This method currently will not check if 
           person is depended upon (ie a parent of an existing child)
           and does not update the child\'s parent ids.  Maybe it should!

 Args    : id of person to remove.

=cut

sub remove_Person{
    shift->throw_not_implemented();
}

=head2 num_of_people

 Title   : num_of_people
 Usage   : my $count = $group->num_of_people;
 Function: returns the number of people currently in a group
 Returns : integer
 Args    : none

=cut

sub num_of_people{
    shift->throw_not_implemented();
}

=head2 each_Person

 Title   : each_Person
 Usage   : my @people = $group->each_Person();
 Function: returns an array of objects representing
           the people in the group. 
           If the string 'id' is passed as an argument will
           only return an array of ids for the stored people
 Returns : @array of Bio::Pedigree::PersonI or ids
 Args    : (optional) 'id' will cause method to only return a list of ids
           for the people stored within the group rather than the
           Bio::Pedigree::PersonI objects

=cut

sub each_Person{
    shift->throw_not_implemented();
}

=head2 get_Person

 Title   : get_Person
 Usage   : my $p = $group->get_Person($id);
 Function: returns the person object based on a specific person id
 Returns : Bio::Pedigree::PersonI object or undef if that id does not exist
 Args    : person id for person to retrieve

=cut

sub get_Person{
    shift->throw_not_implemented();
}

=head2 delete_Marker

 Title   : delete_Marker
 Usage   : $group->delete_Marker($name);
 Function: For a given variation name, delete its alleles from all
           individuals contained within the group
 Returns : boolean on success  - false if marker does not exist for anyone
                                 true if at least one person had the marker
 Args    : marker name

=cut

sub delete_Marker{
    shift->throw_not_implemented();
}

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

=head2 groupid

 Title   : groupid
 Usage   : my $id = $group->groupid()
 Function: Get/Set Group ID number for this group
 Returns : integer
 Args    : integer (optional) integer to set the group id to

=cut

sub groupid {
    shift->throw_not_implemented();
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
   return $self->center . " ". $self->groupid;
}

=head2 description

 Title   : description
 Usage   : my $description = $group->description; #or
 Function: Get/Set Group description value
 Returns : string 
 Args    : string (optional) string to set the group description to

=cut

sub description {
    shift->throw_not_implemented();
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

=head2 Algorithms

=cut

=head2 calculate_relationships

 Title   : calculate_relationships
 Usage   : $group->calculate_relationships('warn');
 Function: Calculates child->parent pointers and sibships and
           fills in information for people where applicable
 Returns : number of updates made
 Args    : warnings - if program should warn when updating
           incorrectly specified relationships
           valid input is 
           'warnOnError' - to display warnings but to overwrite
           'failOnError' - to throw and exception when an error is found
           passing anything else (or no argument) will cause method to 
           update errors quietly

=cut

sub calculate_relationships {
    shift->throw_not_implemented();
}

=head2 find_founders

 Title   : find_founders
 Usage   : my @founders = $group->find_founders();
 Function: Returns a list of 2-pule arrays for each set of founders
           Founders which are multi-married can be a problem some
           implementation may insert an artificial ancestor lineage 
           to solve this problem
 Returns : Array of 2-pule arrays for each couple that can be considered
           a founder (ie a couple which both people have no parents
		      in the pedigree)
 Args    : none

=cut

sub find_founders {
    shift->throw_not_implemented();
}

1;


