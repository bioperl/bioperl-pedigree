# $Id$
#
# BioPerl module for Bio::Pedigree::PedIO::ped.pm
#
# Cared for by Jason Stajich <jason@chg.mc.duke.edu>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Pedigree::PedIO::ped.pm - Ped format implementation of the PedIO system for reading linkage format pedigree files

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


package Bio::Pedigree::PedIO::ped.pm;
use vars qw(@ISA);
use strict;

use Bio::Pedigree::PedIO

@ISA = qw(Bio::Pedigree::PedIO );

=head2 read_pedigree

 Title   : read_pedigree
 Usage   : my $ped = $stream->read_pedigree
 Function: Read the pedigree from the stream and instantiate an object 
 Returns : Bio::Pedigree object
 Args    : none

=cut

sub read_pedigree{
   my ($self) = @_;
   $self->warn("cannot call read_pedigree from Bio::Pedigree::PedIO");
}



