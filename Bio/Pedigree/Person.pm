
#
# BioPerl module for Bio::Pedigree::Person
#
# Cared for by Jason Stajich <jason@bioperl.org>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Pedigree::Person - An individual in a Family or Group

=head1 SYNOPSIS

  use Bio::Pedigree::Person;
  my $person = new Bio::Pedigree::Person(-person_id => $person_id,
                                         -display_id=> $id,
                                         -father_id => $father_id,
                                         -mother_id => $mother_id,
                                         -gender    => $gender);

  print "father id ", $person->father_id, "\n";
  print "mother id ", $person->mother_id, "\n";
  print "gender is ", $person->gender, "\n";  

  
=head1 DESCRIPTION

Represents an individual in a pedigree - stores the persons individual
id, pointers to their parents. Sibling pointers can be derived.  Also
stores their genotype information.

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


package Bio::Pedigree::Person;
use vars qw(@ISA %REQUIRED_FIELD);
use strict;

use Bio::Pedigree::PersonI;
use Bio::PopGen::Individual;

@ISA = qw(Bio::PopGen::Individual Bio::Pedigree::PersonI);
%REQUIRED_FIELD = ( 'person' => 1,
		    'father' => 1,
		    'mother' => 1,
		    'child'  => 0,
		    'patsib' => 0,
		    'matsib' => 0);

# explictly using father_id and mother_id instead of mother/father to 
# allow possibility of mother/father object references later on.

=head2 new

 Title   : new
 Usage   : my $person = new Bio::Pedigree::Person(-person_id  => $id,
						  -father_id  => $fid,
						  -mother_id  => $mid,
						  -gender     => $gender
						  -display_id => $displayid );
 Function: creates a new person
 Returns : Bio::Pedigree::Person object
 Args    : All fields are required unless specified as optional
            -person_id  => id for the person (within this family)
                           This is only unique within a family and is typically
                           the order this person occupies in the family file.
            -gender     => ['M','F', 'U'] or ['1', '2', '0' ] 
            -display_id => (optional) the display id for this person (label) 
                          useful for internal coding schemes, e.g. '1001' 
                          This will be the same as person_id unless explictly
                          set.
            -proband    => (optional) boolean if person is proband
            -genotypes  => (optional) array ref of results to initialize this
                          person with.

              ANY of the XX_id or XX can be used,
              father,mother OR father_id,mother_id must be supplied
            -father     => for the father (numeric pointer essentially)
            -mother     => id for the mother (numeric pointer essentially)
            -child      => (optional) child object
            -patsib     => (optional) paternal sib object
            -matsib     => (optional) maternal sib object

               OR

            -father_id  => id for the father (numeric pointer essentially)
            -mother_id  => id for the mother (numeric pointer essentially)
            -child_id   => (optional) child pointer id
            -patsib_id  => (optional) paternal sib pointer id
            -matsib_id  => (optional) maternal sib pointer id
    

=cut

sub new {
  my($class,@args) = @_;

  # the superclass will take care of the -genotypes and unique_id fields
  my $self = $class->SUPER::new(@args);

  # initialize some containers
  $self->{'_results'} = {}; # results are hashed by name
  # parse the arguments
  my (%ids,%rels, $personid,$gender, $displayid,$proband);
  
  ($personid, 
   $rels{'father'}, $ids{'father'}, 
   $rels{'mother'}, $ids{'mother'}, 
   $rels{'child'},  $ids{'child'},
   $rels{'patsib'}, $ids{'patsib'},
   $rels{'matsib'}, $ids{'matsib'},
   $gender, $displayid,
   $proband) = $self->_rearrange([qw(PERSON_ID 
				     FATHER FATHER_ID 
				     MOTHER MOTHER_ID 
				     CHILD  CHILD_ID
				     MATSIB MATSIB_ID
				     PATSIB PATSIB_ID
				     GENDER 
				     DISPLAY_ID 
				     PROBAND
				     )], @args);
  
  
  if( ! defined $personid ) {
      $self->throw("Must specify a personid");
  } else { $self->person_id($personid) }
  
  foreach my $rel ( qw(father mother child patsib matsib ) ) {
      if( $rels{$rel} ) { 
	  my $pobj = $rels{$rel};
	  if( ! ref($pobj) ||
	      ! $pobj->isa('Bio::Pedigree::PersonI') ) {
	      $self->throw("Must supply a valid Person object or an individual id when initializing the $rel field for a $class, got a $pobj");
	  } elsif( defined $ids{$rel}  && $pobj->person_id ne $ids{$rel}) {
	      $self->throw("You suppliced a $rel\_id and a $rel obj when initializing $class and the id for the $rel object (".$pobj->person_id.") does not match $ids{$rel}");
	  }
	  $self->relative($pobj);
      } elsif( defined $ids{$rel} ) {
	  $self->relative_id($rel,$ids{$rel});
      } else {
	  # relative ids will default to 0 
	  $self->relative_id($rel, 0);
      } 
  }

  if( ! defined $gender ) {
      $self->throw("Must specify a gender when initializing a $class");
  } else { $self->gender($gender) }


  defined $displayid && $self->display_id($displayid);
  $self->proband($proband) if defined $proband;  
  return $self;
}


=head2 person_id

 Title   : person_id
 Usage   : my $person = $person->person_id;
 Function: Get/Set the id for a person
 Returns : id for a person
 Args    : (optional) id to set for a person

=cut

sub person_id{
    my ($self,$value) = @_;
    if( defined $value ) {
	$self->{'_person_id'} = $value;
    }
    return $self->{'_person_id'};
}

=head2 father_id

 Title   : father_id
 Usage   : my $fid = $person->father_id;
 Function: Get/Set the father id for a person 
 Returns : father id for a person
 Args    : (optional) father id to set for a person

=cut

sub father_id{
    shift->relative_id('father', @_);
}

=head2 father

 Title   : father
 Usage   : $obj->father($newval)
 Function: Get/Set the father object reference (for caching)
 Returns : value of father
 Args    : newvalue (optional)


=cut

# for caching the object once it has been set

sub father{
    shift->relative('father', @_);
}

=head2 mother_id

 Title   : mother_id
 Usage   : my $fid = $person->mother_id;
 Function: Get/Set the mother id for a person
 Returns : mother id for a person
 Args    : (optional) mother id to set for a person

=cut

sub mother_id{
    shift->relative_id('mother', @_);
}

=head2 mother

 Title   : mother
 Usage   : $obj->mother($newval)
 Function: Get/Set the mother object reference (for caching)
 Returns : value of mother
 Args    : newvalue (optional)


=cut

sub mother{
    shift->relative('mother', @_);
}

=head2 gender

 Title   : gender
 Usage   : my $gender = $person->gender;
 Function: Get/Set gender for person
 Returns : gender ("M","F", "U")
 Args    : (optional) gender code to store 

=cut

sub gender{
    my ($self,$value) = @_;
    if( defined $value ) {
	$value =~ tr/[012]/[UMF]/;
	if( $value !~ /[UMF]/ ) {
	    $self->warn("gender value $value is not known");
	    $value = 'U';
	}
	$self->{'_gender'} = $value;
    }
    return $self->{'_gender'};
}

=head2 display_id

 Title   : display_id
 Usage   : my $dispylid = $person->display_id
 Function: Returns the display id for a person which is more informative
            than the personid (ie personid is typically the order in the family
            while display_id might be the id code for individual like : 1001),
            or perhaps a string.  It is expected to be unique within a 
            family/group.
 Returns : string representing displayid
 Args    : (optional) string to set displayid to

=cut

sub display_id{
    my ($self,$value) = @_;
    if( defined $value || ! defined $self->{'_display_id'} ) {	
	$value = $self->person_id unless defined $value;
	$self->{'_display_id'} = $value;
    }
    return $self->{'_display_id'};
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
    shift->relative_id('patsib',@_);
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
    shift->relative_id('matsib',@_);
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
    shift->relative_id('child',@_);
}



=head2 patsib

 Title   : patsib
 Usage   : my $patsibid = $person->patsib_id;
 Function: Get/Set the patsib obj for a person
           1st patsib id is a pointer to the next paternal sibling.
           In the case of full sibs, matsib and patsib will be identical
           but in half sib situations matsib and patsib will point to
           differently chained objects.
           This can either be set a object creation time
           (parsing from file) or derived by walking down 
           the pedigree.
 Returns : patsib for a person
 Args    : (optional) patsib to set for a person

=cut

sub patsib{
    shift->relative('patsib',@_);
}

=head2 matsib

 Title   : matsib
 Usage   : my $fid = $person->matsib;
 Function: Get/Set the 1st matsib for a person
           1st matsib id is a pointer to the next maternal sibling.
           In the case of full sibs, matsib and patsib will be identical
           but in half sib situations matsib and patsib will point to
           differently chained objects.
           This can either be set a object creation time
           (parsing from file) or derived by walking down 
           the pedigree.
           This can either be set a object creation time
           (parsing from file) or derived by walking down 
 Returns : matsib for a person
 Args    : (optional) matsib to set for a person

=cut

sub matsib{
    shift->relative('matsib',@_);
}


=head2 child

 Title   : child
 Usage   : my $fid = $person->child;
 Function: Get/Set the 1st child for a person
           1st child id is a pointer to the child which will have
           a link to any other siblings via matsib or patsib ids 
           depending on whether or not the they share the same 
           set of parents.
           This can either be set a object creation time
           (parsing from file) or derived by walking down 
           the pedigree.
 Returns : child for a person
 Args    : (optional) child id to set for a person

=cut

sub child{
    shift->relative('child',@_);
}

=head2 proband

 Title   : proband
 Usage   : $obj->proband($newval)
 Function: Get/Set the proband status
 Returns : value of proband
 Args    : newvalue (optional)


=cut

sub proband{
    my $self = shift;
    return $self->{'_proband'} = shift if @_;
    return $self->{'_proband'};
}

sub get_last_sib {
    my ($self,$parent) = @_;
    
    if( $parent->person_id == $self->father_id ) {
	if( $self->patsib ) {
	    return $self->patsib->get_last_sib($parent);
	} else { 
	    return $self;
	}
    } elsif( $parent->person_id == $self->mother_id ) {
	if( $self->matsib ) {
	    return $self->matsib->get_last_sib($parent);
	} else { 
	    return $self;
	}
    } else { return undef }
}


=head2 relative_id

 Title   : relative_id
 Usage   : my $id = $person->relative_id('mother');
 Function: Simple programatic way to get access to 
           father/mother/child/patsib/matsib fields
 Returns : Unique identifier of the relative
 Args    : relationship name (one of 'mother', 'father', 'child', 
			             'patsib', 'matsib')
           (optional) value to store for id


=cut


# todo at some point - verify that relative and relative id
# can't get out of sync

sub relative_id{
   my $self = shift;
   # no forced validation of 'relationship'
   my $rel  = shift;
   return unless defined $rel;
   $rel = lc($rel);
   if( @_) {
       return $self->{"_$rel\_id"} = shift;
   }
   return $self->{"_$rel\_id"};
}


=head2 relative

 Title   : relative
 Usage   : my $id = $person->relative_id('mother');
 Function: Simple programatic way to get access to 
           father/mother/child/patsib/matsib objects
 Returns : Reference to relative object
 Args    : relationship name (one of 'mother', 'father', 'child', 
			             'patsib', 'matsib')
           (optional) value to store for object


=cut

sub relative {
    my $self = shift;
    my $rel = shift;

    # no forced validation of 'relationship'

    return unless defined $rel;
    # force lowercase
    $rel = lc($rel);

    if( @_ ) {
	my $obj = shift;
	if( ref($obj) &&
	    $obj->isa('Bio::Pedigree::PersonI') ) {
	    $self->{"_$rel"} = $obj;
	    $self->{"_$rel\_id"} = $obj->person_id;
	} else { 
	    $self->throw("Need to provide a valid Bio::Pedigree::PersonI to $rel") }
    }
    return $self->{'_$rel'};
}


=head2 Inherited from Bio::PopGen::Individual


=head2 num_of_results

 Title   : num_of_results
 Usage   : my $count = $person->num_results;
 Function: returns the count of the number of Results for a person
 Returns : integer
 Args    : none

=cut

=head2 add_Genotype

 Title   : add_Genotype
 Usage   : $individual->add_Genotype
 Function: add a genotype value
 Returns : count of the number of genotypes associated with this individual
 Args    : $genotype - Bio::PopGen::GenotypeI object containing the alleles for
                       a marker


=cut

=head2 reset_Genotypes

 Title   : reset_Genotypes
 Usage   : $individual->reset_Genotypes;
 Function: Reset the genotypes stored for this individual
 Returns : none
 Args    : none


=cut

=head2 remove_Genotype

 Title   : remove_Genotype
 Usage   : $individual->remove_Genotype(@names)
 Function: Removes the genotypes for the requested markers
 Returns : none
 Args    : Names of markers 


=cut

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
