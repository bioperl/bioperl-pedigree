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

Bio::Pedigree::PedIO::ped.pm - Ped format implementation of the PedIO
system for reading linkage format pedigree files

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
   if( ! $self->_initialize_pedfh(@args) ||
       ! $self->_initialize_datfh(@args) ) {
       $self->throw("Must specify both pedigree and marker data input files for marker format")
   }
   my $pedigree = new Bio::Pedigree;   
   my $line;
   # skip leading whitespace lines
   while( defined($line = $self->_readline_dat) && $line !~ /\S/ ){}
   if( ! defined $line ) { $self->throw("no data in marker dat file!") }
   # defines the number of markers
   my ($markercount) = split(/\s+/,$line);
   if( !$markercount ) { $self->throw("Ped format: incorrect dat format -- no marker count at top") }
   # skip the next line b/c I don't know what to do with it   
   $self->_readline_dat;
   # marker order line
   $line = $self->_readline_dat;
   my (@order) = split (/\s+,$line);
   
   foreach ( 1..$markercount ) {
       while( defined($line = $self->_readline_dat) && $line !~ /\S/ ) {}
       my($type,$alleles, $name) = split(/\s+/,$line);       
       $name =~ s/\#//;
       my $marker;
       if( $type == 1 ) { # dx marker
	   my (@frequencies) = split(/\s+/,$self->_readline_dat);
	   if( ! @frequencies ) { $self->throw("Ped format: incorrect dat format -- no frequencies for dx marker $name") }
	   my ($liabct) = ($self->_readline_dat =~ /^\s*(\d+)/);
	   if( ! $liabct ) { $self->throw("Ped format: incorrect dat format -- no liability class count for dx marker $name")}
	   my %liabs;

	   # artificial liability class labels - just the order they came in
	   foreach ( 1..$liabct ) {
	       $line = $self->_readline_dat;
	       $line =~ s/^\s+(\S+)/$1/;
	       $liabs{$_} = [ split(/\s+/,$line)];
	   }
	   $marker = new Bio::Pedigree::Marker( -verbose => $self->verbose,
						-name => $name,
						-type => 'disease',
	  # some ped fmt dx markers are special!
						-num_result_alleles => 2,
						-frequencies => \@frequencies,
						-liab_classes => \%liabs);
       } elsif( $type == 3 ) {
	   $line = $self->_readline_dat;
	   $line =~ s/^\s+(\S+)/$1/;
	   my( $count,%alleles) = ( 1 );

	   foreach my $freq ( split(/\s+/,$line) ) {
	       $alleles{$count++} = $freq;
	   }

	   $marker = new Bio::Pedigree::Marker(-verbose => $self->verbose,
					       -name    => $name,
					       -type    => 'variation',
					       -alleles => \%alleles);

       } elsif( $type == 5 ) {
	   $marker = new Bio::Pedigree::Marker(-verbose => $self->verbose,
					       -name    => $name,
					       -type    => 'quantitative');
       }
       $pedigree->add_Marker($marker);
   }
   # rest of the datfile can be thrown away
   
   # read in pedigree data
   my %groups;
   while( defined($line = $self->_readline_ped) ) {
       $line =~ s/^\s+(\S+)/$1/;
       my (@fields) = split(/\s+/,$line);
       my ($center,$displayid) = ( 'UNK');
       if( $fields[-1] =~ /CTR=/ ) {
	   $center = (pop @fields =~ /CTR=(\S+)/);
       }
       if( $fields[-1] =~ /ID=/ ) {
	   $displayid = (pop @fields =~ /ID=(\S+)/);
       }       
       my ($groupid,$id,$father,$mother,$child,$patsib,
	   $matsib,$gender,$proband,@results) = @fields;
       if( ! defined $groups{$ctr} ) {
	   $groups{$ctr} = new Bio::Pedigree::Group(-center =>$center,
						    -groupid=>$groupid,
						    -type   =>'FAMILY');
       }
       my $person = new Bio::Pedigree::Person(-personid => $id,
					      -father   => $father,
					      -mother   => $mother,
					      -gender   => $gender,
					      -child    => $child,
					      -display  => $displayid,
					      -patsib   => $patsib,
					      -matsib   => $matsib,
					      -proband  => $proband);
       foreach my $marker ( $group->each_Marker ) {
	   my @alleles = splice(@r, 0, $marker->num_result_alleles);
	   my $result = new Bio::Pedigree::Result(-name => $marker->name,
						  -alleles => [ @alleles]);
	   $person->add_Result($result);
       }
       $group->add_Person($person);
   }  
   return $pedigree;
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
 Args    : -pedigree => Bio::Pedigree object
           -pedfile => pedigree output location
           -datfile => (if needed) marker data output location
           pedfile/datfile can be filenames or an output stream (GLOB)

=cut

sub write_pedigree {
    my($self,@args) = @_;
   if( ! $self->_initialize_pedfh(@args) ||
       ! $self->_initialize_datfh(@args) ) {
       $self->throw("Must specify both pedigree and marker data output files for ped format")
   }

    my ($pedigree) = $self->_rearrange([qw(PEDIGREE)],@args);
    # write the dat file first
    my @markrs = $pedigree->each_Marker;
    $self->_print_dat(sprintf("%2d %d %d %d\n",scalar @markers, 0,0,5));
    $self->_print_dat("0 0.0 0.0 0\n"); # intricacies of the ped format 
                                        # I don't understand at this point
    $self->_print_dat(" ", join(" ", 1..scalar @markers), "\n");
    foreach my $marker ( @markrs) {
	$self->_print_dat(sprintf("%2s 
    }
}


