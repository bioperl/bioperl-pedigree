
#
# BioPerl module for Bio::Pedigree::GroupI
#
# Cared for by Jason Stajich <jason@chg.mc.duke.edu>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Pedigree::GroupI - DESCRIPTION of Object

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

Email jason@chg.mc.duke.edu

Describe contact details here

=head1 APPENDIX

The rest of the documentation details each of the object methods.
Internal methods are usually preceded with a _

=cut


# Let the code begin...


package Bio::Pedigree::GroupI;
use strict;
use Carp;

sub _abstractDeath {
  my $self = shift;
  my $package = ref $self;
  my $caller = (caller)[1];
  
  confess "Abstract method '$caller' defined in interface Bio::Pedigree::GroupI not implemented by pacakge $package. Not your fault - author of $package should be blamed!";
}

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
    $_[0]->_abstractDeath;
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
    $_[0]->_abstractDeath;
}

=head2 num_of_people

 Title   : num_of_people
 Usage   : my $count = $group->num_of_people;
 Function: returns the number of people currently in a group
 Returns : integer
 Args    : none

=cut

sub num_of_people{
    $_[0]->_abstractDeath;
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
    $_[0]->_abstractDeath;
}

=head2 get_Person

 Title   : get_Person
 Usage   : my $p = $group->get_Person($id);
 Function: returns the person object based on a specific person id
 Returns : Bio::Pedigree::PersonI object or undef if that id does not exist
 Args    : person id for person to retrieve

=cut

sub get_Person{
    $_[0]->_abstractDeath();
}

=head2 delete_Variation

 Title   : delete_Variation
 Usage   : $group->delete_Variation($name);
 Function: For a given variation name, delete its alleles from all
           individuals contained within the group
 Returns : boolean on success  - false if marker does not exist for anyone
                                 true if at least one person had the marker
 Args    : marker name

=cut

sub delete_Variation{
    $_[0]->_abstractDeath();
}

=head2 center

 Title   : center
 Usage   : my $center = $group->center()
 Function: Get/Set research center name for this group
 Returns : string
 Args    : string (optional) string to set the center name to

=cut

sub center{
    $_[0]->_abstractDeath;
}

=head2 groupid

 Title   : groupid
 Usage   : my $id = $group->groupid()
 Function: Get/Set Group ID number for this group
 Returns : integer
 Args    : integer (optional) integer to set the group id to

=cut

sub groupid {
    $_[0]->_abstractDeath;
}

=head2 description

 Title   : description
 Usage   : my $description = $group->description; #or
 Function: Get/Set Group description value
 Returns : string 
 Args    : string (optional) string to set the group description to

=cut

sub description {
    $_[0]->_abstractDeath;
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
    $_[0]->_abstractDeath();
}

1;

