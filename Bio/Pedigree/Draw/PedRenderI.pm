
#
# BioPerl module for Bio::Pedigree::Draw::PedRenderI
#
# Cared for by Jason Stajich <jason@chg.mc.duke.edu>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Pedigree::Draw::PedRenderI - DESCRIPTION of Object

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


package Bio::Pedigree::Draw::PedRenderI;
use strict;
use Carp;

sub _abstractDeath {
  my $self = shift;
  my $package = ref $self;
  my $caller = (caller)[1];
  
  confess "Abstract method '$caller' defined in interface Bio::Pedigree::Draw::PedRenderI not implemented by pacakge $package. Not your fault - author of $package should be blamed!";
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
    _abstractDeath();
}

=head2 max_height

 Title   : max_height
 Usage   : my $height = $rendered->max_height
 Function: returns the maximum height needed to draw the pedigree
 Returns : integer
 Args    : none

=cut

sub max_height {
    _abstractDeath;
}

=head2 max_width

 Title   : max_width
 Usage   : my $width = $renderer->max_width
 Function: returns the maximum width needed to draw the pedigree
 Returns : integer
 Args    : none


=cut

sub max_width {
    _abstractDeath();
}


=head2 write

 Title   : write
 Usage   : $renderer->write;
 Function: Writes pedigree output to data stream using drawengine
 Returns : boolean of success
 Args    : drawingengine to use


=cut

sub write {
    _abstractDeath();
}

1;
