

#
# BioPerl module for Bio::Pedigree::Draw::Command
#
# Cared for by Jason Stajich <jason@chg.mc.duke.edu>
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


package Bio::Pedigree::Draw::Command;
use vars qw(@ISA $DEFAULTCOLOR $DEFAULTLINEWIDTH) ;
use strict;

use Bio::Root::RootI;
$DEFAULTLINEWIDTH = 1;
$DEFAULTCOLOR = 'BLACK';

@ISA = qw(Bio::Root::RootI );

sub new {
  my($class,@args) = @_;

  my $self = $class->SUPER::new(@args);
  my ($startx,$starty, $linewidth,
      $color) = $self->_rearrange([qw(STARTX STARTY LINEWIDTH COLOR)],@args);  

  if( ! defined $startx || ! defined $starty ) {
      $self->throw("Did not specify required startx or starty to Command");
  } else { 
      $self->startx($startx);
      $self->startx($starty);      
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
	$obj->{'startx'} = $value;
    }
    return $obj->{'startx'};
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
	$obj->{'starty'} = $value;
    }
    return $obj->{'starty'};
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
	$obj->{'linewidth'} = $value;
    }
    return $obj->{'linewidth'};
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
	$obj->{'color'} = $value;
    }
    return $obj->{'color'};
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
	$obj->{'endx'} = $value;
    }
    return $obj->{'endx'};
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
	$obj->{'endy'} = $value;
    }
    return $obj->{'endy'};
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
    my ($endx,$endy,$fill) = $self->_rearrange([qw(ENDX ENDY 
						   FILLCOLOR)],@args);  

    if( ! defined $endx || ! defined $endy ) {
	$self->throw("Must defined endx and endy in BoxCommand");
    }
    $self->endx($endx);
    $self->endy($endy);
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
			     $self->endx, $self->endy,
			     $self->linewidth, $self->color,
			     $self->fillcolor);
}

=head2 endx

 Title   : endx
 Usage   : $obj->endx($newval)
 Function: 
 Returns : value of endx
 Args    : newvalue (optional)


=cut

sub endx{
   my ($obj,$value) = @_;
   if( defined $value) {
      $obj->{'endx'} = $value;
    }
    return $obj->{'endx'};

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
      $obj->{'endy'} = $value;
    }
    return $obj->{'endy'};

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
      $obj->{'fillcolor'} = $value;
    }
    return $obj->{'fillcolor'};
}

package Bio::Pedigree::Draw::OvalCommand;
use vars qw(@ISA);
use strict;

use Bio::Pedigree::Draw::Command;

@ISA = qw(Bio::Pedigree::Draw::Command);

sub new {
    my ($class, @args) = @_;
    my $self = $class->SUPER::new(@args);
    my ($radx,$rady,$fill) = $self->_rearrange([qw(RADIUSX RADIUSY 
						   FILLCOLOR)],@args);  

    if( ! defined $radx || ! defined $rady ) {
	$self->throw("Must defined radiusx and radiusy in OvalCommand");
    }
    $self->radiusx($radx);
    $self->radiusy($rady);
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
   $graphics->draw_oval($self->startx - $self->radiusx ,
			      $self->starty - $self->radiusy,
			      $self->radiusx, $self->radiusy,
			      $self->linewidth, $self->color,
			      $self->fillcolor);
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
      $obj->{'fillcolor'} = $value;
    }
    return $obj->{'fillcolor'};
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
      $obj->{'fontsize'} = $value;
    }
    return $obj->{'fontsize'};

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
      $obj->{'direction'} = $value;
    }
    return $obj->{'direction'};
}

package Bio::Pedigree::Draw::Command;
1;
