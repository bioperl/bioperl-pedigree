#$Id$
#
# BioPerl module for Bio::Pedigree::Group
#
# Cared for by Jason Stajich <jason@bioperl.org>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Pedigree::Group - An object for managing lists of people who are related in some way

=head1 SYNOPSIS

    use Bio::Pedigree::Group;
    use Bio::Pedigree::Person;
    my $group = new Bio::Pedgigree::Group( -groupid => 1,
					   -center  => 'DUK',
					   -desc    => 'example family');
    my $person = new Bio::Pedigree::Person( -personid => 1,
					    -gender   => 'M',
					    -father   => 0,
					    -mother   => 0 );
    $group->add_Person($person);

    foreach my $p ( $group->each_Person ) {
	print "person id is ", $p->personid, "\n";
    }

=head1 DESCRIPTION

This object encapsulates the concept of a Group or Family in Pedigree.
A family is a collection of related individuals, a group is a
collection of unrelated individuals.  The only need for Groups is when
calculating allele frequencies and related population statistics.

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


package Bio::Pedigree::Group;
use vars qw(@ISA $DEFAULTTYPE);
use strict;

use Bio::Pedigree::GroupI;
use Tie::IxHash;
use Bio::Root::Root;

@ISA = qw(Bio::Root::Root Bio::Pedigree::GroupI);

BEGIN { 
    $DEFAULTTYPE = 'FAMILY';
}

=head2 new

 Title   : new
 Usage   : my $group = new Bio::Pedigree::Group( -groupid => 1,
						 -center  => 'DUK',
						 -desc    => 'example family',
						 -people  => \@people);
 Function: creates a new group
 Returns : Bio::Pedigree::Group object
 Args    : All fields are required unless specified as optional
            -groupid  => group id for the group 
                        (typically assigned by a research center so 
			 groupid is not unique, however center + groupid 
			 should be unique!)
            -center   => research center responsible for this family
            -desc     => (optional) description
            -type     => 'FAMILY' or 'GROUP' - 'FAMILY' by default
            -people   => (optional) initial people arrayref to initialize
                         object with

=cut

sub new {
  my($class,@args) = @_;

  my $self = $class->SUPER::new(@args);
  
  $self->{'_people'} = {};
  tie %{$self->{'_people'}}, "Tie::IxHash";

  my ($groupid, $center, $desc, $type,
      $people) = $self->_rearrange([ qw(GROUPID CENTER DESC TYPE
				      PEOPLE)] , @args);
  if( !defined $groupid || ! defined $center ) {
      $self->throw("Must defined groupid and center to initialize a $class object");
  }
  $self->groupid($groupid);
  $self->center ($center);
  $self->type($type || $DEFAULTTYPE);
  $desc && $self->description($desc);
  if( defined $people ) {
      if( ref($people) !~ /array/i ) {
	  $self->warn("Trying to initialize a the people list with $people which is not an ArrayRef");
      } else { 
	  foreach my $person ( @$people ) {
	      $self->add_Person($person,1);
	  }
      }
  }
  return $self;
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
    my ($self, $person,$overwrite) = @_;
    if( ! $person || !ref($person) || 
	! $person->isa('Bio::Pedigree::PersonI') ) {
	$self->warn("Trying to add a person $person which is not a Bio::Pedigree::PersonI");
	return 0;
    }
    my $personid = $person->personid;
    if( ! defined  $personid ) {
	$self->throw("No person id, assigning a pid for them");	
    } elsif( $personid < 0 ) {
	$self->throw("Invalid person id!")
    }    
    if( ! $overwrite && defined $self->{'_people'}->{$personid} ) {
	$self->warn("Trying to overwrite already seen $personid with a new person and overwrite is turned off.  Will not replace the existing value");
	return 0;    
    }
    if( !defined $person->pid ) { $person->pid($self->num_of_people + 1); }
    $self->{'_people'}->{$personid} = $person;
    return $self->num_of_people;
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

 Args    : id of person to remove or Bio::Pedigree::PersonI object

=cut

sub remove_Person{
    my ($self, $pid) = @_;
    if( ref($pid) && $pid->isa('Bio::Pedigree::PersonI') ) {
	$pid = $pid->personid;
    }

    return 0 if( ! defined $pid || !defined $self->{'_people'}->{$pid} );

    delete $self->{'_people'}->{$pid};
    return 1;
}

=head2 num_of_people

 Title   : num_of_people
 Usage   : my $count = $group->num_of_people;
 Function: returns the number of people currently in a group
 Returns : integer
 Args    : none

=cut

sub num_of_people{
    my ($self) = @_;
    return scalar values %{ $self->{'_people'} };
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
    my ($self,$id) = @_;
    return ( $id && $id eq 'id' ) ? keys %{ $self->{'_people'} } : values %{ $self->{'_people'} };
}

=head2 get_Person

 Title   : get_Person
 Usage   : my $p = $group->get_Person($id);
 Function: returns the person object based on a specific person id
 Returns : Bio::Pedigree::PersonI object or undef if that id does not exist
 Args    : person id for person to retrieve

=cut

sub get_Person{
    my ($self, $id) = @_;
    return undef if( ! defined $id || $id < 0 );
    return $self->{'_people'}->{$id};
}

=head2 remove_Marker

 Title   : remove_Marker
 Usage   : $group->remove_marker($name);
 Function: For a given Marker name, remove its alleles from all
           individuals contained within the group
 Returns : boolean on success  - false if marker does not exist for anyone
                                 true if at least one person had the marker
 Args    : marker name or Bio::Pedigree::MarkerI object

=cut

sub remove_Marker{
    my ($self, $name) = @_;
    if( ref($name) && $name->isa('Bio::Pedigree::MarkerI') ) {
	$name = $name->name;
    }
    my $foundone = 0;
    foreach my $person ( $self->each_Person ) {
	if( $person->remove_Result($name) ) { $foundone = 1; }
    }
    return $foundone;
}

=head2 center

 Title   : center
 Usage   : my $center = $group->center()
 Function: Get/Set research center name for this group
 Returns : string
 Args    : string (optional) string to set the center name to

=cut

sub center{
    my ($self,$value) = @_;
    if( defined $value ) {
	$self->{'_center'} = $value;
    }
    return $self->{'_center'};
}

=head2 groupid

 Title   : groupid
 Usage   : my $id = $group->groupid()
 Function: Get/Set Group ID number for this group
 Returns : integer
 Args    : integer (optional) integer to set the group id to
 Note    : We try and be explicit about what type of id we have here
           to avoid future confusion with databaseids.

=cut

sub groupid {
    my ($self,$value) = @_;
    if( defined $value ) {
	$self->{'_groupid'} = $value;
    }
    return $self->{'_groupid'};
}

=head2 description

 Title   : description
 Usage   : my $description = $group->description; #or
 Function: Get/Set Group description value
 Returns : string 
 Args    : string (optional) string to set the group description to

=cut

sub description {
    my ($self,$value) = @_;
    if( defined $value ) {
	$self->{'_description'} = $value;
    }
    return $self->{'_description'} || '';
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
    my ($self,$value) = @_;
    if( defined $value ) {
	$self->{'_type'} = $value;
    }
    return $self->{'_type'};
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
   my ($self,$warnings) = @_;
   my $warntype = sub { print $_[0], "\n"};
   if( defined $warnings && $warnings ne '' ) {
       if( $warnings =~ /warnonerror/i ) { 
	   print "assigning warntype\n";
	   $warntype = sub { $self->warn($_[0]) };
       } elsif ( $warnings =~ /failonerror/i ) {
	   $warntype = sub { $self->throw($_[0]) };
       } else {
	   $self->warn("Unrecognized warning flag - $warnings.\nWill not notify on errors");  
       }
   }
   return $self->_helper_calculate_relationships
       ([sort {$a<=>$b} $self->each_Person('id')], 
	$warntype);
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
    my ($self) = @_;
    # even if this is redundant - we want to be sure that everything is 
    # up to date wrt child pointers
#    $self->calculate_relationships();
    
    # find all the people who have no father or mother in the pedigree
    my %orphans;  # these will be indexed by their CHILD pointers
    foreach my $person ( $self->each_Person ){
	if( $person->fatherid == 0 ) {
	    if( $person->motherid != 0 ) {
		$self->throw("Person ". $person->personid. " has is malformed, they have a mother pointer of ". $person->motherid. " while their fatherid is 0");
	    }
	    push @{$orphans{$person->childid}}, $person, 
	}
    }
    
    my @founders;
    while( my($child,$parents) = each %orphans ) {
	if( @$parents > 2 ) {
	    $self->throw("Sanity Check failed - a child -- $child -- has more than 2 parents!\nParent Ids are: ". join(',', map { $_->personid } @$parents ));
	} elsif( @$parents == 1 ) { next; }
	$parents = [ sort { $a->gender eq 'M' ? 1 : 0 } @$parents]; 
	if( $parents->[0]->gender eq $parents->[1]->gender ) {
	    $self->warn("Parents gender is not opposite!\n".
			sprintf("Gender was for %s: %s and for %s: %s",
				$parents->[0]->personid, 
				$parents->[0]->gender,
				$parents->[1]->personid, 
				$parents->[1]->gender));
	    next;
	}
	push @founders, $parents;
    }
    return @founders;
}


# helper method - not public

sub _helper_calculate_relationships {
    my ($group,$ids, $warntype) = @_;
    return 0 if ( @$ids == 0);
    my @ids = @$ids;
    my $id = shift @ids;
    my $person = $group->get_Person($id);
    my $count = 0;
    return 0 if( ! $person );
    if( $person->fatherid ) {
	if( ! $person->motherid ) { $group->throw("MotherID does not exist for individual $id, which does have a fatherid ".$person->fatherid); }
	my $father = $group->get_Person($person->fatherid);
	my $mother = $group->get_Person($person->motherid);	
	if( $father->gender ne 'M' ) {
	    $warntype->("Expected gender to be 'M' for ". $person->fatherid);
	    $father->gender('M');			
	}
	if( $mother->gender ne 'F' ) {
	    $warntype->("Expected gender to be 'F' for ". $person->motherid);
	    $mother->gender('F');
	}
	$person->father($father);
	$person->mother($mother);
	$count += $group->_add_child($father, $id);
	$count += $group->_add_child($mother, $id);	
     }
    # this will try and hit every node - as it will go through the whole 
    # list of individuals
    # this could be computationally expensive so we may need to
    # improve the algorithm
    return $count + $group->_helper_calculate_relationships(\@ids,$warntype);
}

# helper method for updating relationships

sub _add_child {
    my ($group,$parent,$child) = @_;
    return 0 unless $child;
    my $childobj = $group->get_Person($child);
    $group->throw("Could not find person with id $child") unless defined $childobj;
    if( ! $parent->childid ) {
	$parent->childid($child);
	$parent->child($childobj);
	return 1;
    } else {
#	return 0 if( $parent->childid == $child);
	my $firstchild = $group->get_Person($parent->childid);
	$parent->child($firstchild);
	if( ! defined $firstchild ) {
	    $group->throw("Person ". $parent->personid. 
			  " has reference to 1st child as ". 
			  $parent->childid . " which does not exist in this group");
	}
	return $group->_add_sib($firstchild, $child, 
				$parent->gender eq 'M');
    }
}

# helper method for updating relationships

sub _add_sib {
    my ($group,$sib,$id, $paternalsib) = @_;
    return 0 if( ! defined $sib || $sib->personid == $id );
    my $sibname = ( $paternalsib ) ? 'patsibid' : 'matsibid';
    my $sibobj = ( $paternalsib ) ? 'patsib' : 'matsib';
    if( ! $sib->$sibname() ) {
	$sib->$sibname($id);
	my $personref = $group->get_Person($id);
	$sib->$sibobj($personref);
	return 1;
    } else {
	my $firstsib = $group->get_Person($sib->$sibname());
	$sib->$sibobj($firstsib);
	return 0 if ( $sib->$sibname() == $id);
	
	if( ! defined $firstsib) {
	    $group->throw("Person ". $sib->personid . 
			  "has a reference to 1st $sibname as ".
			  $sib->$sibname() . " which does not exist in this group");
	}	
	return $group->_add_sib($firstsib, $id, $paternalsib);	
    }
}
1;
