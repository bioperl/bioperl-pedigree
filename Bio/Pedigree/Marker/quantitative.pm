# $Id$
#
# module for Bio::Pedigree::Marker::quatitative
#
# Cared for by Jason Stajich  <jason@chg.mc.duke.edu>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Pedigree::Marker::quantitative - module for managing Quantitivate
marker data

=head1 SYNOPSIS

    use Bio::Pedigree::Marker;
    my $marker = new Bio::Pedigree::Marker::quantitative
    (-name       => $name,
     -type       => $type,
     -desc       => $desc,
     -comment    => $comment
     );

=head1 DESCRIPTION

This module manages Quantitative Marker information.

=head1 AUTHOR - Jason Stajich

Email jason@chg.mc.duke.edu

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

# Let the code begin...

package Bio::Pedigree::Marker::quantitative;
use vars qw(@ISA);
use strict;
use Bio::Pedigree::Marker;

@ISA = qw(Bio::Pedigree::Marker);

sub _initialize { 
    my ($self, @args) = @_;
    # chained _initialize call to include behaviour of superclass
    $self->SUPER::_initialize(@args);
    my ($comment) = $self->_rearrange([qw(COMMENT)], @args);    
    
    $self->comment($comment);
    return;
}


=head2 name

 Title   : name
 Usage   : my $name = $marker->name();
 Function: Get/Set marker name
 Returns : string
 Args    : [optional] marker name to set

=cut

=head2 type

 Title   : type
 Usage   : my $type = $marker->type();
 Function: Get/Set marker type
 Returns : string
 Args    : [optional] marker type to set

=cut

=head2 description

 Title   : description
 Usage   : my $desc = $marker->description();
 Function: Get/Set marker description
 Returns : string
 Args    : [optional] marker description to set

=cut

=head2 num_result_alleles

 Title   : num_result_alleles
 Usage   : my $numalleles = $marker->num_result_alleles;
 Function: Get number of results for this type of marker           
 Returns : integer
 Args    : none

=cut

sub num_result_alleles {
    # by default 1 allele value for a quantitative marker 

    my ($self, $value) = @_;
    if( defined $value ) {
	$self->{'_numresultalleles'} = $value;
    }
    return $self->{'_numresultalleles'} || 1;
}

=head2 type_code

 Title   : type_code
 Usage   : my $code_type = $marker->type_code();
 Function: Get marker code type
 Returns : integer
 Args    : none

=cut

=head1 Bio::Pedigree::Marker::quantitative specific methods 

=head2 comment

 Title   : comment
 Usage   : my $comment = $marker->comment();
 Function: Get/Set comment
 Returns : the comment associated with this marker
 Args    : [optional] comment value to set

=cut

sub comment { 
    my ($self, $value) = @_;
    if( defined $value || ! defined $self->{'_comment'} ) {
	$value = '' unless defined $value;
	$self->{'_comment'} = $value;
    }
    return $self->{'_comment'};
}

__END__
1;
