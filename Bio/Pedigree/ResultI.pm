# $Id$
#
# BioPerl module for Bio::Pedigree::ResultI
#
# Cared for by Jason Stajich <jason@chg.mc.duke.edu>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Pedigree::ResultI - Interface for Marker Results

=head1 SYNOPSIS

    # get a Bio::Pedigree::ResultI object somehow
    print "markername is ", $result->name, " alleles are (",
    join(",", $result->alleles), ")\n";

=head1 DESCRIPTION

This interface encapsulates the information a Marker Result will have.
Disease markers will have single allele results or perhaps 2 alleles
with one allele being the disease status and the second allele the
liability class.  

For standard microsattelite, RFLP, SNP markers 2 alleles will
represent the allele value for each chromosome.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is  an integral part of the evolution  of this and other
Bioperl modules. Send your  comments and suggestions preferably to the
Bioperl mailing list.  Your participation is much appreciated.

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


package Bio::Pedigree::ResultI;
use strict;
use Carp;

sub _abstractDeath {
  my $self = shift;
  my $package = ref $self;
  my $caller = (caller)[1];
  
  confess "Abstract method '$caller' defined in interface Bio::Pedigree::ResultI not implemented by pacakge $package. Not your fault - author of $package should be blamed!";
}

=head2 name

 Title   : name
 Usage   : my $name = $result->name;
 Function: Get/Set the Marker name for a result
 Returns : name of Marker
 Args    : (optional) Marker name to set for result  

=cut

sub name{
    $_[0]->_abstractDeath;
}

=head2 alleles

 Title   : alleles
 Usage   : my @alleles = $result->alleles
 Function: Get/Set the alleles for a result
 Returns : @array of alleles for result  
 Args    : (optional) array of alleles to set 
           (will always overwrite the existing alleles)

=cut

sub alleles{
    $_[0]->_abstractDeath;
}


1;
