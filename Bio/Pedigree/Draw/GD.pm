
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

use Bio::Root::RootI;
use Bio::Pedigree::Draw::GraphicsI;

@ISA = qw(Bio::Pedigree::Draw::GraphicsI Bio::Root::RootI );
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
  my ($type,$fh) = $self->_rearrange([qw(TYPE FH)],@args);
  if( ! defined $fh ) { $self->throw("Must specify Filehandle (-fh) to write to"); }
  $type = $DEFAULTTYPE unless defined $type;  
  my $gd = new GD::Image(100,100);
  $self->_gdengine($gd);
  $self->fh($fh);
  return $self;
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

=head2 fh

 Title   : fh
 Usage   : $obj->fh($newval)
 Function: 
 Returns : value of fh
 Args    : newvalue (optional)


=cut

sub fh{
   my ($obj,$value) = @_;
   if( defined $value) {
      $obj->{'_fh'} = $value;
    }
    return $obj->{'_fh'};
}
