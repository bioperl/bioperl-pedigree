# $Id$
#
# BioPerl module for Bio::Pedigree::PedIO::ped
#
# Cared for by Allen Day <allenday@ucla.edu>
#
# Copyright Allen Day, Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Pedigree::PedIO::ped - Ped format implementation of the PedIO
system for reading linkage format pedigree files

=head1 SYNOPSIS

    use Bio::Pedigree::PedIO;
    my $pedio = new Bio::Pedigree::PedIO(-format => 'linkage');

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

=head1 AUTHOR - Allen Day, Jason Stajich

Email allenday@ucla.edu

Describe contact details here

=head1 APPENDIX

The rest of the documentation details each of the object methods.
Internal methods are usually preceded with a _

=cut

# Let the code begin...

package Bio::Pedigree::PedIO::ped;
use vars qw(@ISA);
use strict;
use Bio::Pedigree::Pedigree;
use Bio::Pedigree::Group;
use Bio::Pedigree::Person;
use Bio::Pedigree::Marker;
use Bio::Pedigree::Result;
use Bio::Pedigree::PedIO;

@ISA = qw(Bio::Pedigree::PedIO );

=head2 read_pedigree

 Title   : read_pedigree
 Usage   : my $ped = $stream->read_pedigree
 Function: Read the pedigree from the stream and instantiate an object 
 Returns : Bio::Pedigree::Pedigree object
 Args    : none

=cut

sub read_pedigree{
  my ($self,@args) = @_;

  if( ! $self->_initialize_datfh(@args) ) {
	$self->throw("Must specify marker data input files for marker format")
  }
  my $pedigree = new Bio::Pedigree::Pedigree();
  my $line;
  # skip leading whitespace lines
  while( defined($line = $self->_readline_dat) && $line !~ /\S/ ){}
  if( ! defined $line ) { $self->throw("no data in marker dat file!") }
  # defines the number of markers
  $line =~ s/^\s+(\S+)/$1/;
  my ($markercount) = split(/\s+/,$line);
  if( !$markercount ) { $self->throw("Ped format: incorrect dat format -- no marker count at top line ") }
  # skip the next line b/c I don't know what to do with it   
  $self->_readline_dat;
  # marker order line
  $line = $self->_readline_dat;
  my (@order) = split (/\s+/,$line);

  my $proband_line     = $self->_readline_dat;
  my $frequency_line   = $self->_readline_dat;
  my $liabilities_line = $self->_readline_dat;
  my $penetrance_line  = $self->_readline_dat;

#warn "proband $proband_line";
#warn "frequency $frequency_line";
#warn "liabilities $liabilities_line";

  foreach ( 1..$markercount ) {
	while( defined($line = $self->_readline_dat) && $line !~ /\S/ ) {}

	$line =~ s/^\s+(\S+)/$1/;
	$line =~ s/\#//g;
	#name may be undefined.  assign it the marker id number if
	#we don't have it.
	my($type,$alleles, $name) = split(/\s+/,$line);
	$name ||= $_;
	#       $name =~ s/\#//;
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

  if( ! $self->_initialize_pedfh(@args) ) {
	$self->throw("Must specify pedigree data input files for marker format")
  }

  my %groups;
  my $fh = $self->_pedfh;
  while( defined( $line = <$fh>) && $line =~ /\S/ ) {
	$line =~ s/^\s+(\S+)/$1/;
	my (@fields) = split(/\s+/,$line);

	#the linkage format
	#my ($groupid,$id,$father,$mother,$child,$patsib,$matsib,$gender,$proband,@results) = @fields;
	my ($groupid,$id,$father,$mother,$gender,$proband,@results) = @fields;
	if( ! defined $groups{$groupid} ) {
	  $groups{$groupid} = new Bio::Pedigree::Group(
												   -center=>'mock',
												   -groupid=>$groupid,
												   -type   =>'FAMILY'
												  );
	}

	my $person = new Bio::Pedigree::Person(-personid => $id,
										   -father   => $father,
										   -mother   => $mother,
										   -gender   => $gender,
										   -proband  => $proband,
										  );
	
	foreach my $marker ( $pedigree->each_Marker ) {
	  my @alleles = splice(@results, 0, $marker->num_result_alleles);
	  my $result = new Bio::Pedigree::Result(-name => $marker->name,
											 -alleles => [ @alleles]);
	  $person->add_Result($result);
	}
	$groups{$groupid}->add_Person($person);
  }
  foreach my $group ( values %groups ) {
	$pedigree->add_Group($group);
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
 Args    : -pedigree => Bio::Pedigree::Pedigree object
           -pedfile => pedigree output location
           -datfile => (if needed) marker data output location
           pedfile/datfile can be filenames or an output stream (GLOB)
 Notes   : CAVEAT! this method does NOT produce valid locus files.

=cut

sub write_pedigree {
    my($self,@args) = @_;
   if( ! $self->_initialize_pedfh(@args) ||
       ! $self->_initialize_datfh(@args) ) {
       $self->throw("Must specify both pedigree and marker data output files for ped format")
   }

#CAVEAT! this method does NOT produce valid locus files.

    my ($pedigree) = $self->_rearrange([qw(PEDIGREE)],@args);
    # write the dat file first
    my @markers = $pedigree->each_Marker;
    $self->_print_dat(sprintf("%2d %d %d %d\n",scalar @markers, 0,0,5));
    $self->_print_dat("0 0.0 0.0 0\n"); # intricacies of the dat format
                                        # I don't understand at this point
    $self->_print_dat(" ", join(" ", 1..scalar @markers), "\n");
    my $quantcount = 0;
    foreach my $marker ( @markers) {
	if( $marker->type eq 'DISEASE' ) {
	    $self->_print_dat(sprintf("%2s %2s #%s\n  ", $marker->type_code,
				      scalar $marker->frequencies,
				      $marker->name));
	} elsif( $marker->type eq 'QUANTITATIVE' ) {
	    $self->_print_dat(sprintf("%2s %2s #%s\n  ", $marker->type_code,
				      $quantcount++,
				      $marker->name));
	} elsif( $marker->type eq 'VARIATION' ) {
	    $self->_print_dat(sprintf("%2s %2s #%s\n  ", $marker->type_code,
				      $marker->known_alleles,
				      $marker->name));
#	    $self->_print_dat(join(' ', $marker->known_alleles), "\n");
		$self->_print_dat(join ' ', map { $marker->get_allele_frequency($_) } reverse $marker->known_alleles);
		$self->_print_dat("\n");
	} else { 
	    $self->warn("Unkown marker ". $marker->name . " skipping...");
	}
    }
    $self->_print_dat("0 0\n","0.00 0.00 0.00 0.00 0.00\n",
		      "1 0.050 0.150\n0.200 0.100 0.400\n");

    # done with dat

    my %personremap;
    my %gendermap = ( 'M' => 1,
		      'F' => 2,
		      'U' => 0);
    $pedigree->calculate_all_relationships;
    foreach my $group ( $pedigree->each_Group ) {
	my $personcount = 1;
	foreach my $person ( $group->each_Person ) {
	  $personremap{$person->personid} = $personcount++;
	  $self->_print_ped(sprintf("%s %2d %2d %2d %2d %2d ",#%2d %d %d ",
								$group->groupid,
								$personremap{$person->personid},
								$personremap{$person->fatherid},
								$personremap{$person->motherid},
#								$personremap{$person->patsibid},
#								$personremap{$person->matsibid},
								$gendermap{$person->gender},
								$person->proband
							   ));

	  foreach my $result ( $person->each_Result ) {
		$self->_print_ped(join(' ', map { sprintf("%5s ", $_)}
							   $result->alleles));

	  }

	  $self->_print_ped("\n");
	}
  }
}

1;
