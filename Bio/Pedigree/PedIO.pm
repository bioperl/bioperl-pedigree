# $Id$
#
# BioPerl module for Bio::Pedigree::PedIO
#
# Cared for by Jason Stajich <jason@chg.mc.duke.edu>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Pedigree::PedIO - Interface for reading in pedigree files from a variety of formats in the same flavor as Bio::SeqIO.

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


package Bio::Pedigree::PedIO;
use vars qw(@ISA);
use strict;

use Bio::Root::RootI;
use Bio::Root::IO;

@ISA = qw(Bio::Root::IO Bio::Root::RootI );

=head2 new

 Title   : new
 Usage   : $stream = Bio::Pedigree::PedIO->new(-file => $filename, 
					       -format => 'ped')
 Function: Returns a new pedreader object
           This is in the SeqIO style but since none of the PED formats
           support more than one pedigree set per data file, we have
           read/write methods instead of iterator methods.
                 
 Returns : A Bio::Pedigree::PedIO::Handler initialised with 
          the appropriate format
 Args    : -format => format
           -file => $filename 
           -fh => filehandle to attach to for data

=cut

sub new {
  my($caller,@args) = @_;

  my $class = ref($caller) || $caller;

  if( $class =~ /Bio::Pedigree::PedIO::(\S+)/ ) {
	my ($self) = $class->SUPER::new(@args);	
	$self->_initialize(@args);
	return $self;
    } else { 
	my %param = @args;
	@param{ map { lc $_ } keys %param } = values %param; # lowercase keys
	my $format = $param{'-format'} || 
	    $class->_guess_format( $param{-file} || $ARGV[0] ) ||
		'ped';
	$format = "\L$format";	# normalize capitalization to lower case

	# normalize capitalization
	return undef unless( &_load_format_module($format) );
	return "Bio::Pedigree::PedIO::$format"->new(@args);
    }
}

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

=head2 write_pedigree

 Title   : write_pedigree
 Usage   : my $ped = $stream->write_pedigree
 Function: Write the pedigree to the stream  
 Returns : Bio::Pedigree object
 Args    : none
 Note    : This won\'t work exactly like the SeqIO system because 
           typically only one pedigree can be written per file, so 
           subsequent calls to write_pedigree will throw execptions.
           There may be a better way to do this.
=cut

sub write_pedigree{
   my ($self) = @_;
   $self->warn("cannot call write_pedigree from Bio::Pedigree::PedIO");
}

sub _initialize {
    my($self, @args) = @_;
    
    # not really necessary unless we put more in RootI
    $self->SUPER::_initialize(@args);
    
    # initialize the IO part
    $self->_initialize_io(@args);
}

=head2 _load_format_module

 Title   : _load_format_module
 Usage   : *INTERNAL PedIO stuff*
 Function: Loads up (like use) a module at run time on demand
 Example :
 Returns :
 Args    :

=cut

sub _load_format_module {
  my ($format) = @_;
  my ($module, $load, $m);

  $module = "_<Bio/Pedigree/PedIO/$format.pm";
  $load = "Bio/Pedigree/PedIO/$format.pm";

  return 1 if $main::{$module};
  eval {
    require $load;
  };
  if ( $@ ) {
    print STDERR <<END;
$load: $format cannot be found
Exception $@
For more information about the PedIO system please see the PedIO docs.
This includes ways of checking for formats at compile time, not run time
END
  ;
    return;
  }
  return 1;
}

=head2 _guess_format

 Title   : _guess_format
 Usage   : $obj->_guess_format($filename)
 Function:
 Example :
 Returns : guessed format of filename (lower case)
 Args    :

=cut

sub _guess_format {
   my $class = shift;
   return unless $_ = shift;
   return 'ped'   if /\.(ped|pedfile|pped)$/i;
   return 'lapis' if /\.(lap|lapis)$/i;
}

sub DESTROY {
    my $self = shift;

    $self->close();
}


sub TIEHANDLE {
  my $class = shift;
  return bless {seqio => shift}, $class;
}

sub READLINE {
  my $self = shift;
  return $self->{'pedio'}->next_seq() unless wantarray;
  my (@list, $obj);
  push @list, $obj while $obj = $self->{'pedio'}->next_seq();
  return @list;
}

sub PRINT {
  my $self = shift;
  $self->{'pedio'}->write_seq(@_);
}

1;
