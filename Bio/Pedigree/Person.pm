
#
# BioPerl module for Bio::Pedigree::Person
#
# Cared for by Jason Stajich <jason@chg.mc.duke.edu>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Pedigree::Person - An individual in a Family or Group

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


package Bio::Pedigree::Person;
use vars qw(@ISA);
use strict;
use Bio::Pedigree::PersonI;
use Tie::IxHash;
use Bio::Root::Root;

@ISA = qw(Bio::Root::Root Bio::Pedigree::PersonI);


# explictly using fatherid and motherid instead of mother/father to 
# allow possibility of mother/father object references later on.

=head2 new

 Title   : new
 Usage   : my $person = new Bio::Pedigree::Person(-pid       => $pid,
						  -personid  => $id,
						  -fatherid  => $fid,
						  -motherid  => $mid,
						  -gender    => $gender
						  -displayid => $display );
 Function: creates a new person
 Returns : Bio::Pedigree::Person object
 Args    : All fields are required unless specified as optional
            -pid       => (optional) internal id (usually starting with 1)
            -personid  => id for the person (within this family)
                         This is only unique within a family and is typically
                         the order this person occupies in the family file.
            -father    => id for the father (numeric pointer essentially)
            -mother    => id for the mother (numeric pointer essentially)
            -gender    => ['M','F', 'U'] or ['1', '2', '0' ]
            -displayid => (optional) the display id for this person (label) 
                          useful for internal coding schemes, e.g. '1001' 
                          This will be the same as personid unless explictly
                          set.
            -childid   => (optional) child pointer id
            -patsib    => (optional) paternal sib pointer id
            -matsib    => (optional) maternal sib pointer id    
            -proband   => (optional) boolean if person is proband
            -results   => (optional) array ref of results to initialize this
                          person with.

=cut

sub new {
  my($class,@args) = @_;
  my $self = $class->SUPER::new(@args);

  # initialize some containers
  $self->{'_results'} = {}; # results are hashed by name
  tie %{$self->{'_results'}}, "Tie::IxHash"; 
  # parse the arguments
  my ($personid, $fatherid, $motherid, $gender, 
      $displayid, $child,$patsib,$matsib, $proband,
      $results, $pid ) = $self->_rearrange([qw(PERSONID FATHER 
					       MOTHER GENDER 
					       DISPLAYID CHILD 
					       PATSIB MATSIB PROBAND
					       RESULTS PID)], @args);
  if( ! defined $personid ) {
      $self->throw("Must specify a personid");
  } elsif( ! defined $fatherid ) {
      $self->throw("Must specify a fatherid");
  } elsif( ! defined $motherid ) {
      $self->throw("Must specify a motherid");
  } elsif( ! defined $gender ) {
      $self->throw("Must specify a gender");
  } 

  $self->personid($personid);
  $self->fatherid($fatherid);
  $self->motherid($motherid);
  $self->gender($gender);
  # optional fields
  defined $displayid && $self->displayid($displayid);
  defined $child     && $self->childid($child);
  defined $patsib    && $self->patsibid($patsib);
  defined $matsib    && $self->matsibid($matsib);
  defined $proband   && $self->proband($proband);
  defined $pid       && $self->pid($pid);
  if( defined $results ) {
      if( ref($results) !~ /array/i ) {
	  $self->warn("Trying to initialize a person with a results list ($results) which is not an array ref"); 
      } else { 
	  foreach my $result ( @$results ) {
	      $self->add_Result($result,1);
	  }
      }
  }
  return $self;
}

=head2 personid

 Title   : personid
 Usage   : my $pid = $person->personid;
 Function: Get/Set the id for a person
 Returns : id for a person
 Args    : (optional) id to set for a person

=cut

sub personid{
    my ($self,$value) = @_;
    if( defined $value ) {
	$self->{'_personid'} = $value;
    }
    return $self->{'_personid'};
}

=head2 fatherid

 Title   : fatherid
 Usage   : my $fid = $person->fatherid;
 Function: Get/Set the father id for a person
 Returns : father id for a person
 Args    : (optional) father id to set for a person

=cut

sub fatherid{
    my ($self,$value) = @_;
    if( defined $value ) {
	$self->{'_fatherid'} = $value;
    }
    return $self->{'_fatherid'};
}

=head2 father

 Title   : father
 Usage   : $obj->father($newval)
 Function: 
 Returns : value of father
 Args    : newvalue (optional)


=cut

sub father{
   my ($obj,$value) = @_;
   if( defined $value) {
      $obj->{'father'} = $value;
    }
    return $obj->{'father'};

}

=head2 motherid

 Title   : motherid
 Usage   : my $fid = $person->motherid;
 Function: Get/Set the mother id for a person
 Returns : mother id for a person
 Args    : (optional) mother id to set for a person

=cut

sub motherid{
    my ($self,$value) = @_;
    if( defined $value ) {
	$self->{'_motherid'} = $value;
    }
    return $self->{'_motherid'};
}

=head2 mother

 Title   : mother
 Usage   : $obj->mother($newval)
 Function: 
 Returns : value of mother
 Args    : newvalue (optional)


=cut

sub mother{
   my ($obj,$value) = @_;
   if( defined $value) {
      $obj->{'mother'} = $value;
    }
    return $obj->{'mother'};

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
    my ($self,$value) = @_;
    if( defined $value || ! defined $self->{'_displayid'} ) {	
	$value = $self->personid unless defined $value;
	$self->{'_displayid'} = $value;
    }
    return $self->{'_displayid'};
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
    my ($self, $result,$overwrite) = @_;
    if( ! $result || !ref($result) || 
	! $result->isa('Bio::Pedigree::ResultI') ) {
	$self->warn("Trying to add a result $result which is not a Bio::Pedigree::ResultI");
	return 0;
    }
    my $name = uc $result->name;
    if( ! $overwrite && defined $self->{'_results'}->{$name} ) {
	$self->warn("Trying to overwrite an already added result for Marker $name and overwrite is turned off.  Will not replace the existing one");
	return 0;
    } else { 
	$self->{'_results'}->{$name} = $result;
    }
    return keys %{$self->{'_results'}};
}

=head2 remove_Result

 Title   : remove_Result
 Usage   : $person->remove_Result($markername)
 Function: removes a result based on its name
 Returns : boolean if succeeded
 Args    : marker name to remove

=cut

sub remove_Result{
    my ($self,$name) = @_;
    $name = uc $name;
    return 0 if( ! defined $name || ! defined $self->{'_results'}->{$name});
    delete $self->{'_results'}->{$name};
    return 1;
}

=head2 each_Result

 Title   : each_Result
 Usage   : my @results = $person->each_Result;
 Function: returns the list of Results for a person
 Returns : Either the name of the markers or the list of Result objects
 Args    : (optional) 'name' to just get the list of variations
                      that are contained for this person.

=cut

sub each_Result{
    my ($self, $name) = @_;
    my (@vals,$bool,$val);
    $bool = ( $name && $name eq 'name' );
    while( my($name,$result) = each %{$self->{'_results'}} ) {
	push @vals, ( $bool ) ? $name : $result;
    }
    return @vals;
}

=head2 get_Result

 Title   : get_Result
 Usage   : my $result = $person->get_Result($name);
 Function: Get a specific result for a person - or undef if not result exists
 Returns : Bio::Pedigree::ResultI object or null
 Args    : name of the result

=cut

sub get_Result{
    my($self,$name) = @_;
    return $self->{'_results'}->{$name};
}

=head2 num_of_results

 Title   : num_of_results
 Usage   : my $count = $person->num_results;
 Function: returns the count of the number of Results for a person
 Returns : integer
 Args    : none

=cut

sub num_of_results {
    my($self) = @_;
    return scalar keys %{$self->{'_results'}};
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
    my ($self, $id) = @_;
    if(defined $id) {
	$self->{'_patsibid'} = $id;
    }
    return $self->{'_patsibid'};
}

=head2 patsib

 Title   : patsib
 Usage   : $obj->patsib($newval)
 Function: 
 Returns : value of patsib
 Args    : newvalue (optional)


=cut

sub patsib{
   my ($obj,$value) = @_;
   if( defined $value) {
      $obj->{'patsib'} = $value;
    }
    return $obj->{'patsib'};
}

=head2 matsibid

 Title   : matsibid
 Usage   : my $fid = $person->matsibid;
 Function: Get/Set the matsib id for a person
 Returns : matsib id for a person
 Args    : (optional) matsib id to set for a person

=cut

sub matsibid{
    my ($self, $id) = @_;
    if(defined $id) {
	$self->{'_matsibid'} = $id;
    }
    return $self->{'_matsibid'};
}

=head2 matsib

 Title   : matsib
 Usage   : $obj->matsib($newval)
 Function: 
 Returns : value of matsib
 Args    : newvalue (optional)


=cut

sub matsib{
   my ($obj,$value) = @_;
   if( defined $value) {
      $obj->{'matsib'} = $value;
    }
    return $obj->{'matsib'};
}

=head2 childid

 Title   : childid
 Usage   : my $fid = $person->childid;
 Function: Get/Set the child id for a person
 Returns : child id for a person
 Args    : (optional) child id to set for a person

=cut

sub childid{
    my ($self, $id) = @_;
    if(defined $id) {
	$self->{'_childid'} = $id;
    }
    return $self->{'_childid'};
}

=head2 child

 Title   : child
 Usage   : $obj->child($newval)
 Function: 
 Returns : value of child
 Args    : newvalue (optional)


=cut

sub child{
   my ($obj,$value) = @_;
   if( defined $value) {
      $obj->{'child'} = $value;
    }
    return $obj->{'child'};
}

=head2 pid

 Title   : pid
 Usage   : $obj->pid($newval)
 Function: 
 Example : 
 Returns : value of pid
 Args    : newvalue (optional)


=cut

sub pid{
   my ($obj,$value) = @_;
   if( defined $value) {
      $obj->{'_pid'} = $value;
    }
    return $obj->{'_pid'};
}

=head2 proband

 Title   : proband
 Usage   : $obj->proband($newval)
 Function: 
 Returns : value of proband
 Args    : newvalue (optional)


=cut

sub proband{
   my ($obj,$value) = @_;
   if( defined $value) {
      $obj->{'_proband'} = $value;
    }
    return $obj->{'_proband'};

}

1;
