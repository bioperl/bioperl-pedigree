# $Id$
#
# BioPerl module for Bio::Pedigree::PersonI
#
# Cared for by Jason Stajich <jason@bioperl.org>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Pedigree::PersonI - Interface defining the methods for a Person in a Pedigree

=head1 SYNOPSIS

    # get a PersonI object somehow
    print "id is ", $person->person_id, " father id is ", $person->father_id, 
          " motherid is ", $person->mother_id, "\n";

=head1 DESCRIPTION

This interface defines the minimum methods required to have a Person
in a Pedigree.  A PersonI is an extension of an Bio::PopGen::IndividualI 
which can be used for more generic population genetic questions.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to
the Bioperl mailing list.  Your participation is much appreciated.

  bioperl-l@bioperl.org            - General discussion
http://bioperl.org/wiki/Mailing_lists  - About the mailing lists

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


package Bio::Pedigree::PersonI;
use vars qw(@ISA);
use strict;

use Bio::PopGen::IndividualI;

@ISA = qw(Bio::PopGen::IndividualI);

=head2 person_id

 Title   : person_id
 Usage   : my $pid = $person->person_id;
 Function: Get/Set the individual id for a person
           This should be unique in a pedigree and is typically
           assigned when the Object is built.
 Returns : id for a person
 Args    : (optional) id to set for a person

=cut

sub person_id{
    shift->throw_not_implemented();
}

=head2 father_id

 Title   : father_id
 Usage   : my $fid = $person->father_id;
 Function: Get/Set the father id for a person (which should be
           the same as the person_id for the father object)
 Returns : father id for a person
 Args    : (optional) father id to set for a person

=cut

sub father_id{
    shift->throw_not_implemented();
}

=head2 mother_id

 Title   : mother_id
 Usage   : my $fid = $person->mother_id;
 Function: Get/Set the mother id for a person (which should be
           the same as the person_id for the mother objec)
 Returns : mother id for a person
 Args    : (optional) mother id to set for a person

=cut

sub mother_id{
    shift->throw_not_implemented();
}

=head2 gender

 Title   : gender
 Usage   : my $gender = $person->gender;
 Function: Get/Set gender for person
 Returns : gender ("M","F", "U") 
 Args    : (optional) gender code to store 

=cut

sub gender{
    shift->throw_not_implemented();
}

=head2 display_id

 Title   : display_id
 Usage   : my $dispylid = $person->display_id
 Function: Returns the display id for a person which is more informative
           than the person_id (display_id may be something like 1001),
           or perhaps a string.  Like person_id it should be unique within a 
           pedigree or group.
 Returns : string representing display_id
 Args    : (optional) string to set display_id to

=cut

sub display_id{
    shift->throw_not_implemented();
}

=head2 num_of_results

 Title   : num_of_results
 Usage   : my $count = $person->num_results;
 Function: returns the count of the number of Results for a person
 Returns : integer
 Args    : none

=cut

sub num_of_results {
    shift->throw_not_implemented();
}

=head2 Extra Person Fields

These fields can be calculated for a group/pedigree but need not be
defined initially for a person unless known at object creation time
(db load or parse time). .

=head2 patsib_id

 Title   : patsib_id
 Usage   : my $fid = $person->patsib_id;
 Function: Get/Set the patsib id for a person
           1st patsib id is a pointer to the next paternal sibling.
           In the case of full sibs, matsib and patsib will be identical
           but in half sib situations matsib and patsib will point to
           differently chained objects.
           This can either be set a object creation time
           (parsing from file) or derived by walking down 
           the pedigree.
 Returns : patsib id for a person
 Args    : (optional) patsib id to set for a person

=cut

sub patsib_id{
    shift->throw_not_implemented();
}

=head2 matsib_id

 Title   : matsib_id
 Usage   : my $fid = $person->matsib_id;
 Function: Get/Set the 1st matsib id for a person
           1st matsib id is a pointer to the next maternal sibling.
           In the case of full sibs, matsib and patsib will be identical
           but in half sib situations matsib and patsib will point to
           differently chained objects.
           This can either be set a object creation time
           (parsing from file) or derived by walking down 
           the pedigree.
           This can either be set a object creation time
           (parsing from file) or derived by walking down 
 Returns : matsib id for a person
 Args    : (optional) matsib id to set for a person

=cut

sub matsib_id{
    shift->throw_not_implemented();
}


=head2 child_id

 Title   : child_id
 Usage   : my $fid = $person->child_id;
 Function: Get/Set the 1st child id for a person
           1st child id is a pointer to the child which will have
           a link to any other siblings via matsib or patsib ids 
           depending on whether or not the they share the same 
           set of parents.
           This can either be set a object creation time
           (parsing from file) or derived by walking down 
           the pedigree.
 Returns : child id for a person
 Args    : (optional) child id to set for a person

=cut

sub child_id{
    shift->throw_not_implemented();
}

=head2 Inherited from Bio::PopGen::IndividualI

The methods inherit from Bio::PopGen::IndividualI

=head2 get_Genotypes

 Title   : get_Genotypes
 Usage   : my @genotypes = $ind->get_Genotypes(-marker => $markername);
 Function: Get the genotypes for an individual, based on a criteria
 Returns : Array of genotypes
 Args    : either none (return all genotypes) or 
           -marker => name of marker to return (exact match, case matters)


=cut

=head2 has_Marker

 Title   : has_Marker
 Usage   : if( $ind->has_Marker($name) ) {}
 Function: Boolean test to see if an Individual has a genotype 
           for a specific marker
 Returns : Boolean (true or false)
 Args    : String representing a marker name


=cut

=head2 get_marker_names

 Title   : get_marker_names
 Usage   : my @names = $individual->get_marker_names;
 Function: Returns the list of known marker names
 Returns : List of strings
 Args    : none


=cut



1;
