
#
# BioPerl module for Bio::Pedigree::Draw::GraphicsI
#
# Cared for by Jason Stajich <jason@bioperl.org>
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

  bioperl-l@bioperl.org                  - General discussion
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


package Bio::Pedigree::Draw::GraphicsI;
use strict;
use Bio::Root::RootI;
use vars qw(@ISA);
@ISA = qw(Bio::Root::RootI);

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
    shift->throw_not_implemented();
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
    shift->throw_not_implemented();
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
    shift->throw_not_implemented();
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
    shift->throw_not_implemented();
}

1;
