# $Id$
#
# BioPerl module for Bio::Pedigree:Pedigree
#
# Cared for by Jason Stajich <jason@chg.mc.duke.edu>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Pedigree::Pedigree - This is the toplevel object which contains references
to the Markers genotyped for a set of families, and the families for
which there are results.

=head1 SYNOPSIS

    use Bio::Pedigree::PedIO;
    # get a Bio::Pedigree object somehow (PedIO system typically)
    my $pedio = new Bio::Pedigree::PedIO(-format => 'xml');
    my $pedigree = $pedio->read_pedigree(-pedfile => 'pedigree_example.xml');

    print "date is ", $pedigree->date, "\n";
    print "comment is ", $pedigree->comment ,"\n";

    print "markers are :\n";
    foreach my $markername ( $pedigree->each_Marker('name') ) {
	print "$markername\n";
    }
    foreach my $group ( $pedigree->each_Group ) {
	print "group name is ", $group->center_groupid, "\n";
	foreach my $person ( $pedigree->each_Person ) {
	    print $person->personid, " ", $person->gender, "\n";
	}
    }


=head1 DESCRIPTION

This object is the toplevel object which contains all the Groups and
Marker objects that are part of a pedigree set.  More than one
Family/Group can be contained within a pedigree which may be counter
to the name 'PEDIGREE' which implies all the components within this
object are part of the same lineage.  In this implementation a
Pedigree is a container for the list of Markers (and their order) as
well as the list of Groups (or Families) which have individuals with
Marker genotypes.

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


package Bio::Pedigree::Pedigree;
use vars qw(@ISA);
use strict;

use Bio::Root::Root;
use Tie::IxHash;
use Bio::Pedigree::Group;
use Bio::Pedigree::Marker;
use POSIX;

@ISA = qw(Bio::Root::Root );

=head2 new

 Title   : new
 Usage   : my $pedigree = new Bio::Pedigree();
 Function: creates a new Pedigree object for storing Group and Marker 
           information
 Returns : Bio::Pedigree object
 Args    : All fields are required unless specified as optional
          -groups   => (optional) array ref of groups to initialize Pedigree 
                                  object with
          -markers  => (optional) array ref of markers to initialize Pedigree 
                                  object with

=cut

sub new {
  my($class,@args) = @_;

  my $self = $class->SUPER::new(@args);
  $self->{'_groups'} = {};
  $self->{'_markers'} = {};
  # allows elements to be retrieved in order they were inserted
  tie %{$self->{'_groups'}}, "Tie::IxHash";
  tie %{$self->{'_markers'}}, "Tie::IxHash";

  my ($groups, $markers, $date,$comment) = $self->_rearrange([qw(GROUPS 
								 MARKERS 
								 DATE 
								 COMMENT)], @args);
  if( defined $groups ) {
      if( ref($groups) !~ /array/i ) {
	  $self->throw("Trying to initialize Bio::Pedigree::Pedigree object with groups ($groups) which is not an array reference");
      } else { 
	  foreach my $group ( @$groups ) {
	      $self->add_Group($group);
	  }
      }
  }
  if( defined $markers ) {
      if( ref($markers) !~ /array/i ) {
	  $self->throw("Trying to initialize Bio::Pedigree object with markers ($markers) which is not an array reference");
      } else { 
	  foreach my $marker ( @$markers ) {
	      $self->add_Marker($marker);
	  }
      }
  }
  $date && $self->date($date);
  $comment && $self->comment($comment);
  return $self;
}

=head2 add_Group

 Title   : add_Group
 Usage   : my $count = $pedigree->add_Group($group);
 Function: Adds a group to the Pedigree object
 Returns : count of number of groups contained
 Args    : Bio::Pedigree::GroupI object

=cut

sub add_Group{
   my ($self,$group) = @_;
   return 0 if( ! $group );
   if( !ref($group) || ! $group->isa('Bio::Pedigree::GroupI') ) {
       $self->warn("Trying to add a group with data $group which is not a Bio::Pedigree::GroupI object");
   }
   # force to uppercase just in case
   $self->{'_groups'}->{uc $group->center_groupid} = $group;
   return keys %{$self->{'_groups'}};
}

=head2 remove_Group

 Title   : remove_Group
 Usage   : my $boolean = $pedigree->remove_Group("$center $groupid");
 Function: Removes a group from the list of stored groups in this pedigree
 Returns : boolean of success
 Args    : - either Bio::Pedigree::GroupI object or 
             string "$center $groupid" 


=cut

sub remove_Group{
   my ($self,$val) = @_;
   if( ref($val) && $val->isa('Bio::Pedigree::GroupI') ) {
       $val = $val->center_groupid;
   }
   $val = uc $val;
   return 0 if( ! $self->{'_groups'}->{$val} );
   delete $self->{'_groups'}->{$val};
   return 1;
}

=head2 each_Group

 Title   : each_Group
 Usage   : my (@groups) = $pedigree->each_Group;
 Function: returns the groups - in order 
 Returns : @array of strings or Bio::Pedigree::GroupI objects
 Args    : (optional) - if the string 'id' is passed in will
                        only return each group\'s center & ids 
                        rather than the whole Bio::Pedigree::GroupI object 

=cut

sub each_Group{
   my ($self, $type) = @_;
   return  ( defined $type && $type eq 'id' ) ? keys %{$self->{'_groups'}} : 
       values %{$self->{'_groups'}};
}

=head2 get_Group

 Title   : get_Group
 Usage   : my $group = $pedigree->get_Group("$center $groupid");
 Function: returns the group stored for a specific center and groupid
 Returns : Bio::Pedigree::GroupI object or undef if no group exists for 
           that name
 Args    : name of group (center groupid)

=cut 

sub get_Group{
   my ($self,$name) = @_;
   return $self->{'_groups'}->{uc $name};
}

=head2 num_of_groups

 Title   : num_of_groups
 Usage   : my $count = $pedigree->num_of_groups;
 Function: Returns the number of groups in this Pedigree object
 Returns : integer
 Args    : none


=cut

sub num_of_groups{
   my ($self) = @_;
   return scalar keys %{$self->{'_groups'}};
}

=head2 add_Marker

 Title   : add_Marker
 Usage   : my $count = $pedigree->add_Marker($marker);
 Function: Adds a new Marker to the Pedigree
 Returns : count of number of markers stored in pedigree
 Args    : Bio::Pedigree::MarkerI object

=cut

sub add_Marker{
   my ($self,$marker,$overwrite) = @_;
   return 0 if( ! $marker );
   if( !ref($marker) || ! $marker->isa('Bio::Pedigree::MarkerI') ) {
       $self->warn("Trying to add a marker with data $marker which is not a Bio::Pedigree::MarkerI object");
   }
   if( $self->{'_markers'}->{uc $marker->name} && ! $overwrite) {
       $self->warn("Marker " . uc $marker->name . " already exists");
   } else { 
       $self->{'_markers'}->{uc $marker->name} = $marker;
   }
   return scalar keys %{$self->{'_markers'}};   
}

=head2 remove_Marker

 Title   : remove_Marker
 Usage   : my $status = $pedigree->remove_Marker($markername);
 Function: Removes a marker from the Pedigree object
 Returns : boolean of status
 Args    : Either marker name (string) or reference to Bio::Pedigree::MarkerI object

=cut

sub remove_Marker{
   my ($self,$val) = @_;
   if( ref($val) && $val->isa('Bio::Pedigree::MarkerI') ) {
       $val = $val->name;
   }
   return 0 unless ( defined $self->{'_markers'}->{$val} );
   delete $self->{'_markers'}->{$val};
   return 1;
}

=head2 each_Marker

 Title   : each_Marker
 Usage   : my @markers = $pedigree->each_Marker;
 Function: Returns a list of Markers or marker names stored 
           in the Pedigree object
 Returns : @array of Bio::Pedigree::MarkerI object or marker name strings 
 Args    : (optional) if the string 'name' is passed in will only return
                      the names of markers contained rather than the 
                      actual Bio::Pedigree::MarkerI objects

=cut

sub each_Marker{
   my ($self,$name) = @_;
   return  ( defined $name && $name eq 'name' ) ? 
       keys %{$self->{'_markers'}} : 
       values %{$self->{'_markers'}};
}

=head2 get_Marker

 Title   : get_Marker
 Usage   : my $marker = $pedigree->get_Marker($name);
 Function:
 Example :
 Returns : 
 Args    :


=cut

sub get_Marker {
   my ($self,$name) = @_;
   return $self->{'_markers'}->{uc $name};
}


=head2 num_of_markers

 Title   : num_of_markers
 Usage   : my $count = $pedigree->num_of_markers;
 Function: Returns the number of markers in this Pedigree object
 Returns : integer
 Args    : none


=cut

sub num_of_markers{
   my ($self) = @_;
   return scalar keys %{$self->{'_markers'}};
}

=head2 Additional Data fields

=head2 date

 Title   : date
 Usage   : $obj->date($newval)
 Function: stores date created information
 Returns : value of date
 Args    : newvalue (optional)


=cut

sub date{
   my ($obj,$value) = @_;
   if( defined $value || ! defined $obj->{'_date'}) {
       $value = &POSIX::strftime("%Y/%M/%d",localtime(time)) 
	   unless defined $value;
       $obj->{'_date'} = $value;
   }
   return $obj->{'_date'};
}

=head2 comment

 Title   : comment
 Usage   : $obj->comment($newval)
 Function: stores pedigree comment information
 Returns : value of comment
 Args    : newvalue (optional)

=cut

sub comment{
   my ($obj,$value) = @_;
   if( defined $value ) {
      $obj->{'_comment'} = $value;
    }
    return $obj->{'_comment'} || '';
}


=head2 Algorithms and toplevel data access

=head2 calculate_all_relationships

 Title   : calculate_all_relationships
 Usage   : $pedigree->calculate_all_relationships
 Function: Convience function - 
           calculates all the relationships by calling
           calculate_relationships on each Group object
 Returns : count of number of relationships updated
 Args    : Type of warning to use 'warnOnError', 'failOnError', or
           do not report warnings.
           See also L<Bio::Pedigree::Group>

=cut

sub calculate_all_relationships {
   my ($self,$warningtype) = @_;
   my $count = 0;
   foreach my $group ( $self->each_Group ) {
       $count += $group->calculate_relationships($warningtype);
   }
   return $count;
}

# change the group order

# change the marker order


1;


