# $Id$
#
# BioPerl module for Bio::Pedigree::PedIO::linkage
#
# Cared for by Jason Stajich <jason@bioperl.org>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Pedigree::PedIO::linkage - Ped format implementation of the PedIO
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

=head1 AUTHOR - Jason Stajich

Email jason@bioperl.org

Describe contact details here

=head1 APPENDIX

The rest of the documentation details each of the object methods.
Internal methods are usually preceded with a _

=cut

# Let the code begin...

package Bio::Pedigree::PedIO::linkage;
use vars qw(@ISA);
use strict;
use Bio::Pedigree::Pedigree;
use Bio::Pedigree::Group;
use Bio::Pedigree::Person;
use Bio::Pedigree::Marker;
use Bio::Pedigree::PedIO;
use Bio::PopGen::Genotype;

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
   if( $self->_initialize_fh(@args) != 2 ) {
       $self->throw("Must specify both pedigree and marker data input files for marker format");
   }
   my @marker_order;
   # make this a factory object one day
   my $pedigree = new Bio::Pedigree::Pedigree();   
   my $line;
   # skip leading whitespace lines
   my $fh = $self->_datfh;
   while( defined($line = $fh->_readline) && $line !~ /\S/ ){}
   if( ! defined $line ) { $self->throw("no data in marker dat file!") }
   # defines the number of markers
   $line =~ s/^\s+(\S+)/$1/;
   my ($markercount) = split(/\s+/,$line);
   if( !$markercount ) { $self->throw("Ped format: incorrect dat format -- no marker count at top line ") }
   # skip the next line b/c I don't know what to do with it   
   $fh->_readline;
   # marker order line
   $line = $fh->_readline;
   my (@order) = split (/\s+/,$line);
   
   foreach ( 1..$markercount ) {
       while( defined($line = $fh->_readline) && $line !~ /\S/ ) {}
       $line =~ s/^\s+(\S+)/$1/;
       $line =~ s/\#//g;
       my($type,$alleles, $name) = split(/\s+/,$line);       
#       $name =~ s/\#//;
       push @marker_order, $name;
       my $marker;
       if( $type == 1 ) { # dx marker
	   my (@frequencies) = split(/\s+/,$fh->_readline);
	   if( ! @frequencies ) { $self->throw("Ped format: incorrect dat format -- no frequencies for dx marker $name") }
	   my ($liabct) = ($fh->_readline =~ /^\s*(\d+)/);
	   if( ! $liabct ) { $self->throw("Ped format: incorrect dat format -- no liability class count for dx marker $name")}
	   my %liabs;

	   # artificial liability class labels - just the order they came in
	   foreach ( 1..$liabct ) {
	       $line = $fh->_readline;
	       $line =~ s/^\s+(\S+)/$1/;
	       $liabs{$_} = [ split(/\s+/,$line) ];
	   }
	   $marker = new Bio::Pedigree::Marker( -verbose => $self->verbose,
						-name => $name,
						-type => 'disease',
	  # some ped fmt dx markers are special!
						-num_result_alleles => 2,
						-frequencies => \@frequencies,
						-liab_classes => \%liabs);
       } elsif( $type == 3 ) {
	   $line = $fh->_readline;
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
   $fh = $self->_pedfh;
   while( defined( $line = $fh->_readline) && $line =~ /\S/ ) {
       $line =~ s/^\s+(\S+)/$1/;
       my (@fields) = split(/\s+/,$line);
       my ($center,$displayid) = ( 'UNK');
       if( $fields[-1] =~ /CTR=/ ) {
	   ($center) = ((pop @fields) =~ /CTR=(\S+)/);
       }
       if( $fields[-1] =~ /ID=/ ) {
	   ($displayid) = ((pop @fields) =~ /ID=(\S+)/);
       }              
       my ($groupid,$id,$father,$mother,$child,$patsib,
	   $matsib,$gender,$proband,@results) = @fields;
       if( ! defined $groups{"$center\_$groupid"} ) {
	   $groups{"$center\_$groupid"} = new Bio::Pedigree::Group
	       (-center   =>$center,
		-group_id =>$groupid,
		-type     =>'FAMILY');
       }
       my $person = new Bio::Pedigree::Person(-person_id   => $id,
					      -father_id   => $father,
					      -mother_id   => $mother,
					      -gender      => $gender,
					      -child_id    => $child,
					      -display_id  => $displayid,
					      -patsib_id   => $patsib,
					      -matsib_id   => $matsib,
					      -proband     => $proband);

       foreach my $marker ( map { $pedigree->get_Marker($_) } @marker_order ) {
	   my @alleles = splice(@results, 0, $marker->num_result_alleles);
	   my $result = new Bio::PopGen::Genotype(-marker_name => $marker->name,
						  -alleles => [ @alleles]);
	   $person->add_Genotype($result);
       }
       $groups{"$center\_$groupid"}->add_Person($person);
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

=cut

sub write_pedigree {
    my($self,@args) = @_;
    if( $self->_initialize_fh(@args) != 2 ) {
	$self->throw("Must specify both pedigree and marker data output files for ped format");
    }
    
    my ($pedigree) = $self->_rearrange([qw(PEDIGREE)],@args);
    # write the dat file first
    my @markers = $pedigree->each_Marker;
    my $fh = $self->_datfh;
    $fh->_print(sprintf("%2d %d %d %d\n",scalar @markers, 0,0,5));
    $fh->_print("0 0.0 0.0 0\n"); # intricacies of the dat format 
                                  # I don't understand at this point
    $fh->_print(" ", join(" ", 1..scalar @markers), "\n");
    my $quantcount = 0;
    foreach my $marker ( @markers) {
	if( $marker->type eq 'DISEASE' ) {
	    $fh->_print(sprintf("%2s %2s #%s", $marker->type_code,
				scalar $marker->frequencies,
				$marker->name));
	} elsif( $marker->type eq 'QUANTITATIVE' ) {
	    $fh->_print(sprintf("%2s %2s #%s", $marker->type_code,
				$quantcount++,
				$marker->name));
	} elsif( $marker->type eq 'VARIATION' ) {
	    $fh->_print(sprintf("%2s %2s #%s", $marker->type_code,
				$marker->known_alleles,
				$marker->name));
	    $fh->_print(join(' ', $marker->known_alleles), "\n");
	} else { 
	    $self->warn("Unkown marker ". $marker->name . " skipping...");
	}
    }
    $fh->_print("0 0\n","0.00 0.00 0.00 0.00 0.00\n",
		"1 0.050 0.150\n0.200 0.100 0.400\n");
    
    # done with dat
    my %personremap;
    my %gendermap = ( 'M' => 1,
		      'F' => 2,
		      'U' => 0);
    $pedigree->calculate_all_relationships;
    $fh = $self->_pedfh;
    foreach my $group ( $pedigree->each_Group ) {
	my $personcount = 1;
	foreach my $person ( $group->each_Person ) {
	    $personremap{$person->person_id} = $personcount++;
	    $fh->_print(sprintf("%s %2d %2d %2d %2d %2d %2d %d %d ",
				      $group->group_id, 
				      $personremap{$person->person_id},
				      $personremap{$person->father_id},
				      $personremap{$person->mother_id},
				      $personremap{$person->patsib_id},
				      $personremap{$person->matsib_id},
				      $gendermap{$person->gender},
				      $person->proband
				      ));
	    foreach my $result ( $group->each_Result ) {
		$fh->_print(join(' ', map { sprintf("%5s ")} 
				       $result->alleles));
	    }	    
	    $fh->_print(sprintf("ID=%s CTR=%s", $person->display_id,
				      $group->center));
	    $fh->_print("\n");
	}
    }
}

1;
