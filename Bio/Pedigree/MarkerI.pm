# $Id$
#
# BioPerl module for Bio::Pedigree::MarkerI
#
# Cared for by Jason Stajich <jason@chg.mc.duke.edu>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Pedigree::MarkerI - Base interface for Markers in Pedigrees

=head1 SYNOPSIS

    # get a Bio::Pedigree::MarkerI object somehow
    print "name is ", $marker->name, "\n";
    print "display name is ", $marker->display_name, "\n";
    print "type is ", $marker->type, "\n";   
    print "number of alleles are ", $marker->num_of_result_alleles, "\n";
    print "description is ", $marker->description, "\n";

=head1 DESCRIPTION

This interface describes the basic Marker object as required for
describing pedigrees for linkage analysis.

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


package Bio::Pedigree::MarkerI;
use strict;

use Carp;

sub _abstractDeath {
  my $self = shift;
  my $package = ref $self;
  my $caller = (caller)[1];
  
  confess "Abstract method '$caller' defined in interface Bio::Pedigree::MarkerI not implemented by pacakge $package. Not your fault - author of $package should be blamed!";
}

=head2 display_name

 Title   : display_name
 Usage   : my $name = $marker->display_name;
 Function: Get/Set Marker Display name
 Returns : string
 Args    : (optional) string to set

=cut

=head2 name

 Title   : name
 Usage   : my $name = $marker->name;
 Function: Get/Set Marker name
 Returns : string
 Args    : (optional) string to set


=cut

sub name{
    $_[0]->_abstractDeath;
}

=head2 type

 Title   : type
 Usage   : my $type = $marker->type;
 Function: Get marker type - valid types are defined by 
           implementing classes
 Returns : type value
 Args    : none

=cut

sub type{
    $_[0]->_abstractDeath;
}

=head2 description

 Title   : description
 Usage   : my $desc = $marker->description();
 Function: Get/Set description for a marker
 Returns : Description string 
 Args    : (optional) string to set as description

=cut

sub description{
    $_[0]->_abstractDeath;
}



=head2 num_of_result_alleles

 Title   : num_of_result_alleles
 Usage   : my $num_alleles_for_result = $marker->num_of_result_alleles;
 Function: returns the number of result alleles for a marker - entirely
           dependant on the marker type.
 Returns : Either '1' or '2' in almost all cases
 Args    : none

=cut

sub num_of_result_alleles{
    $_[0]->_abstractDeath;
}

=head2 type_code

 Title   : type_code
 Usage   : my $code_type = $marker->type_code();
 Function: Get marker code type
 Returns : integer
 Args    : none

=cut

sub type_code {
    $_[0]->_abstractDeath;
}

1;
