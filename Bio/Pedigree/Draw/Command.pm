

#
# BioPerl module for Bio::Pedigree::Draw::Command
#
# Cared for by Jason Stajich <jason@bioperl.org>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Pedigree::Draw::Command - DESCRIPTION of Object

=head1 SYNOPSIS

Give standard usage here

=head1 DESCRIPTION

Describe the object here

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to
the Bioperl mailing list.  Your participation is much appreciated.

  bioperl-l@bioperl.org                  - General discussion
  http://bioperl.org/wiki/Mailing_lists  - About the mailing lists

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
of the bugs and their resolution. Bug reports can be submitted via
the web:

  http://bugzilla.open-bio.org/

=head1 AUTHOR - Jason Stajich

Email jason@bioperl.org

Describe contact details here

=head1 APPENDIX

The rest of the documentation details each of the object methods.
Internal methods are usually preceded with a _

=cut


# Let the code begin...


package Bio::Pedigree::Draw::Command;
use vars qw(@ISA $DEFAULTCOLOR $DEFAULTLINEWIDTH) ;
use strict;

use Bio::Root::Root;
$DEFAULTLINEWIDTH = 1;
$DEFAULTCOLOR = 'BLACK';

@ISA = qw(Bio::Root::Root );

sub new {
  my($class,@args) = @_;

  my $self = $class->SUPER::new(@args);
  my ($startx,$starty, $linewidth,
      $color) = $self->_rearrange([qw(STARTX STARTY LINEWIDTH COLOR)],@args);  

  if( ! defined $startx || ! defined $starty ) {
      $self->throw("Did not specify required startx or starty to Command");
  } else { 
      $self->startx($startx);
      $self->starty($starty);      
  }
  if( ! defined $linewidth ) {
      $linewidth = $DEFAULTLINEWIDTH;
  }
  $self->linewidth($linewidth);
  if( ! defined $color ) {
      $color = $DEFAULTCOLOR;
  }
  $self->color($color);

  return $self;
}

=head2 execute

 Title   : execute
 Usage   : $command->execute;
 Function: Executes the drawing command encapsulated in this command
 Returns : none
 Args    : none

=cut

sub execute {
   my ($self,@args) = @_;
   $self->throw("Must be implemented by subclass of Command");
}

=head2 shift_up

 Title   : shift_up
 Usage   : $command->shift_up($value);
 Function: Shifts the command coordinates up
 Returns : none
 Args    : $value to add to the y-coordinates 

=cut

sub shift_up {
   my ($self,$value) = @_;
   return if ! $value;
   $self->starty( $self->starty + $value);
}

=head2 shift_right

 Title   : shift_right
 Usage   : $command->shift_right($value)
 Function: Shifts the command coordinates to the right
 Returns : nothing 
 Args    : $value to add to the x-coorindates


=cut

sub shift_right {
   my ($self,$value) = @_;
   return if ! $value;
   $self->startx( $self->startx + $value);
}

=head2 startx

 Title   : startx
 Usage   : $obj->startx($newval)
 Function: 
 Returns : value of startx
 Args    : newvalue (optional)


=cut

sub startx{
    my ($obj,$value) = @_;
    if( defined $value) {
	$obj->{'_startx'} = $value;
    }
    return $obj->{'_startx'};
}

=head2 starty

 Title   : starty
 Usage   : $obj->starty($newval)
 Function: 
 Returns : value of starty
 Args    : newvalue (optional)


=cut

sub starty{
    my ($obj,$value) = @_;
    if( defined $value) {
	$obj->{'_starty'} = $value;
    }
    return $obj->{'_starty'};
}

=head2 linewidth

 Title   : linewidth
 Usage   : $obj->linewidth($newval)
 Function: 
 Returns : value of linewidth
 Args    : newvalue (optional)


=cut

sub linewidth{
    my ($obj,$value) = @_;
    if( defined $value) {
	$obj->{'_linewidth'} = $value;
    }
    return $obj->{'_linewidth'};
}

=head2 color

 Title   : color
 Usage   : $obj->color($newval)
 Function: 
 Returns : value of color
 Args    : newvalue (optional)

=cut

sub color{
    my ($obj,$value) = @_;
    if( defined $value) {
	$obj->{'_color'} = $value;
    }
    return $obj->{'_color'};
}


# --- new Command --- #

package Bio::Pedigree::Draw::LineCommand;
use vars qw(@ISA);
use strict;

use Bio::Pedigree::Draw::Command;

@ISA = qw(Bio::Pedigree::Draw::Command);

sub new {
  my($class,@args) = @_;

  my $self = $class->SUPER::new(@args);
  my ($endx,$endy) = $self->_rearrange([qw(ENDX ENDY)],@args);  

  if( ! defined $endx || ! defined $endy ) {
      $self->throw("Must defined endx and endy in LineCommand");
  }
  $self->endx($endx);
  $self->endy($endy);
   
  return $self;
}

=head2 execute

 Title   : execute
 Usage   : $command->execute;
 Function: Executes the drawing command encapsulated in this command
 Returns : none
 Args    : none

=cut

sub execute {
   my ($self,$graphics) = @_;
   $graphics->draw_line($self->startx, $self->starty, 
			$self->endx,$self->endy, $self->linewidth,
			$self->color);
}

=head2 shift_up

 Title   : shift_up
 Usage   : $command->shift_up($value);
 Function: Shifts the command coordinates up
 Returns : none
 Args    : $value to add to the y-coordinates 

=cut

sub shift_up {
   my ($self,$value) = @_;
   $self->SUPER::shift_up($value);
   return if ! $value;   
   $self->endy( $self->endy + $value);
}

=head2 shift_right

 Title   : shift_right
 Usage   : $command->shift_right($value)
 Function: Shifts the command coordinates to the right
 Returns : nothing 
 Args    : $value to add to the x-coorindates


=cut

sub shift_right {
   my ($self,$value) = @_;
   $self->SUPER::shift_right($value);
   return if ! $value;
   $self->endx( $self->endx + $value);
}

=head2 endx

 Title   : endx
 Usage   : $obj->endx($newval)
 Function: args
 Returns : value of endx
 Args    : newvalue (optional)


=cut

sub endx{
    my ($obj,$value) = @_;
    if( defined $value) {
	$obj->{'_endx'} = $value;
    }
    return $obj->{'_endx'};
}

=head2 endy

 Title   : endy
 Usage   : $obj->endy($newval)
 Function: 
 Returns : value of endy
 Args    : newvalue (optional)


=cut

sub endy{
    my ($obj,$value) = @_;
    if( defined $value) {
	$obj->{'_endy'} = $value;
    }
    return $obj->{'_endy'};
}

# --- new Command --- #

package Bio::Pedigree::Draw::BoxCommand;
use vars qw(@ISA);
use strict;

use Bio::Pedigree::Draw::Command;

@ISA = qw(Bio::Pedigree::Draw::Command);

sub new {
    my ($class, @args) = @_;
    my $self = $class->SUPER::new(@args);
    my ($height, $width,$fill) = $self->_rearrange([qw(HEIGHT WIDTH 
						       FILLCOLOR)],@args);  

    if( ! defined $height || ! defined $height ) {
	$self->throw("Must defined height and width in BoxCommand");
    }
    $self->height($height);
    $self->width($width);
    if( ! defined $fill ) {
	$fill = 'WHITE';
    }
    $self->fillcolor($fill);
    return $self;
}

=head2 execute

 Title   : execute
 Usage   : $command->execute;
 Function: Executes the drawing command encapsulated in this command
 Returns : none
 Args    : none

=cut

sub execute {
   my ($self,$graphics) = @_;
   $graphics->draw_box($self->startx,$self->starty,
		       $self->startx + $self->width, 
		       $self->starty + $self->height,
		       $self->linewidth, $self->color,
		       $self->fillcolor);
}

=head2 height

 Title   : height
 Usage   : $obj->height($newval)
 Function: 
 Returns : value of height
 Args    : newvalue (optional)


=cut

sub height{
   my ($obj,$value) = @_;
   if( defined $value) {
      $obj->{'_height'} = $value;
    }
    return $obj->{'_height'};

}

=head2 width

 Title   : width
 Usage   : $obj->width($newval)
 Function: 
 Returns : value of width
 Args    : newvalue (optional)


=cut

sub width{
   my ($obj,$value) = @_;
   if( defined $value) {
      $obj->{'_width'} = $value;
    }
    return $obj->{'_width'};

}

=head2 fillcolor

 Title   : fillcolor
 Usage   : $obj->fillcolor($newval)
 Function: 
 Returns : value of fillcolor
 Args    : newvalue (optional)


=cut

sub fillcolor{
   my ($obj,$value) = @_;
   if( defined $value) {
      $obj->{'_fillcolor'} = $value;
    }
    return $obj->{'_fillcolor'};
}

package Bio::Pedigree::Draw::OvalCommand;
use vars qw(@ISA);
use strict;

use Bio::Pedigree::Draw::Command;

@ISA = qw(Bio::Pedigree::Draw::Command);

sub new {
    my ($class, @args) = @_;
    my $self = $class->SUPER::new(@args);
    my ($height, $width,$fill) = $self->_rearrange([qw(HEIGHT WIDTH 
						       FILLCOLOR)],@args);  

    if( ! defined $height || ! defined $width ) {
	$self->throw("Must define height and width in OvalCommand");
    }
    $self->height($height);
    $self->width($width);
    if( ! defined $fill ) {
	$fill = 'WHITE';
    }
    $self->fillcolor($fill);
    return $self;

}

=head2 execute

 Title   : execute
 Usage   : $command->execute;
 Function: Executes the drawing command encapsulated in this command
 Returns : none
 Args    : none

=cut

sub execute {
   my ($self,$graphics) = @_;
   # adjust for startx to be the center of the circle not top left
   # as in boxes
   $graphics->draw_oval($self->startx + ($self->width / 2), 
			$self->starty + ($self->height/ 2),
			$self->width,
			$self->height,
			$self->linewidth, $self->color,
			$self->fillcolor);
}

=head2 height

 Title   : height
 Usage   : $obj->height($newval)
 Function: 
 Returns : value of height
 Args    : newvalue (optional)


=cut

sub height{
   my ($obj,$value) = @_;
   if( defined $value) {
      $obj->{'_height'} = $value;
    }
    return $obj->{'_height'};
}

=head2 width

 Title   : width
 Usage   : $obj->width($newval)
 Function: 
 Returns : value of width
 Args    : newvalue (optional)


=cut

sub width{
   my ($obj,$value) = @_;
   if( defined $value) {
      $obj->{'_width'} = $value;
    }
    return $obj->{'_width'};
}

=head2 fillcolor

 Title   : fillcolor
 Usage   : $obj->fillcolor($newval)
 Function: 
 Returns : value of fillcolor
 Args    : newvalue (optional)


=cut

sub fillcolor{
   my ($obj,$value) = @_;
   if( defined $value) {
      $obj->{'_fillcolor'} = $value;
    }
    return $obj->{'_fillcolor'};
}


package Bio::Pedigree::Draw::TextCommand;
use vars qw(@ISA);
use strict;

use Bio::Pedigree::Draw::Command;

@ISA = qw(Bio::Pedigree::Draw::Command);

sub new {
    my ($class, @args) = @_;
    my $self = $class->SUPER::new(@args);
    my ($text,$fontsize, $dir) = $self->_rearrange([qw(TEXT FONTSIZE 
						 DIRECTION)],@args);  

    if( ! defined $text) {
	$self->throw("Must defined text in TextCommand");
    }
    $self->text($text);
    if( ! defined $fontsize ) {
	$fontsize = 8;
    }
    $self->fontsize($fontsize);

    if( ! defined $dir ) {
	$dir = 'horizontal';
    } elsif( $dir !~ /^horizontal$/i && $dir !~ /^vertical$/ ) {
	$self->warn("Direction $dir is not valid, setting to 'horizontal'");
	$dir = 'horizontal';
    }
    $self->direction($dir);
    return $self;
}

=head2 execute

 Title   : execute
 Usage   : $command->execute;
 Function: Executes the drawing command encapsulated in this command
 Returns : none
 Args    : none

=cut

sub execute {
   my ($self,$graphics) = @_;
   $graphics->draw_text($self->startx, $self->starty,
			$self->text, $self->color,
			$self->fontsize, $self->direction);
}

=head2 fontsize

 Title   : fontsize
 Usage   : $obj->fontsize($newval)
 Function: 
 Returns : value of fontsize
 Args    : newvalue (optional)


=cut

sub fontsize{
   my ($obj,$value) = @_;
   if( defined $value) {
      $obj->{'_fontsize'} = $value;
    }
    return $obj->{'_fontsize'};

}

=head2 direction

 Title   : direction
 Usage   : $obj->direction($newval)
 Function: 
 Returns : value of direction
 Args    : newvalue (optional)


=cut

sub direction{
   my ($obj,$value) = @_;
   if( defined $value) {
      $obj->{'_direction'} = $value;
    }
    return $obj->{'_direction'};
}

=head2 text

 Title   : text
 Usage   : $obj->text($newval)
 Function: 
 Returns : value of text
 Args    : newvalue (optional)


=cut

sub text{
   my ($obj,$value) = @_;
   if( defined $value) {
      $obj->{'_text'} = $value;
    }
    return $obj->{'_text'};
}

package Bio::Pedigree::Draw::Command;
1;
