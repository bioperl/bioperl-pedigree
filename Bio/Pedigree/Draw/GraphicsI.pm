
#
# BioPerl module for Bio::Pedigree::Draw::GraphicsI
#
# Cared for by Jason Stajich <jason@chg.mc.duke.edu>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Pedigree::Draw::GraphicsI - 2d graphics interface

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


package Bio::Pedigree::Draw::GraphicsI;
use strict;

use Carp;

sub _abstractDeath {
  my $self = shift;
  my $package = ref $self;
  my $caller = (caller)[1];
  
  confess "Abstract method '$caller' defined in interface Bio::Pedigree::Draw::GraphicsI not implemented by pacakge $package. Not your fault - author of $package should be blamed!";
}

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
           color of line (string) default 'black'
=cut

sub draw_line {
    _abstractDeath();
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
           color of line  (string) default 'black'
           box fill color (string) default 'white'
=cut

sub draw_box {
    _abstractDeath();
}

=head2 draw_oval

 Title   : draw_oval
 Usage   : $graphics->draw_oval($centerx,$centery,$xradius,$yradius,
				$linewidth,$linecolor, $fillcolor);
 Function: Draws a line with starting and ending points, width and color
 Returns : none
 Args    : center   X point
           center   Y point
           length of X radius
           length of Y radius
           width of line (in points)
           color of line   (string) default 'black'
           oval fill color (string) default 'white'
=cut

sub draw_oval {
    _abstractDeath();
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
           direction (horizontal or vertial text) (default 'horizontal')


=cut

sub draw_text {
    _abstractDeath();
}

1;
