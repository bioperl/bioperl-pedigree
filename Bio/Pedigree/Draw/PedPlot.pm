# $Id$
#
# BioPerl module for Bio::Pedigre::Draw::PedPlot
#
# Cared for by Jason Stajich <jason@chg.mc.duke.edu>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Pedigre::Draw::PedPlot - An object to plot pedigrees

=head1 SYNOPSIS

    use Bio::Pedigree::Draw::PedPlot;
    # get a Bio::Pedigree somehow
    my $plotter = new Bio::Pedigree::Draw::PedPlot(-drawingengine => $de);
    $plotter->add_group_to_draw($group,$dxmarker);
    $plotter->write();

=head1 DESCRIPTION

This is an implementation of Bio::Pedigree::Draw::PedRenderI.
This is based on code by Jason Stajich for pedigree plotting in 
PedPlot - see ASHG ..... 
 

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


package Bio::Pedigre::Draw::PedPlot;
use vars qw(@ISA);
use strict;

use Bio::Root::RootI;
use Bio::Pedigree::Draw::PedRenderI;

@ISA = qw( Bio::Pedigree::Draw::PedRenderI Bio::Root::RootI );

=head2 new

 Title   : new
 Usage   : my $plotter = new Bio::Pedigree::Draw::PedPlot(-drawingengine=>$de);
 Function: Initializes a Pedigree::Draw::PedPlot object for plotting pedigrees
 Returns : Bio::Pedigree::Draw::PedPlot object
 Args    : -drawingengine => Bio::Pedigree::Draw::GraphicsI object

=cut

sub new {
    my($class,@args) = @_;    
    my $self = $class->SUPER::new(@args);
    $self->{'_coveredareas'} = [];
    $self->{'_commands'}     = [];
    my ($engine) = $self->_rearrange([qw(DRAWINGENGINE)], @args);
    if( ! $engine && 
	! $engine->isa('Bio::Pedigree::Draw::GraphicsI') ) {
	$self->throw("Must specify a valid Draw::GraphicsI object to Draw::PedPlot");
    } 
    $engine && $self->drawengine($engine);
    return $self;
}

=head2 add_group_to_draw

 Title   : add_group_to_draw
 Usage   : $renderer->add_group_to_draw($group,$marker)
 Function: Draws a group on a page, can be called multiple times
           and will insure that no group overwrites another.

           Data is not final until renderer object is closed 
           (data is synced out to disk/filestream at that point).
 Returns : none 
 Args    : group to draw
           marker which will determine affection status (if not defined 
           affection status will not be reported)

=cut

sub add_group_to_draw {
    my ($self,$group,$marker) = @_;
    if( ! defined $group || ! ref($group) || 
	! $group->isa('Bio::Pedigree::GroupI') ) {
	$self->warn("No valid group passed in to plot");
	return;
    }
    if( $marker && ( ! ref($marker) || 
		     ! $marker->isa('Bio::Pedigree::MarkerI') ) ) {
	$self->warn("Invalid object passed in for marker - $marker, ignoring");
	$marker = undef;
    }
    
}

=head2 drawengine

 Title   : drawengine
 Usage   : $self->drawengine($engine)
 Function: Get/Set reference to GraphicsI object 
 Returns : Bio::Pedigree::Draw::GraphicsI object if set
 Args    : (optional) Bio::Pedigree::Draw::GraphicsI to set

=cut

sub drawengine {
    my ($self,$obj) = @_;
    if( defined $obj ) {
	if( !ref($obj) || ! $obj->isa('Bio::Pedigree::Draw::GraphicsI') ){
	    $self->throw("Did not specify a valid GraphicsI object to drawengine");
	}
	$self->{'_engine'} = $obj;
    }
    return $self->{'_engine'};
}

=head2 write

 Title   : write
 Usage   : $renderer->write;
 Function: Writes pedigree output to data stream using drawengine
 Returns : boolean of success
 Args    : (optional) drawengine to use


=cut

sub write {
    my ($self, $drawengine) = @_;
    if( ! defined $drawengine ) { 
	$drawengine = $self->drawengine;
    }
    
}

1;
