# $Id$
#
# BioPerl module for Bio::Pedigree::DxMarker
#
# Cared for by Jason Stajich <jason@chg.mc.duke.edu>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Pedigree::DxMarker - Disease Marker object 

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


package Bio::Pedigree::DxMarker;
use vars qw(@ISA);
use strict;
use Bio::Pedigree::MarkerI;
use Bio::Root::RootI;

@ISA = qw(Bio::Pedigree::MarkerI Bio::Root::RootI );

=head2 new

 Title   : new
 Usage   : my $dxmarker = new Bio::Pedigree::DxMarker( -name    => $name,
						       -desc    => $desc,
						       -display => $disp, 
						       );
 Function: build a Bio::Pedigree::DxMarker object
 Returns : Bio::Pedigree::DxMarker
 Args    : All fields are required unless specified as optional
           -name     => name of the marker, this is expected to be unique
           -alleles  => available alleles for this marker 
                       (typically 'A' and 'U') 
           -display  => (optional) a display name for the marker if 
                        preferred over 'name' when displaying
                        available markers 
           -desc     => (optional) description text for marker
           -liab     => (optional) liability classes
           -penetrance => (optional) array ref of penetrances for 
                          each liability class
           -frequencies=> (optional) array ref of frequencies for each allele
                          
=cut

sub new {
  my($class,@args) = @_;
  my $self = $class->SUPER::new(@args);
  $self->throw("This object is not finished");

  $self->{'_alleles'} = [ 'U', 'A' ];
  $self->{'_liabclasses'} = [ ];
  $self->{'_classpenetrance'} = { };
  $self->{'_allele_frequencies'} = { };

  my ($name, $desc, $display,$alleles,
      $liab, $penetrance,
      $freqs ) = $self->_rearrange([qw(NAME DESC DISPLAY ALLELES 
				       LIAB PENETRANCE
				       FREQS)], @args);
  if( !defined $name ) {
      $self->throw("Must specify a valid name to initialize DxMarker");
  } 
  
  $self->name($name);
  defined $display && $self->display_name ($display);
  defined $desc    && $self->description($desc);
  if( defined $alleles ) {
  
    if( ref($alleles) !~ /array/i ) {
	$self->warn("Tried to set alleles in new but specified $alleles not an array ref"); 
    }  else { 
	$self->{'_alleles'} = $alleles;
    }
  }
}

=head2 Bio::Pedigree::DxMarker specific methods

=head2 liab_classes

 Title   : liab_classes
 Usage   : my $liab_classes = $marker->liab_classes();
 Function: Get/Set liab_classes of onset
 Returns : array of liab_classes
 Args    : [optional] liab_classes to set (array)

=cut

sub liab_classes {
    my ($self, @values) = @_;
    if( @values || ! defined $self->{'_liab_classes'} ) {
        @values = () unless @values;
        $self->{'_liab_classes'} = \@values;
    }
    return @{$self->{'_liab_classes'}};
}

=head2 frequencies

 Title   : frequencies
 Usage   : my $freqs = $marker->frequencies();
 Function: Get/Set frequencies 
 Returns : array of frequencies
 Args    : [optional] frequencies to set (array)

=cut

sub frequencies {
    my ($self, @values) = @_;
    if( @values || ! defined $self->{'_frequencies'} ) {
        @values = () unless @values;
        $self->{'_frequencies'} = \@values;
    }
    return @{$self->{'_frequencies'}};
}

=head2 penetrances

 Title   : penetrances
 Usage   : my $pens = $marker->penetrances();
 Function: Get/Set penetrances of onset
 Returns : array of penetrances
 Args    : [optional] penetrances to set (array)

=cut

sub penetrances {
    my ($self, @values) = @_;
    if( @values || ! defined $self->{'_penetrances'} ) {
        @values = () unless @values;
        $self->{'_penetrances'} = [@values];
    }
    return @{$self->{'_penetrances'}};
}

=head2 Bio::Pedigree::MarkerI implemented

=head2 display_name

 Title   : display_name
 Usage   : my $name = $marker->display_name;
 Function: Get/Set Marker Display name
 Returns : string
 Args    : (optional) string to set

=cut

sub display_name {
   my ($obj,$value) = @_;
   if( defined $value) {
       $obj->{'_displayname'} = $value;
   }
   return $obj->{'_displayname'};
}

=head2 name

 Title   : name
 Usage   : my $name = $variation->name;
 Function: Get/Set Variation name
 Returns : string
 Args    : (optional) string to set


=cut

sub name{
   my ($obj,$value) = @_;
   if( defined $value) {
       $obj->{'_name'} = $value;
   }
   return $obj->{'_name'};
}

=head2 type

 Title   : type
 Usage   : my $type = $variation->type;
 Function: Get marker type - valid types are defined by 
           implementing classes
 Returns : type value
 Args    : none

=cut

# I guess this is an okay way to do this

sub type { return 'Dx'; }

=head2 description

 Title   : description
 Usage   : my $desc = $marker->description();
 Function: Get/Set description for a marker
 Returns : Description string 
 Args    : (optional) string to set as description

=cut

sub description{
    my ($self, $value) = @_;
    if( defined $value ) {
	$self->{'_description'} = $value;
    }
    return $self->{'_description'};
}


=head2 num_of_alleles

 Title   : num_of_alleles
 Usage   : my $count = $variation->num_of_alleles
 Function: returns the number of alleles known for this Marker
           In the case of a Dx marker, this will be the different 
           affection states           
 Returns : integer
 Args    : none


=cut

sub num_of_alleles{
    my ($self) = @_;
    return scalar $self->known_alleles;
}


=head2 known_alleles

 Title   : known_alleles
 Usage   : @alleles = $marker->known_alleles
 Function: Get/Set a list of the known alleles for this marker
 Returns : @array of known alleles
 Args    : (optional) list of alleles to set for a marker

=cut 

sub known_alleles {
    my($self,@values) = @_;
    if( @values ) {
	$self->{'_alleles'} = [ @values ];
    }
    return @{ $self->{'_alleles'} };
}

=head2 num_of_result_alleles

 Title   : num_of_result_alleles
 Usage   : my $num_alleles_for_result = $marker->num_of_result_alleles;
 Function: returns the number of result alleles for a marker - entirely
           dependant on the marker type.
 Returns : Either '1' or '2' in almost all cases
 Args    : none

=cut

sub num_of_result_alleles{
    return 1;
}

1;
