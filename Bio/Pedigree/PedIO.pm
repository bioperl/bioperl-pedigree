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

  bioperl-l@bioperl.org            - General discussion
http://bioperl.org/MailList.shtml  - About the mailing lists

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


package Bio::Pedigree::PedIO;
use vars qw(@ISA @EXPORT $DEFAULTDIGITLEN);
use strict;

use Bio::Root::Root;
use Symbol;

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
	return undef unless( &_load_format_module($format) );
	return "Bio::Pedigree::PedIO::$format"->new(@args);
    }
}

# _initialize is chained for all SeqIO classes

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
   my ($self,@args) = @_;
   $self->throw("Do not call read_pedigree directly from the base PedIO object");
   
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
   my ($self,@args) = @_;
   $self->throw("Do not call this method directly from the base PedIO object");

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
	close($self->_pedfh);
    }
    if( defined $self->_datfh ) {
	close($self->_datfh);
    }
}

=head2 _initialize_pedfh

 Title   : _initialize_pedfh
 Usage   : $pedio->_initialize_pedfh(@args)
 Function: Initialize pedigree data input from file or fh
 Returns : whether or not a pedfh was initialized
 Args    : -pedfile  -- either filehandle, GLOB, or filename

=cut

sub _initialize_pedfh {
    my ($self,@args) = @_;
    my $fh;
    $self->{'_readbufferped'} = '';
    my ($pedfile) = $self->_rearrange([qw(PEDFILE)], @args);
    return undef if( ! defined $pedfile );
    
    if( ref($pedfile) =~ /GLOB/i ) {
	$fh = $pedfile;
    } elsif( defined $pedfile && $pedfile ne '' ) {
	$fh = Symbol::gensym();
	open ($fh,$pedfile) || $self->throw("Could not open IO for $pedfile: $!");
    } else { return undef; }
    $self->_pedfh($fh) if( defined $fh);
    return defined $fh;
}

=head2 _initialize_datfh

 Title   : _initialize_datfh
 Usage   : $pedio->_initialize_datfh(@args)
 Function: Initialize marker data input from file or fh
 Returns : whether or not a datfh was initialized
 Args    : -datfile -- either filehandle, GLOB, or filename


=cut

sub _initialize_datfh {
   my ($self,@args) = @_;
   my $fh;
   $self->{'_readbufferdat'} = '';
   my ($datfile) = $self->_rearrange([qw(DATFILE)], @args);
   return undef if( ! defined $datfile );
   if( ref($datfile) =~ /GLOB/i ) {
       $fh = $datfile;
   } elsif( defined $datfile && $datfile ne '' ) {
       $fh = Symbol::gensym();
       open ($fh,$datfile) || $self->throw("Could not open IO for $datfile: $!");
   } else { return undef; }
   $self->_datfh($fh) if( defined $fh);
   return defined $fh;
}

=head2 _pedfh

 Title   : _pedfh
 Usage   : $obj->_pedfh($newval)
 Function: 
 Returns : value of _pedfh
 Args    : newvalue (optional)

=cut

sub _pedfh {
   my ($obj,$value) = @_;
   if( defined $value) {
      $obj->{'_pedfh'} = $value;
    }
    return $obj->{'_pedfh'};
}

=head2 _datfh

 Title   : _datfh
 Usage   : $obj->_datfh($newval)
 Function: 
 Returns : value of _datfh
 Args    : newvalue (optional)

=cut

sub _datfh {
   my ($obj,$value) = @_;
   if( defined $value) {
      $obj->{'_datfh'} = $value;
    }
    return $obj->{'_datfh'};
}


=head2 _print_ped

 Title   : _print_ped
 Usage   : $obj->_print_ped(@lines)
 Function:
 Example :
 Returns : writes output for ped file

=cut

sub _print_ped {
    my $self = shift;
    my $fh = $self->_pedfh || \*STDOUT;
    print $fh @_;
}

=head2 _readline_ped

 Title   : _readline_ped
 Usage   : $obj->_readline_ped
 Function: Reads a line of input from ped data.

           Note that this method implicitely uses the value of $/ that is
           in effect when called.

           Note also that the current implementation does not handle pushed
           back input correctly unless the pushed back input ends with the
           value of $/.
 Example :
 Returns : 

=cut

sub _readline_ped {
    my $self = shift;
    my $fh = $self->_pedfh || \*STDIN;
    my $line;
    
    # if the buffer been filled by _pushback then return the buffer
    # contents, rather than read from the filehandle
    if(exists($self->{'_readbufferped'})) {
	$line = $self->{'_readbufferped'};
	delete $self->{'_readbufferped'};	
    } else {
	$line = <$fh>;
    }
    $line =~ s/\r\n/\n/g if (defined $line);
    return $line;
}

=head2 _pushback_ped

 Title   : _pushback_ped
 Usage   : $obj->_pushback_ped($newvalue)
 Function: puts a line previously read with _readline_ped back into a buffer
 Example :
 Returns :
 Args    : newvalue

=cut

sub _pushback_ped {
    my ($obj, $value) = @_;
    $value .= $obj->{'_readbufferped'} if(exists($obj->{'_readbufferped'}));
    $obj->{'_readbufferped'} = $value;
}


=head2 _print_dat

 Title   : _print_dat
 Usage   : $obj->_print_dat(@lines)
 Function:
 Example :
 Returns : writes output for ped file

=cut

sub _print_dat {
    my $self = shift;
    my $fh = $self->_datfh || \*STDOUT;
    print $fh @_;
}

=head2 _readline_dat

 Title   : _readline_dat
 Usage   : $obj->_readline_dat
 Function: Reads a line of input from ped data.

           Note that this method implicitely uses the value of $/ that is
           in effect when called.

           Note also that the current implementation does not handle pushed
           back input correctly unless the pushed back input ends with the
           value of $/.
 Example :
 Returns : 

=cut

sub _readline_dat {
    my $self = shift;
    my $fh = $self->_datfh || \*STDIN;
    my $line;
    
    # if the buffer been filled by _pushback then return the buffer
    # contents, rather than read from the filehandle
    if(exists($self->{'_readbufferdat'})) {
	$line = $self->{'_readbufferdat'};
	delete $self->{'_readbufferdat'};	
    } else {
	$line = <$fh>;
    }
    $line =~ s/\r\n/\n/g if (defined $line);
    return $line;
}

=head2 _pushback_dat

 Title   : _pushback_dat
 Usage   : $obj->_pushback_dat($newvalue)
 Function: puts a line previously read with _readline_dat back into a buffer
 Example :
 Returns :
 Args    : newvalue

=cut

sub _pushback_dat {
    my ($obj, $value) = @_;
    $value .= $obj->{'_readbufferdat'} if(exists($obj->{'_readbufferdat'}));
    $obj->{'_readbufferdat'} = $value;
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
   return 'ped'   if /\.(ped|pedfile|pped|pedigree|p)$/i;
   return 'genbank' if /\.(lapis|lap)$/i;
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
