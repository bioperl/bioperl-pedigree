
#
# BioPerl module for Bio::Pedigree::Draw::GD
#
# Cared for by Jason Stajich <jason@chg.mc.duke.edu>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Pedigree::Draw::GD - DESCRIPTION of Object

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


package Bio::Pedigree::Draw::GD;
use vars qw(@ISA $DEFAULTTYPE);
use strict;

use Bio::Root::Root;
use Bio::Pedigree::Draw::GraphicsI;
use GD;

@ISA = qw(Bio::Root::Root Bio::Pedigree::Draw::GraphicsI  );
$DEFAULTTYPE = 'png';

=head2 new

 Title   : new
 Usage   : my $graphics = new Bio::Pedigree::Draw::GD(-fh => $fh,
						      -type => 'png');
 Function: Initialize a Bio::Pedigree::Draw::GD object
 Returns : Bio::Pedigree::Draw::GD object
 Args    : -fh   => filehandle to write to
           -type => format to use 'png' or 'gif' are supported by GD
                    only png depending on your version of GD

=cut

sub new {
  my($class,@args) = @_;
  my $self = $class->SUPER::new(@args);
  my ($h,$w,$type,$fh) = $self->_rearrange([qw(HEIGHT WIDTH TYPE FH)],@args);
  if( ! defined $fh ) { $self->throw("Must specify Filehandle (-fh) to write to"); }
  $type = $DEFAULTTYPE unless defined $type;  
  if( ! $h || ! $w ) {
      $self->throw("Must specify height and width for GD to draw image");
  }
  my $gd = new GD::Image($w,$h);
  $self->type($type);
  $self->_gdengine($gd);
  $self->_fh($fh);
  $self->_initialize_colors();
  return $self;
}

sub close {
    my ($self) = @_;
    my $fh = $self->_fh;
    if( defined $fh ) {
	binmode $fh;
	my $type = $self->type;
	print $fh $self->_gdengine->$type();
    }
    close($self->_fh);
    $self->{'_gdengine'} = undef;
}

sub DESTROY {
    my($self) = @_;
    $self->close;
}

=head2 _get_color

 Title   : _get_color
 Usage   : private method to get a color from the internal hash
 Args    : color name

=cut

sub _get_color {
   my ($self,$colorname) = @_;
   return undef unless defined $colorname;
   $colorname = uc $colorname;
   return $self->{'_colors'}->{$colorname};
}

=head2 _initialize_colors

 Title   : _initialize_colors
 Usage   : private method to initialize color hash

=cut

sub _initialize_colors {
   my ($self) = @_;
   $self->{'_colors'} = {};

   $self->{'_colors'}->{'WHITE'} = $self->_gdengine->colorAllocate(255,255,255);
   $self->{'_colors'}->{'BLACK'} = $self->_gdengine->colorAllocate(0,0,0);
   $self->{'_colors'}->{'RED'} = $self->_gdengine->colorAllocate(255,0,0);
   $self->{'_colors'}->{'BLUE'} = $self->_gdengine->colorAllocate(0,0,255);
   
   return;
}

=head2 _gdengine

 Title   : _gdengine
 Usage   : $obj->_gdengine($newval)
 Function: 
 Returns : value of _gdengine
 Args    : newvalue (optional)


=cut

sub _gdengine{
   my ($obj,$value) = @_;
   if( defined $value) {
      $obj->{'_gdengine'} = $value;
    }
    return $obj->{'_gdengine'};
}

=head2 _fh

 Title   : _fh
 Usage   : $obj->fh($newval)
 Function: 
 Returns : value of _fh
 Args    : newvalue (optional)


=cut

sub _fh{
   my ($obj,$value) = @_;
   if( defined $value) {
      $obj->{'_fh'} = $value;
    }
    return $obj->{'_fh'};
}

=head2 type

 Title   : type
 Usage   : $obj->type($newval)
 Function: 
 Returns : value of type
 Args    : newvalue (optional)


=cut

sub type{
    my ($obj,$value) = @_;
    if( defined $value) {
	$value =~ s/jpg/jpeg/;
	if( $value !~ /png|jpeg|gd|gd2|wbmp/ ) {
	    $obj->throw("type $value is unrecognized for GD");
	}
	$obj->{'_type'} = $value;
    }
    return $obj->{'_type'};
}

=head2 GraphicsI implementation

=head2 draw_line

 Title   : draw_line
 Usage   : $graphics->draw_line($startx,$starty,$endx,$endy,
				$linewidth,$linecolor);
 Function: Draws a line with starting and ending points, width and color
 Returns : none
 Args    : starting X point 
           starting Y point
           ending   X point
           ending   Y point
           width of line (in points)
           color of line (string)

=cut

sub draw_line {
    my ($self, $startx,$starty,$endx,$endy,$linewidth,$linecolor) = @_;
    my $color = $self->_get_color($linecolor);
    $self->_gdengine->line($startx,$starty,$endx,$endy,$color);
}

=head2 draw_box

 Title   : draw_box
 Usage   : $graphics->draw_box($startx,$starty,$endx,$endy,
			       $linewidth,$linecolor, $fillcolor);
 Function: Draws a line with starting and ending points, width and color
 Returns : none
 Args    : starting X point (top left corner)
           starting Y point (top left corner)
           ending   X point (bottom right corner) 
           ending   Y point (bottom right corner)
           width of line (in points)
           color of line  (string)
           box fill color (string)

=cut

sub draw_box {
    my ($self, $startx,$starty,$endx,$endy,$linewidth,$linecolor,$fill) = @_;
    my $color = $self->_get_color($linecolor);
    my $fillcolor = $self->_get_color($fill);
    my $white = $self->_get_color('WHITE');

    if(defined $fillcolor && $fillcolor != $white ) {
	$self->_gdengine->filledRectangle($startx,$starty,$endx,$endy,
					  $fillcolor);
    } else { 
	$self->_gdengine->rectangle($startx,$starty,$endx,$endy,$color);
    }
}

=head2 draw_oval

 Title   : draw_oval
 Usage   : $graphics->draw_oval($centerx,$centery,$width,$height,
				$linewidth,$linecolor, $fillcolor);
 Function: Draws a line with starting and ending points, width and color
 Returns : none
 Args    : center   X point
           center   Y point
           width
           height
           width of line (in points)
           color of line   (string)
           oval fill color (string)

=cut

sub draw_oval {
    my ($self, $centerx,$centery,$width,$height,$linewidth,
	$linecolor,$fill) = @_;
    my $color = $self->_get_color($linecolor);
    my $fillcolor = $self->_get_color($fill);
    my $white = $self->_get_color('WHITE');
    $self->_gdengine->arc($centerx,$centery,
			  $width, $height,
			  0, 360, $color);

    if(defined $fillcolor && $fillcolor != $white ) {
	$self->_gdengine->fill($centerx,$centery,$fillcolor);
    }
}

=head2 draw_text

 Title   : draw_text
 Usage   : $graphics->draw_text($startx,$starty,$text,$textcolor,
				$fontsize,$direction);
 Function: Draws text
 Returns : none
 Args    : starting X point
           starting Y point
           text to draw (string)
           textcolor (string)
           fontsize (integer)
           direction (horizontal or vertial text)


=cut

sub draw_text {
    my ($self, $startx,$starty,$text,$textcolor,$fontsize,
	$direction) = @_;
    my $font;
    if( $fontsize <= 5 ) {
	$font = GD::Font->Tiny;
    } elsif( $fontsize <= 8 ) {
	$font = GD::Font->Small;
    } elsif( $fontsize <= 12 ) {
	$font = GD::Font->MediumBold;
    } elsif( $fontsize <= 16 ) {
	$font = GD::Font->Large;
    } else {
	$font = GD::Font->Giant;
    }
 
    my $color = $self->_get_color($textcolor);

    $self->_gdengine->string(gdSmallFont, $startx,$starty,$text,$color);
}

1;
