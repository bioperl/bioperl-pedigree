# $Id$
#
# BioPerl module for Bio::Pedigree::PedIO::xml
#
# Cared for by Jason Stajich <jason@bioperl.org>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Pedigree::PedIO::xml - Pedigree IO for an internal Pedigree XML format 

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

Email jason@bioperl.org

Describe contact details here

=head1 APPENDIX

The rest of the documentation details each of the object methods.
Internal methods are usually preceded with a _

=cut


# Let the code begin...


package Bio::Pedigree::PedIO::xml;
use vars qw(@ISA);
use strict;

use Bio::Root::RootI;
use Bio::Pedigree::PedIO;
use XML::Writer;
use IO;

@ISA = qw(Bio::Pedigree::PedIO );


=head2 _initialize

 Title   : _initialize
 Usage   : 
 Function: initialization parameters are parsed here in
           the PedIO system instead of in the constructor
 Returns : NONE
 Args    : NO PedIO::xml specific arguments at this time

=cut

# no cmd line arguments to parse here
=head2 read_pedigree

 Title   : read_pedigree
 Usage   : my $pedigree = $pedio->read_pedigree(-pedfile => $pedfile);
 Function: Instatiates a Bio::Pedigree::Pedigree object from a data source
 Returns : Bio::Pedigree object or undef on failed reading 
 Args    : -pedfile  => pedigree input location
           (-datfile is not needed for a lapis format)
           pedfile can be filenames or an input stream (GLOB)
=cut

sub read_pedigree {
    my ($self, @args) = @_;
    $self->_initialize_pedfh(@args); # will default to stdin if no fh specified
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
           (datfile not needed for xml format)

=cut

sub write_pedigree {
    my ($self,@args) = @_;
    $self->_initialize_pedfh(@args);
#    my $out = $self->_pedfh;
    my $outfh = new IO::File(">test.xml");
    my ($pedigree) = $self->_rearrange([qw(PEDIGREE)], @args);
    if( !defined $pedigree || !ref($pedigree) || 
	!$pedigree->isa('Bio::Pedigree::Pedigree') ) {
	$self->warn("Trying to write a pedigree without passing in a pedigree object!");
	return 0;
    }    
    my $writer = new XML::Writer(OUTPUT      => $outfh,
				 DATA_MODE   => 1,
				 DATA_INDENT => 3);
    $writer->comment("Pedigree produced by BioPerl Pedigree Toolkit PedIO::xml module");
    $writer->startTag("PEDIGREE", 
		      'date' => $pedigree->date,
		      $pedigree->comment ? ("comment" => $pedigree->comment) :
		      undef
		      );
    foreach my $marker ( $pedigree->each_Marker ) {
	my %markertag = ( "name" => $marker->name,
			  "type" => lc $marker->type,
			  "display_name" => ($marker->display_name || 
					     $marker->name),
			  "result_allele_count" => $marker->num_result_alleles,
			  );

	if ( defined $marker->description &&  $marker->description ne '' ) {
	    $markertag{'description'} = $marker->description;
	}	
	if( $marker->can('chrom') ) {
	    $markertag{'chrom'} = $marker->chrom;
	}
	$writer->startTag("MARKER", %markertag);
	
	if( $marker->type =~ /disease/i ) {
	    foreach my $liab ( $marker->each_Liability_class ) {
		my ($dom,$het,$rec) = $marker->get_Penetrance_for_Class($liab);
		$writer->startTag("LIAB_CLASS",
				  "name" => $liab);
		$writer->emptyTag("PENETRANCE",
				  "dom"  => $dom,
				  "het"  => $het,
				  "rec"  => $rec);
		$writer->endTag;
	    }
	} elsif( $marker->type =~ /variation/i ) {
	    if( defined (my $seq = $marker->upstream_flanking_seq()) ) {
		$writer->startTag("UPSTREAMSEQ");
		$writer->characters($seq->seq());
		$writer->endTag("UPSTREAMSEQ");
	    }
	    if( defined (my $seq = $marker->dnstream_flanking_seq()) ) {
		$writer->startTag("DNSTREAMSEQ");
		$writer->characters($seq->seq());
		$writer->endTag("DNSTREAMSEQ");
	    }
	    foreach my $allele ( $marker->known_alleles ) {
		$writer->emptyTag("MARKER_ALLELE",
				  "allele" => $allele,
				  "frequency" => $marker->get_allele_frequency($allele));
	    }
	}
	$writer->endTag("MARKER");
    }
    # now let's print the groups and individuals
    

    foreach my $group ( $pedigree->each_Group ) {
	$writer->startTag("GROUP",
			  "id" => $group->groupid,
			  "center" => $group->center,
			  "type" => uc $group->type,
			  "description" => $group->description);	
	foreach my $person ( $group->each_Person ) {
	    my %persontags = ("id" => $person->personid,
			      "displayid" => $person->displayid,
			      "gender" => $person->gender,
			      "father" => $person->fatherid,
			      "mother" => $person->motherid);
	    if( $person->childid ) {
		$persontags{'child'} = $person->childid;
	    }
	    if( $person->patsibid ) {
		$persontags{'patsib'} = $person->patsibid;
	    }
	    if( $person->matsibid ) {
		$persontags{'matsib'} = $person->matsibid;
	    }
	    $writer->startTag("PERSON", %persontags);
			      
	    foreach my $result ( $person->each_Result ) {
		$writer->startTag("RESULT", 
				  "marker" => $result->name);
		foreach my $allele ( $result->alleles ) {
		    $writer->startTag("ALLELE");
		    $writer->characters($allele);
		    $writer->endTag("ALLELE");
		}
		$writer->endTag("RESULT");
	    }
	    $writer->endTag("PERSON");
	}
	$writer->endTag("GROUP");
    }

    $writer->endTag("PEDIGREE");
    $writer->end();
    
    return 1;
}

1;
