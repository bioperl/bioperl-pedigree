
#
# BioPerl module for Bio::Pedigree::Result
#
# Cared for by Jason Stajich <jason@bioperl.org>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Pedigree::Result - Allele storage object

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


package Bio::Pedigree::Result;
use vars qw(@ISA);
use strict;
use Bio::Pedigree::ResultI;
use Bio::Root::Root;

@ISA = qw(Bio::Root::Root Bio::Pedigree::ResultI );

=head2 new

 Title   : new
 Usage   : my $result = new Bio::Pedigree::Result(-name     => $name,
						  -alleles  => \@alleles);
 Function: creates a new variation result
 Returns : Bio::Pedigree::Result object
 Args    : All fields are required unless specified as optional
            -name     => unique name for this variation.
            -alleles  => (optional) array ref of alleles to initialize object 

=cut

sub new {
  my($class,@args) = @_;

  my $self = $class->SUPER::new(@args);
  $self->{'_alleles'} = [];
  my ($name,$alleles) = $self->_rearrange([qw(NAME ALLELES)], @args);
  
  if( !defined $name ) {
      $self->throw("Must defined name for a variation result"); 
  }
  $self->name($name);
  if( defined $alleles ) { 
      if( ref($alleles) !~ /array/i ) {
	  $self->warn("Did not define a valid array ref ($alleles) to initialize alleles");
      } else {
	  $self->alleles(@$alleles);
      }      
  }
  return $self;
}

=head2 name

 Title   : name
 Usage   : my $name = $result->name;
 Function: Get/Set the variation name for a result
 Returns : name of the Result Marker 
 Args    : (optional) Marker name to set for result  

=cut

sub name{
    my ($self,$name) = @_;
    if( defined $name ) {
	$self->{'_name'} = $name;
    }
    return $self->{'_name'};
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
    my ($self, @alleles) = @_;
    if( @alleles ) {
	# always sort least to greatest, this
	# does assume that all alleles are numeric, could be a problem.
	my $sort = ( $alleles[0] =~ /^\d+$/ ) ? sub { $b <=> $a} : sub { $b cmp $a} ;
	
	$self->{'_alleles'} = [sort $sort @alleles];       
    }
    return @{$self->{'_alleles'}};
}


1;
