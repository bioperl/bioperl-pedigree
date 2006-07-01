# $Id$
#
# BioPerl module for Bio::Pedigree::Draw
#
# Cared for by Jason Stajich <jason@bioperl.org>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Pedigree::Draw - Object which initiates drawing calling the requested renderer and graphics engine

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


package Bio::Pedigree::Draw;
use strict;
use vars qw(@ISA %FORMATS %RENDERTYPES $DEFAULTRENDERTYPE);

%FORMATS = ( 'png|jpg|jpeg|gd|gd2|gif' => 'Bio/Pedigree/Draw/GD.pm',
	     'ps|postscript' => 'Bio/Pedigree/Draw/Postscript.pm'
	     );

%RENDERTYPES = ( 'pedplot' => 'Bio/Pedigree/Draw/PedPlot.pm');
$DEFAULTRENDERTYPE = 'pedplot';

use Bio::Root::IO;
use Bio::Root::Root;

@ISA = qw(Bio::Root::Root Bio::Root::IO );

=head2 new

 Title   : new
 Usage   : my $draw = new Bio::Pedigree::Draw();

 Function: Initializes a new Drawing object for rendering pedigrees
 Returns : 
 Args    :

=cut


sub new {
   my ($class,@args) = @_;
   my $self = $class->SUPER::new(@args);
   return $self;
}

=head2 draw

 Title   : draw
 Usage   : $plotter->draw(-pedigree   => $pedigree,
			  -rendertype => 'pedplot',
			  -file       => 'filename.png',
			  -format     => 'png');
 Function: Draws a pedigree of individuals
           Each group on a separate pageset or a separate file.

           Glyph and structure formats are determined by the 'type'
           Output file format is determined by 'format'
 Example :
 Returns : 
 Args    :  -type => which rendering engine to use
                    - options are currently only 'pedplot'
                     (would like to do dia xml someday soon)
           default is thus 'postscript'
           -file/-fh => output filename or handle
           -format => output file format - gif,png are supported by GD library
                                         - raw postscript 

=cut

sub draw {
    my ($self,@args) = @_;
    $self->_initialize_io(@args);

    my ($type,$groupindex,$format,
	$pedigree) = $self->_rearrange([qw(RENDERTYPE
					   GROUP
					   FORMAT
					   PEDIGREE)],@args);
    $self->throw("Must specify a pedigree !") unless defined $pedigree;
    $type = $DEFAULTRENDERTYPE if( !defined $type );

    $self->throw("Must specify a format for Drawing") if( ! defined $format );

    my ($rendermodule,$formatmodule);
    foreach my $key ( keys %RENDERTYPES ) {
	if( $type =~ /$key/i ) {
	    $rendermodule = $RENDERTYPES{$key};
	}
    }
    if( ! defined $rendermodule ) { 
	$self->throw("Unrecognized render type $type - it may need to be added to the \%RENDERTYPES hash in the Draw module");
    }
    foreach my $key ( keys %FORMATS ) {
	if( $format =~ /$key/i ) {
	    $formatmodule = $FORMATS{$key};
	}
    }
    if( ! defined $formatmodule ) { 
	$self->throw("Unrecognized format  $type - it may need to be added to the \%FORMATS hash in the Draw module");
    }
    eval { 
	require $formatmodule;
	require $rendermodule;
    };
    if( $@) {
	$self->warn($@);
	$self->throw("Either your system is incorrectly configured or there is an error in the Bio::Pedigree::Draw module");
    }

    foreach ( $formatmodule, $rendermodule ) {
	s/\//::/g;
	s/\.pm$//;
    }
    my $marker;
    foreach my $m ( $pedigree->get_Markers ) {
	if( $m->type eq 'DISEASE' ) { $marker = $m; last;}
    }
    my $renderengine = $rendermodule->new(-verbose => $self->verbose);
    my @groups = $pedigree->get_Groups;    
    my $group;
    if( $groupindex ) {
      if ( ref($groupindex) && $groupindex->isa('Bio::Pedigree::Group') ) {
        $group = $groupindex;
      }
      else {
        $group = $groups[$groupindex];
        if( ! defined $group ) { 
	    $self->warn("no group valid for index $groupindex");
	    return;
        }
     }
     $renderengine->add_group_to_draw($group, $marker->name, 1);
    } else {      
	foreach my $group ( @groups ) {
	    $renderengine->add_group_to_draw($group, defined $marker ? $marker->name : '', 1);
	    last;
	}
    }
    # reposition the drawing
    $renderengine->calibrate();
    my $drawingengine = $formatmodule->new(-width => $renderengine->max_width,
					   -height => $renderengine->max_height ,
					   -fh => $self->_fh,
					   -format => $format,
                                           -type   =>  $format);

    $renderengine->write($drawingengine);
}

1;
