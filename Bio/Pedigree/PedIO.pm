# $Id$
#
# BioPerl module for Bio::Pedigree::PedIO
#
# Cared for by Jason Stajich <jason@bioperl.org>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Pedigree::PedIO - PedIO interface 

=head1 SYNOPSIS

    use Bio::Pedigree::PedIO;
    my $pedio = new Bio::Pedigree::PedIO(-format => 'genethon');

=head1 DESCRIPTION

This is the interface description for the PedIO system.  Various
subclasses implement this module and handle reading and writing
pedigrees in specific formats.

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


package Bio::Pedigree::PedIO;
use vars qw(@ISA @EXPORT $DEFAULTDIGITLEN);
use strict;

use Bio::Root::Root;
use Bio::Root::IO;
require Exporter;

BEGIN { $DEFAULTDIGITLEN = 4; }

@ISA = qw(Bio::Root::Root Exporter);
@EXPORT = qw(_digitstr);

=head2 new

 Title   : new
 Usage   : do not use this module directly it is an interface
 Function: initializes a PedIO object, constructor for shared 
           data initialization.

           IO is initialized in the read/write methods since 
           a single stream can really only support one pedigree
           at a time.
 Returns : new Bio::Pedigree::PedIO object
 Args    : 

=cut

sub new {
    my($class,@args) = @_;

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
	return undef unless( $class->_load_format_module($format) );
	return "Bio::Pedigree::PedIO::$format"->new(@args);
    }
}

# _initialize is chained for all PedIO classes

sub _initialize {
    my($self, @args) = @_;
    
    # not really necessary unless we put more in RootI
    $self->SUPER::_initialize(@args);    
}

=head2 read_pedigree

 Title   : read_pedigree
 Usage   : my $pedigree = $pedio->read_pedigree(-pedfile => $pedfile,
						-datfile => $datfile);
 Function: Instatiates a Bio::Pedigree::Pedigree object from a data source
 Returns : Bio::Pedigree::Pedigree object or undef on failed reading 
 Args    : -pedfile => pedigree input location
           -datfile => (if needed) marker data input location
           pedfile/datfile can be filenames or an input stream (GLOB)

=cut

sub read_pedigree {
    my $self = shift;
    $self->throw("Do not call read_pedigree directly from the base PedIO object - the author of ".ref($self). " did not implement read_pedigree method");
}

=head2 write_pedigree

 Title   : write_pedigree
 Usage   : $pedio->write_pedigree( -pedigree => $pedobj,
				   -pedfile  => ">pedfile.ped",
				   -datfile  => ">datfile.dat");
 Function: Writes a pedigree to a file or filehandle
           as specified by the implementing class 
           (some formats have the pedigree and marker data 
	    stored in the same file rather than in 2 separate files)
 Returns : boolean of success, may throw exception on fatal error 
 Args    : -pedigree => Bio::Pedigree::Pedigree object
           -pedfile => pedigree output location
           -datfile => (if needed) marker data output location
           pedfile/datfile can be filenames or an output stream (GLOB)

=cut

sub write_pedigree {
   my $self = shift;
   $self->throw("Do not call read_pedigree directly from the base PedIO object - the author of ".ref($self). " did not implement read_pedigree method");
}

=head2 close

 Title   : close
 Usage   : $pedio->close();
 Function: close all open filehandles and streams 
           opened by this object
 Returns : NONE
 Args    : NONE


=cut

sub close { 
    my($self) = @_;
    if( defined $self->_pedfh ) {
	$self->_pedfh->close();
    }
    if( defined $self->_datfh ) {
	$self->_datfh->close();
    }
}

=head2 _initialize_fh

 Title   : _initialize_fh
 Usage   : $pedio->_initialize_fh(@args)
 Function: Initialize pedigree data input from file or fh
 Returns : whether or not a pedfh was initialized
 Args    : -pedfile  -- either filehandle, GLOB, or filename

=cut

sub _initialize_fh {
    my ($self,@args) = @_;
    my ($pedfile,$datfile) = $self->_rearrange([qw(PEDFILE DATFILE)], @args);
    my $inited = 0;
    if( $pedfile ) { 
	my $type = ref($pedfile) =~ /GLOB/i ? '-fh' : '-file'; 
	my $fh = new Bio::Root::IO($type => $pedfile);
	if( $fh ) {
	    $self->_pedfh($fh);
	    $inited++;
	}
    }
    if( $datfile ) { 
	my $type = ref($datfile) =~ /GLOB/i ? '-fh' : '-file'; 
	my $fh = new Bio::Root::IO($type => $datfile);
	if( $fh ) {
	    $self->_datfh($fh);
	    $inited++;
	}
    }
    return $inited;
}

=head2 _pedfh

 Title   : _pedfh
 Usage   : $obj->_pedfh($newval)
 Function: 
 Returns : Bio::Root::IO 
 Args    : newvalue (optional)

=cut

sub _pedfh {
    my $obj = shift;
    $obj->{'_pedfh'} = shift if @_;
    return $obj->{'_pedfh'};
}

=head2 _datfh

 Title   : _datfh
 Usage   : $obj->_datfh($newval)
 Function: 
 Returns : Bio::Root::IO object
 Args    : newvalue (optional)

=cut

sub _datfh {
    my $obj = shift;
    $obj->{'_datfh'} = shift if @_;
    return $obj->{'_datfh'};
}

=head2 _load_format_module

 Title   : _load_format_module
 Usage   : *INTERNAL SeqIO stuff*
 Function: Loads up (like use) a module at run time on demand
 Example :
 Returns :
 Args    :

=cut

sub _load_format_module {
  my ($self,$format) = @_;
  my $module = "Bio::Pedigree::PedIO::" . $format;
  my $ok;
  
  eval {
      $ok = $self->_load_module($module);
  };
  if ( $@ ) {
    print STDERR <<END;
$self: $format cannot be found
Exception $@
For more information about the PedIO system please see the PedIO docs.
This includes ways of checking for formats at compile time, not run time
END
  ;
  }
  return $ok;
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
   return 'ped'     if /\.(ped|pedfile|pped|pedigree|p)$/i;
   return 'genbank' if /\.(lapis|lap)$/i;
   return 'xml'     if /\.xml$/i;
}

=head2 DESTROY

 Title   : DESTROY
 Usage   : called automatically
 Function: free allocated resources
 Returns : NONE
 Args    : NONE


=cut

sub DESTROY {
    my $self = shift;
    $self->close();
}

=head2 _digitstr

 Title   : _digitstr
 Usage   : my $str = &_digitstr($ind);
 Function: Get an individual string formatted as a N-digit
           string unless it is 0, N is 4 by default
 Returns : an N-digit string (string)
 Args    : number to format

=cut

sub _digitstr {
    my ($indstr,$N) = @_;
    $N = $DEFAULTDIGITLEN unless (defined $N && $N =~ /^\d+$/ );
    if( $indstr eq '0' || !defined $indstr || $indstr eq '' ) { $indstr = '0';}
    else {
	while( length($indstr) < $N) {
	    # prepend '0' to the string while it is less than 4 digits
	    $indstr = '0' . $indstr;
	}
    }
    return $indstr;
}

1;
