# $Id$
#
# module for Bio::Pedigree::Marker::disease
#
# Cared for by Jason Stajich  <jason@chg.mc.duke.edu>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

CHG::Lapis::Marker::disease - module for managing lapis DxMarker data

=head1 SYNOPSIS

    use Bio::Pedigree::Marker;
    my $marker = new Bio::Pedigree::Marker::disease(-name       => $name,
						    -type       => $type,
						    -desc       => $desc,
						    -penetrances=> \@pens,
						    -liab_classes=>\@classes,
						    -frequencies=>\@freqs);

=head1 DESCRIPTION

This module manages Disease Marker information.

=head1 AUTHOR - Jason Stajich

Email jason@chg.mc.duke.edu

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

# Let the code begin...

package Bio::Pedigree::Marker::disease;
use vars qw(@ISA);
use strict;
use Bio::Pedigree::Marker;

@ISA = qw(Bio::Pedigree::Marker);

sub _initialize { 
    my ($self, @args) = @_;
    # chained _initialize call to include behaviour of superclass
    $self->SUPER::_initialize(@args);
    my ($liab_classes, $pen, $freqs) = $self->_rearrange([qw(LIAB_CLASSES 
							     PENETRANCES
							     FREQUENCIES)],
							 @args);
    $liab_classes  && $self->liab_classes(@$liab_classes);
    $pen   && $self->penetrances(@$pen);
    $freqs && $self->frequencies(@$freqs);

    return;
}

=head1 Methods from Bio::Pedigree::Marker

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
 Usage   : my $numalleles = $marker->num_result_alleles();
 Function: Get number of results for this type of marker           
 Returns : integer
 Args    : none

=cut

sub num_result_alleles {
    # by default 1 allele value for a disease marker,
    # this may become 2 in the future when we store
    # classes 
    return 1;
}

=head2 type_code

 Title   : type_code
 Usage   : my $code_type = $marker->type_code();
 Function: Get marker code type
 Returns : integer
 Args    : none

=cut

=head1 Bio::Pedigree::Marker::disease specific methods 

=head2 liab_classes

 Title   : liab_classes
 Usage   : my $liab_classes = $marker->liab_classes();
 Function: Get/Set liab_classes of onset
 Returns : array of liab_classes
 Args    : [optional] liab_classes to set (array)

=cut

sub liab_classes {
    my ($self, @values) = @_;
    if( @values || ! defined $self->{'_liab_classes'} ) {
	@values = () unless @values;
	$self->{'_liab_classes'} = \@values;
    }
    return @{$self->{'_liab_classes'}};
}

=head2 frequencies

 Title   : frequencies
 Usage   : my $freqs = $marker->frequencies();
 Function: Get/Set frequencies 
 Returns : array of frequencies
 Args    : [optional] frequencies to set (array)

=cut

sub frequencies {
    my ($self, @values) = @_;
    if( @values || ! defined $self->{'_frequencies'} ) {
	@values = () unless @values;
	$self->{'_frequencies'} = \@values;
    }
    return @{$self->{'_frequencies'}};
}

=head2 penetrances

 Title   : penetrances
 Usage   : my $pens = $marker->penetrances();
 Function: Get/Set penetrances of onset
 Returns : array of penetrances
 Args    : [optional] penetrances to set (array)

=cut

sub penetrances {
    my ($self, @values) = @_;
    if( @values || ! defined $self->{'_penetrances'} ) {
	@values = () unless @values;
	$self->{'_penetrances'} = [@values];
    }
    return @{$self->{'_penetrances'}};
}


__END__
1;
