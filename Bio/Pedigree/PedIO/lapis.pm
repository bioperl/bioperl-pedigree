
#
# BioPerl module for Bio::Pedigree::PedIO::lapis
#
# Cared for by Jason Stajich <jason@chg.mc.duke.edu>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Pedigree::PedIO::lapis - DESCRIPTION of Object

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


package Bio::Pedigree::PedIO::lapis;
use vars qw(@ISA);
use strict;

use Bio::Root::RootI;
use Bio::Pedigree;
use Bio::Pedigree::Group;
use Bio::Pedigree::Person;
use Bio::Pedigree::PedIO;
use Bio::Pedigree::Result;

@ISA = qw(Bio::Pedigree::PedIO );

=head2 _initialize

 Title   : _initialize
 Usage   : 
 Function: initialization parameters are parsed here in
           the PedIO system instead of in the constructor
 Returns : NONE
 Args    : NO PedIO::lapis specific arguments at this time

=cut

sub _initialize {
    my ($self, @args) = @_;
    $self->SUPER::_initialize(@args);
    # no cmd line arguments to parse here
}

=head2 read_pedigree

 Title   : read_pedigree
 Usage   : my $pedigree = $pedio->read_pedigree(-pedfile => $pedfile);
 Function: Instatiates a Bio::Pedigree object from a data source
 Returns : Bio::Pedigree object or undef on failed reading 
 Args    : -pedfile  => pedigree input location
           (-datfile is not needed for a lapis format)
           pedfile can be filenames or an input stream (GLOB)
=cut

sub read_pedigree {
    my ($self,@args) = @_;
    $self->_initialize_pedfh(@args);
    my $pedigree = new Bio::Pedigree;
    my ($line,$nMarkers, $nFams,$date,@com,$comment);    

    while( defined($line = $self->_readline_ped) ) {
	last if( $line =~ /\S/ ); # skip leading whitespace lines
    }
    # remove leading whitespace
    $line =~ s/^\s+(\S+)/$1/;

    # read in from header first
    ($nMarkers,$nFams,$date,$comment) = split(/\s+/,$line,4);

    if( !defined $nMarkers || !defined $nFams) {
	$self->throw("Error in header line of lapis ($line) file");
    }
    # save data and comment fields
    $date = undef if ( $date =~ /^\s+$/);

    $pedigree->date($date);
    $pedigree->comment($comment);

    # let's read in all the markers
  MARKERREAD: for(my $mkct = 0; $mkct < $nMarkers; $mkct++ ) {
      my $marker;
      # skip blank lines
      while( defined($line = $self->_readline_ped) ) {
	  last if ( $line =~ /\S/ );
      }
      if( $line =~ /^\s*(1)\s+(\d+)\s+(\S+)\s+(.+)?$/ ) {
	  # if type code is '1' then this must be a disease marker
	  my ($type,$nall,$name, $desc) = ($1,$2,$3,$4);
	  # skip blank lines
	  while( defined($line = $self->_readline_ped) ) {
	      last if ( $line =~ /\S/ );
	  }
	  $line =~ s/^\s+(\S+)/$1/;
	  my @freqs = split(/\s+/, $line);
	  while( defined($line = $self->_readline_ped) ) {
	      last if ( $line =~ /\S/ );
	  }
	  my ($liabct) = ($line =~ /^\s*(\d+)/);
	  if( !defined $liabct )  {
	      $self->throw(sprintf("Filename=%s: lapis parse did not see ".
				   "properly formatted file with a liability count".
				   " in\n '%s'",$self->_filename, $line)); 
	  }
	  my (@pens,@classes);
	  while( defined($line = $self->_readline_ped) ) {
	      next if ( $line =~ /^\s+$/ );
	      $line =~ s/^\s+(\S+)/$1/;
	      chomp($line);
	      push @pens, $line;		
	      last if( @pens == $liabct);
	  }

	  # in case classes list goes onto the next line
	  while( @classes != $liabct ) {
	      while( defined($line = $self->_readline_ped) ) {
		  last if ( $line =~ /\S/ );
	      }
	      if( !defined $line ) {
		  $self->throw(sprintf("Filename=%s: lapis parse did not see ".
				       "properly formatted disease classes".
				       " in \n'%s'",$self->_filename, 
				       $line));
	      }
	      chomp($line);
	      $line =~ s/^\s+(\S+)/$1/;
	      @classes = split(/\s+/,$line);
	  }

	  $marker = new Bio::Pedigree::Marker(-verbose => $self->verbose,
					      -type    => 'disease',
					      -name    => $name,
					      -desc    => $desc || '',
					      -frequencies  => \@freqs,
					      -liab_classes => \@classes,
					      -penetrances  => \@pens, 
					      );	    
      } elsif( $line =~ /^\s*(3)\s+(\S+)\s+(\S+)\s+(\S+)\s+(.+)?$/ ) {
	  my ( $type, $nall, $chrom, $name, $desc) = ($1,$2,$3,$4,$5);
	  my (%alleles,@freqs);
	  # read in allele frequency
	  while( defined($line = $self->_readline_ped) ) {
	      next if ( $line !~ /\S/ );
	      $line =~ s/^\s+(\S+)/$1/;
	      push @freqs, split(/\s+/,$line);
	      last if ( @freqs == $nall );
	  }
	  if( @freqs != $nall ) {
	      $self->throw("Did not find the proper number of alleles for this banded marker ( $name )");
	  }
	  # read in allele names
	  while( defined($line = $self->_readline_ped) ) {
	      next if ( $line !~ /\S/ );
	      $line =~ s/^\s+(\S+)/$1/;
	      foreach my $allele (  split(/\s+/,$line) ) {
		  $alleles{$allele} = shift @freqs;
	      }
	      last if ( scalar(keys %alleles) == $nall );
	  }
	  $marker  = new Bio::Pedigree::Marker(-verbose => $self->verbose,
					       -type    =>'variation',
					       -name    => $name,
					       -chrom   => $chrom,
					       -desc    => $desc || '',
					       -alleles => \%alleles);
      } else { 
	  $self->throw("Do not know how to handle marker for line $line\n");
      }
      $pedigree->add_Marker($marker);
  }

  FAMILYREAD: for( my $famct = 0; $famct < $nFams; $famct++ ) {
      while( defined($line = $self->_readline_ped) ) {
	  last if ( $line =~ /\S/ );
      }
      # remove leading whitespace
      $line =~ s/\s+(\S+)/$1/;
      my ($nInds, $dbledinds, $FTYPE, 
	  $famnum, $ctr, $desc) = split(/\s+/,$line, 6);
      
      my $group = new Bio::Pedigree::Group(-verbose => $self->verbose,
					    -groupid => $famnum,
					    -center  => $ctr,
					    -type    => $FTYPE,
					    -desc    => $desc);
      for ( my $indct = 0; $indct < $nInds; $indct++ ) {
	  while( defined($line = $self->_readline_ped) ) {
	      last if ( $line =~ /\S/ );
	  }
	  my ($indnum,$father,$mother,
	      $gender, @results) = split(/\s+/,$line);

	  my $person = new Bio::Pedigree::Person(-verbose => $self->verbose,
						 -personid   => $indnum,
						 -fatherid   => $father,
						 -motherid   => $mother,
						 -gender     => $gender);
	  my $result_num = scalar @results;
	  foreach my $marker ( $pedigree->each_Marker ) {
	      my @mkresult;
	      my $zero;
	      while( scalar @mkresult < $marker->num_result_alleles) {
		  my $val = shift @results;
		  $zero = ( $val =~ /^0$/ );
		  push (@mkresult,$val);
	      }
	      # there is no need to store empty values
	      next if ( $zero );
	      my $result = new Bio::Pedigree::Result( -name => $marker->name,
						      -alleles => [@mkresult]);

	      $person->add_Result($result);
	  }
	  $group->add_Person($person);
      }
      for( my $dblct = 0; $dblct < $dbledinds; $dblct++ ){
	  while( defined($line = $self->_readline_ped) ) {
#	      # stop if line has anything that is not whitespace
	      last if ( $line =~ /\S/ );
	  }
#	  my ($id, $dbledid) = split(/\s+/,$line);
#	  $group->add_DoubledPerson(-id => $id,
#				     -dbledid => $dbledid);
      }

      while( defined($line = $self->_readline_ped) ) {
	  last if ( $line =~ /\S/ );
      }
      if( $line !~ /7000/ ) {
	  $self->throw("Last line of family did not end in 7000, was $line");
      }
      $pedigree->add_Group($group);
  }
    return $pedigree;

}

=head2 write_pedigree

 Title   : write_pedigree
 Usage   : $pedio->write_pedigree( -pedigree => $pedobj,
				   -pedfile  => ">pedfile.ped");
 Function: Writes a pedigree to a file or filehandle
           as specified by the implementing class 
           (some formats have the pedigree and marker data 
	    stored in the same file rather than in 2 separate files)
 Returns : boolean of success, may throw exception on fatal error 
 Args    : -pedigree => Bio::Pedigree object
           -pedfile / -pedfh => pedigree output location
           -datfile / -datfh => (if needed) marker data output location

=cut

sub write_pedigree {
    my ($self,@args) = @_;
    $self->_initialize_pedfh(@args);
    my ($pedigree) = $self->_rearrange([qw(PEDIGREE)], @args);
    if( !defined $pedigree || !ref($pedigree) || 
	!$pedigree->isa('Bio::Pedigree') ) {
	$self->warn("Trying to write a pedigree without passing in a pedigree object!");
	return 0;
    }
    my @fams = $pedigree->each_Group;
    my @mkrs = $pedigree->each_Marker;
	
    # print header line
    $self->_print_ped( sprintf("%2d %4d  %s %s\n\n", 
			       scalar @mkrs, scalar @fams, $pedigree->date,
			       $pedigree->comment));
    
    # now let's print the markers
    foreach my $marker ( @mkrs ) {	
	if( uc($marker->type) eq 'DISEASE') {
	    my @freqs = $marker->frequencies;
	    # print marker line
	    $self->_print_ped( sprintf("%2d %3d  %s %s\n",
				       $marker->type_code,
				       scalar @freqs,
				       $marker->name,
				       $marker->description));
	    # print frequencies
	    $self->_print_ped( join(" ", @freqs), "\n");
	    my @liabs = $marker->liab_classes;
	    my @pens = $marker->penetrances;
	    $self->_print_ped( sprintf("%3d\n", scalar @liabs));
	    foreach my $pen ( @pens ) {
		$self->_print_ped( sprintf(" %s\n", $pen) ); 
	    }
	    $self->_print_ped( join( " ", @liabs), "\n" );
	} elsif( uc($marker->type) eq 'VARIATION' ) {
	    my @alleles = $marker->known_alleles;
	    # print marker line
	    $self->_print_ped( sprintf("%2d %2d  %s %s\n",
				       $marker->type_code,
				       scalar @alleles,
				       $marker->name,
				       $marker->description));
	    my (@a,@f);
	    foreach my $allele ( @alleles ){
		push @f, sprintf("%6.4f",
				 $marker->get_allele_frequency($allele));
		push @a, sprintf("%-6s",$allele);
	    }
	    $self->_print_ped(join(" ", @f), "\n");
	    $self->_print_ped(join(" ", @a), "\n");
	    
	} else {
	    $self->throw("Type ". uc $self->type. " support not implemented");
	}
	$self->_print_ped( "\n" );
    }

    # now lets print the families
    foreach my $group ( @fams ) {
	my @inds = $group->each_Person();
#	my @dbled = $family->get_DoubledPersonIds(-type => 'id');
	
	$self->_print_ped(sprintf("%4s  %2s  %s %s %s %s\n",
				  scalar @inds,
				  0,
				  #scalar @dbled, 
				  $group->type,
				  $group->groupid,
				  $group->center,
				  $group->description));
	foreach my $person ( @inds ) {
	    my @results;	    
	    foreach my $marker ( @mkrs ) {
		my $r = $person->get_Result($marker->name);
		foreach ( 0..( $marker->num_result_alleles - 1)) {
                    # default to 0 if we don't have a result for a marker
		    my $allele = ( defined $r) ? ($r->alleles)[$_] : 0;
		    push @results, sprintf('%-3s', $allele);
		}
	    }
	    $self->_print_ped(sprintf("%4s %4s %4s %2s %s\n", 
				  &_digitstr($person->personid),
				  &_digitstr($person->fatherid),
				  &_digitstr($person->motherid),
				  $person->gender,
				  join(" ", @results) )
			  );	    
	}
#	foreach my $double ( @dbled ) {
#	    $self->_print( sprintf("%4s %4s\n",
#				   &_digitstr($double),
#				   &_digitstr($group->get_DoubledPerson(-id=>$double))));
#	}
	$self->_print_ped(sprintf("%4s\n", '7000'));
		      
    }
    return 1;
}
