
#
# BioPerl module for Bio::Pedigree::PedIO::lapis
#
# Cared for by Jason Stajich <jason@bioperl.org>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Pedigree::PedIO::lapis - PedIO implementation which processes LAPIS format files.

=head1 SYNOPSIS

    use Bio::Pedigree::PedIO;
    my $pedio = new Bio::Pedigree::PedIO(-format => 'lapis');
    my $pedigree = $pedio->read_pedigree(-pedfile => 'project1.lap' );    

=head1 DESCRIPTION

This implementation reads and writes filestreams in the standard LAPIS
 format (unpublished).

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


package Bio::Pedigree::PedIO::lapis;
use vars qw(@ISA);
use strict;

use Bio::Root::RootI;
use Bio::Pedigree::Pedigree;
use Bio::Pedigree::Group;
use Bio::Pedigree::Person;
use Bio::Pedigree::PedIO;
use Bio::Popgen::Genotype;

@ISA = qw(Bio::Pedigree::PedIO );

=head2 _initialize

 Title   : _initialize
 Usage   : 
 Function: initialization parameters are parsed here in
           the PedIO system instead of in the constructor
 Returns : NONE
 Args    : NO PedIO::lapis specific arguments at this time

=cut

# no cmd line arguments to parse here

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

    # defaults to stdin if no pedfile is specified
    if( ! $self->_initialize_fh(@args) ) {
	$self->_initialize_fh(-pedfile => \*STDIN );
    }
    my $pedigree = new Bio::Pedigree::Pedigree;
    my ($line,$nMarkers, $nFams,$date,@com,$comment);    

    # skip blank lines
    my $fh = $self->_pedfh;
    while( defined($line = $fh->_readline) && $line !~ /\S/ ) {}
    $self->throw("premature end of lapis file") unless defined $line;
    # remove leading, trailing whitespace
    $line =~ s/^\s+(\S+)/$1/ && $line =~ s/(\S+)\s+$/$1/;

    # read in from header first
    ($nMarkers,$nFams,$date,$comment) = split(/\s+/,$line,4);
    
    if( !defined $nMarkers || !defined $nFams) {
	$self->throw("Error in header line of lapis ($line) file");
    }
    # save data and comment fields
    ( $date !~ /^\s+$/) && $pedigree->date($date);
    $pedigree->comment($comment);

    # let's read in all the markers
  MARKERREAD: foreach ( 1..$nMarkers ) {
      my $marker;
      # skip blank lines
      while( defined($line = $fh->_readline) && $line !~ /\S/ ){}
      $self->throw("premature end of lapis file") unless defined $line;
      if( $line =~ /^\s*(1)\s+(\d+)\s+(\S+)\s+(.+)?$/ ) {
	  # if type code is '1' then this must be a disease marker
	  my ($type,$nall,$name, $desc) = ($1,$2,$3,$4);
	  # skip blank lines
	  while( defined($line = $fh->_readline) ) {
	      last if ( $line =~ /\S/ );
	  }
	  $line =~ s/^\s+(\S+)/$1/;
	  my @freqs = split(/\s+/, $line);
	  while( defined($line = $fh->_readline) && $line !~ /\S/ ) {}
	  $self->throw("premature end of lapis file") unless defined $line;

	  my $liabct;
	  if( !defined $line || ! (($liabct) = ($line =~ /^\s*(\d+)/)) )  {
	      $self->throw(sprintf("Filename=%s: lapis parse did not see ".
				   "properly formatted file with a liability count".
				   " in\n '%s'",$self->_filename, $line)); 
	  }
	  
	  my (@pens,@classes, %liabclasses);
	  while( defined($line = $fh->_readline) ) {
	      next if ( $line =~ /^\s+$/ );
	      # remove leading spaces
	      $line =~ s/^\s+(\S+)/$1/;
	      push @pens, [ split(/\s+/,$line) ];		
	      last if( @pens == $liabct);
	  }
	  # in case classes list goes onto the next line
	  while( @classes != $liabct ) {
	      while( defined($line = $fh->_readline) && $line !~ /\S/ ){}
	      if( !defined $line ) {
		  $self->throw(sprintf("Filename=%s: lapis parse did not see ".
				       "properly formatted disease classes".
				       " in \n'%s'",$self->_filename, 
				       $line));
	      }
	      # remove leading and trailing spaces
	      chomp($line);
	      $line =~ s/^\s+(\S+)/$1/;
	      push @classes, split(/\s+/,$line);
	  }
	  foreach my $class ( @classes ) {
	      $liabclasses{$class} = shift @pens;
	  }
	  if (@pens ) {
	      $self->warn("Liability classes do not equal number of penetrances\n");
	  }
	  $marker = new Bio::Pedigree::Marker(-verbose => $self->verbose,
					      -type    => 'disease',
					      -name    => $name,
					      -desc    => $desc || '',
					      -frequencies  => \@freqs,
					      -liab_classes => \%liabclasses,
					      );	    
      } elsif( $line =~ /^\s*(3)\s+(\S+)\s+(\S+)\s+(\S+)\s+(.+)?$/ ) {
	  my ( $type, $nall, $chrom, $name, $desc) = ($1,$2,$3,$4,$5);
	  my (%alleles,@freqs);
	  # read in allele frequency
	  while( defined($line = $fh->_readline) ) {
	      next if ( $line !~ /\S/ );
	      $line =~ s/^\s+(\S+)/$1/;
	      push @freqs, split(/\s+/,$line);
	      last if ( @freqs == $nall );
	  }
	  if( @freqs != $nall ) {
	      $self->throw("Did not find the proper number of alleles for this banded marker ( $name )");
	  }
	  # read in allele names
	  while( defined($line = $fh->_readline) ) {
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

  FAMILYREAD: foreach (1..$nFams) {
      while( defined($line = $fh->_readline) && $line !~ /\S/ ){}
      $self->throw("premature end of lapis file") unless defined $line;

      # remove leading whitespace
      $line =~ s/\s+(\S+)/$1/;
      my ($nInds, $dbledinds, $FTYPE, 
	  $famnum, $ctr, $desc) = split(/\s+/,$line, 6);
      
      my $group = new Bio::Pedigree::Group(-verbose   => $self->verbose,
					   -group_id => $famnum,
					   -center   => $ctr,
					   -type     => $FTYPE,
					   -desc     => $desc);
      foreach ( 1..$nInds ) {
	  while( defined($line = $fh->_readline) && $line !~ /\S/ ){}
	  $self->throw("premature end of lapis file") unless defined $line;

	  my ($indnum,$father,$mother,
	      $gender, @results) = split(/\s+/,$line);

	  my $person = new Bio::Pedigree::Person(-verbose   => $self->verbose,
						 -person_id => $indnum,
						 -father_id => $father,
						 -mother_id => $mother,
						 -gender    => $gender);
	  my $result_num = scalar @results;
	  foreach my $marker ( $pedigree->each_Marker ) {
	      my @mkresult;
	      my $zero;
	      while( (scalar @mkresult) < $marker->num_result_alleles) {
		  if( ! @results ) {
		      while( defined($line = $fh->_readline) && 
			     $line !~ /\S/ ){}
		      $self->throw("premature end of lapis file")
			  unless defined $line;		      
		      @results = split(/\s+/,$line);
		  }
		  my $val = shift @results;
		  $zero = ( $val =~ /^0$/ );
		  push (@mkresult,$val);
	      }
	      # there is no need to store empty values
	      next if ( $zero );
	      my $result = new Bio::PopGen::Genotype( -marker_name => $marker->name,
						      -alleles => [@mkresult]);

	      $person->add_Genotype($result);
	  }
	  $group->add_Person($person);
      }
      for( my $dblct = 0; $dblct < $dbledinds; $dblct++ ){
	  while( defined($line = $fh->_readline) && $line !~ /\S/ ){}
	  $self->throw("premature end of lapis file") unless defined $line;


#	  my ($id, $dbledid) = split(/\s+/,$line);
#	  $group->add_DoubledPerson(-id => $id,
#				     -dbledid => $dbledid);
      }
      while( defined($line = $fh->_readline) && $line !~ /\S/ ){}
      $self->throw("premature end of lapis file") unless defined $line;
 
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
 Args    : -pedigree => Bio::Pedigree::Pedigree object
           -pedfile / -pedfh => pedigree output location
           -datfile / -datfh => (if needed) marker data output location
           (datfile not needed for lapis format)

=cut

sub write_pedigree {
    my ($self,@args) = @_;
    # defaults to STDOUT if no pedfile is specified
    if( ! $self->_initialize_fh(@args) ) {
	$self->_initialize_fh(-pedfile => \*STDOUT );
    }

    my ($pedigree) = $self->_rearrange([qw(PEDIGREE)], @args);
    if( !defined $pedigree || !ref($pedigree) || 
	!$pedigree->isa('Bio::Pedigree::Pedigree') ) {
	$self->warn("Trying to write a pedigree without passing in a pedigree object!");
	return 0;
    }
    my @fams = $pedigree->each_Group;
    my @mkrs = $pedigree->each_Marker;
    my $fh = $self->_pedfh;
    # print header line
    $fh->_print( sprintf("%2d %4d  %s %s\n\n", 
			 scalar @mkrs, scalar @fams, $pedigree->date,
			 $pedigree->comment));
    
    # now let's print the markers
    foreach my $marker ( @mkrs ) {
	if( uc($marker->type) eq 'DISEASE') {
	    my @freqs = $marker->frequencies;
	    # print marker line
	    $fh->_print( sprintf("%2d %3d  %s %s\n",
				       $marker->type_code,
				       scalar @freqs,
				       $marker->name,
				       $marker->description));
	    # print frequencies
	    $fh->_print( join(" ", @freqs), "\n");
	    my @liabs = $marker->each_Liability_class;
	    
	    $fh->_print( sprintf("%3d\n", scalar @liabs));
	    foreach my $class ( @liabs ) {
		$fh->_print( sprintf(" %s\n", join(' ', $marker->get_Penetrance_for_Class($class)))); 
	    }
	    $fh->_print( join( " ", @liabs), "\n" );
	} elsif( uc($marker->type) eq 'VARIATION' ) {
	    my @alleles = $marker->known_alleles;
	    # print marker line
	    $fh->_print( sprintf("%2d %2d  %s %s\n",
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
	    $fh->_print(join(" ", @f), "\n");
	    $fh->_print(join(" ", @a), "\n");
	    
	} else {
	    $self->throw("Type ". uc $self->type. " support not implemented");
	}
	$fh->_print( "\n" );
    }

    # now lets print the families
    foreach my $group ( @fams ) {
	my @inds = $group->each_Person();
#	my @dbled = $family->get_DoubledPersonIds(-type => 'id');
	
	$fh->_print(sprintf("%4s  %2s  %s %s %s %s\n",
			    scalar @inds,
			    0,
			    #scalar @dbled, 
			    $group->type || '',
			    $group->group_id || '',
			    $group->center || '',
			    $group->description || ''));
	foreach my $person ( @inds ) {
	    my @results;	    
	    foreach my $marker ( @mkrs ) {
		my $r = $person->get_Genotypes($marker->name);
		foreach ( 0..( $marker->num_result_alleles - 1)) {
                    # default to 0 if we don't have a result for a marker
		    my $allele = ( defined $r) ? ($r->get_Alleles)[$_] : 0;
		    push @results, sprintf('%-3s', $allele);
		}
	    }
	    $fh->_print(sprintf("%4s %4s %4s %2s %s\n", 
				  &_digitstr($person->person_id),
				  &_digitstr($person->father_id),
				  &_digitstr($person->mother_id),
				  $person->gender,
				  join(" ", @results) )
			  );	    
	}
#	foreach my $double ( @dbled ) {
#	    $self->_print( sprintf("%4s %4s\n",
#				   &_digitstr($double),
#				   &_digitstr($group->get_DoubledPerson(-id=>$double))));
#	}
	$fh->_print(sprintf("%4s\n", '7000'));
		      
    }
    return 1;
}
