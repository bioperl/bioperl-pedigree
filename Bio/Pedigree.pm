# $Id$
#
# BioPerl module for Bio::Pedigree
#
# Cared for by Jason Stajich <jason@chg.mc.duke.edu>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Pedigree - This is the toplevel object which contains
references to the Markers genotyped for a set of families, and the
families for which there are results.

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


package Bio::Pedigree;
use vars qw(@ISA);
use strict;

use Bio::Root::RootI;
use Tie::IxHash;
use Bio::Pedigree::Group;
use Bio::Pedigree::Variation;

@ISA = qw(Bio::Root::RootI );

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

  my ($groups, $markers) = $self->_rearrange([qw(GROUPS MARKERS)], @args);
  if( defined $groups ) {
      if( ref($groups) !~ /array/i ) {
	  $self->throw("Trying to initialize Bio::Pedigree object with groups ($groups) which is not an array reference");
      } else { 
	  foreach my $group ( @$groups ) {
	      $self->add_group($group);
	  }
      }
  }
  if( defined $markers ) {
      if( ref($markers) !~ /array/i ) {
	  $self->throw("Trying to initialize Bio::Pedigree object with markers ($markers) which is not an array reference");
      } else { 
	  foreach my $marker ( @$markers ) {
	      $self->add_marker($marker);
	  }
      }
  }
  return $self;
}

=head2 add_group

 Title   : add_group
 Usage   : my $count = $pedigree->add_group($group);
 Function: Adds a group to the Pedigree object
 Returns : count of number of groups contained
 Args    : Bio::Pedigree::GroupI object

=cut

sub add_group{
   my ($self,$group) = @_;
   return 0 if( ! $group );
   if( !ref($group) || ! $group->isa('Bio::Pedigree::GroupI') ) {
       $self->warn("Trying to add a group with data $group which is not a Bio::Pedigree::GroupI object");
   }
   # force to uppercase just in case
   $self->{'_groups'}->{uc $group->center_groupid} = $group;
   return keys %{$self->{'_groups'}};
}

=head2 remove_group

 Title   : remove_group
 Usage   : my $boolean = $pedigree->remove_group("$center $groupid");
 Function: Removes a group from the list of stored groups in this pedigree
 Returns : boolean of success
 Args    : - either Bio::Pedigree::GroupI object or 
             string "$center $groupid" 


=cut

sub remove_group{
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

=head2 add_marker

 Title   : add_marker
 Usage   : my $count = $pedigree->add_marker($marker);
 Function: Adds a new Marker to the Pedigree
 Returns : count of number of markers stored in pedigree
 Args    : Bio::Pedigree::MarkerI object

=cut

sub add_marker{
   my ($self,$marker,$overwrite) = @_;
   return 0 if( ! $marker );
   if( !ref($marker) || ! $marker->isa('Bio::Pedigree::MarkerI') ) {
       $self->warn("Trying to add a marker with data $marker which is not a Bio::Pedigree::MarkerI object");
   }
   if( $self->{'_markers'}->{$marker->name} && ! $overwrite) {
       $self->warn("Marker ", $marker->name, " already exists");
   } else { 
       $self->{'_markers'}->{$marker->name} = $marker;
   }
   return scalar keys %{$self->{'_groups'}};   
}

=head2 remove_marker

 Title   : remove_marker
 Usage   : my $status = $pedigree->remove_marker($markername);
 Function: Removes a marker from the Pedigree object
 Returns : boolean of status
 Args    : Either marker name (string) or reference to Bio::Pedigree::MarkerI object

=cut

sub remove_marker{
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

# change the group order

# change the marker order
1;
