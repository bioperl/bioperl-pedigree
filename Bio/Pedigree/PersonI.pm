# $Id$
#
# BioPerl module for Bio::Pedigree::PersonI
#
# Cared for by Jason Stajich <jason@chg.mc.duke.edu>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Pedigree::PersonI - Interface defining the methods for a Person in a Pedigree

=head1 SYNOPSIS

    # get a PersonI object somehow
    print "id is ", $person->personid, " father id is ", $person->fatherid, 
          " motherid is ", $person->motherid, "\n";
   

=head1 DESCRIPTION

This interface defines the minimum methods required to have a Person
in a Pedigree.

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


package Bio::Pedigree::PersonI;
use vars qw(@ISA);
use strict;

use Carp;

sub _abstractDeath {
  my $self = shift;
  my $package = ref $self;
  my $caller = (caller)[1];
  
  confess "Abstract method '$caller' defined in interface Bio::Pedigree::PersonI not implemented by pacakge $package. Not your fault - author of $package should be blamed!";
}

=head2 personid

 Title   : personid
 Usage   : my $pid = $person->personid;
 Function: Get/Set the id for a person
 Returns : id for a person
 Args    : (optional) id to set for a person

=cut

sub personid{
    $_[0]->_abstractDeath;
}

=head2 fatherid

 Title   : fatherid
 Usage   : my $fid = $person->fatherid;
 Function: Get/Set the father id for a person
 Returns : father id for a person
 Args    : (optional) father id to set for a person

=cut

sub fatherid{
    $_[0]->_abstractDeath
}

=head2 motherid

 Title   : motherid
 Usage   : my $fid = $person->motherid;
 Function: Get/Set the mother id for a person
 Returns : mother id for a person
 Args    : (optional) mother id to set for a person

=cut

sub motherid{
    $_[0]->_abstractDeath
}

=head2 gender

 Title   : gender
 Usage   : my $gender = $person->gender;
 Function: Get/Set gender for person
 Returns : gender ("M","F", "U")
 Args    : (optional) gender code to store 

=cut

sub gender{
    $_[0]->_abstractDeath;
}

=head2 displayid

 Title   : displayid
 Usage   : my $dispylid = $person->displayid
 Function: Returns the display id for a person which is more informative
            than the personid (ie personid is typically the order in the family
            while display_id might be the id code for individual like : 1001),
            or perhaps a string.  It is expected to be unique within a 
            family/group.
 Returns : string representing displayid
 Args    : (optional) string to set displayid to

=cut

sub displayid{
    $_[0]->_abstractDeath;
}

=head2 add_Result

 Title   : add_Result
 Usage   : $person->add_Result($result,$overwrite);
 Function: Add a result for a person
 Returns : count of number of results or 0 if the addition failed
 Args    : result to add, 
           boolean if existing results should be overwritten
 Throws  : Exception if a result with the name $result->name  already exists
           unless $overwrite is true
=cut

sub add_Result{
    $_[0]->_abstractDeath;
}

=head2 remove_Result

 Title   : remove_Result
 Usage   : $person->remove_Result($markername)
 Function: removes a result based on its name
 Returns : boolean if succeeded
 Args    : marker name to remove

=cut

sub remove_Result{
    $_[0]->_abstractDeath;
}

=head2 each_Result

 Title   : each_Result
 Usage   : my @results = $person->each_Result;
 Function: returns the list of Results for a person
 Returns : Either the name of the variations or the list of Result objects
 Args    : (optional) 'name' to just get the list of variations
                      that are contained for this person.

=cut

sub each_Result{
    $_[0]->_abstractDeath;
}

=head2 get_Result

 Title   : get_Result
 Usage   : my $result = $person->get_Result($name);
 Function: Get a specific result for a person - or undef if not result exists
 Returns : Bio::Pedigree::ResultI object or null
 Args    : name of the result

=cut

sub get_Result{
    $_[0]->_abstractDeath;
}

=head2 num_of_results

 Title   : num_of_results
 Usage   : my $count = $person->num_results;
 Function: returns the count of the number of Results for a person
 Returns : integer
 Args    : none

=cut

sub num_of_results {
    $_[0]->_abstractDeath;
}

=head2 Extra Person Fields

These fields can be calculated for a group but need not be defined
initially for a person unless already known.

=head2 patsibid

 Title   : patsibid
 Usage   : my $fid = $person->patsibid;
 Function: Get/Set the patsib id for a person
 Returns : patsib id for a person
 Args    : (optional) patsib id to set for a person

=cut

sub patsibid{
    $_[0]->_abstractDeath
}

=head2 matsibid

 Title   : matsibid
 Usage   : my $fid = $person->matsibid;
 Function: Get/Set the matsib id for a person
 Returns : matsib id for a person
 Args    : (optional) matsib id to set for a person

=cut

sub matsibid{
    $_[0]->_abstractDeath
}


=head2 childid

 Title   : childid
 Usage   : my $fid = $person->childid;
 Function: Get/Set the child id for a person
 Returns : child id for a person
 Args    : (optional) child id to set for a person

=cut

sub childid{
    $_[0]->_abstractDeath
}

1;
