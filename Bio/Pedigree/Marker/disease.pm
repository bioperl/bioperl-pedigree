# $Id$
#
# module for Bio::Pedigree::Marker::disease
#
# Cared for by Jason Stajich  <jason@bioperl.org>
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
						    -liab_classes=>\%classes,
						    -frequencies=>\@freqs);

=head1 DESCRIPTION

This module manages Disease Marker information.

=head1 AUTHOR - Jason Stajich

Email jason-at-bioperl-dot-org

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

# Let the code begin...

package Bio::Pedigree::Marker::disease;
use vars qw(@ISA $LOADED_IXHASH);
use strict;
use Bio::Pedigree::Marker;

$LOADED_IXHASH = 0;
eval { 
    require Tie::IxHash;
    $LOADED_IXHASH = 1;
};

@ISA = qw(Bio::Pedigree::Marker);

=head2 _initialize

 Title   : _initialize
 Usage   : called by Marker::new
 Function: Initializes disease marker specific constructor arguments 
 Returns : boolean of success
 Args    : (all are optional)
           -liab_classes => hashref of liability class name to 
                            3-pule arrayref of penetrances 
           -frequencies  => arrayref of frequencies for disease status
           -num_result_alleles => [1,2] number of result alleles in pedigree files

=cut

sub _initialize { 
    my ($self, @args) = @_;
    $self->{'_liab_classes'} = {};
    if( $LOADED_IXHASH ) {
	tie %{ $self->{'_liab_classes'} }, 'Tie::IxHash';
    }
    # chained _initialize call to include behaviour of superclass
    $self->SUPER::_initialize(@args);
    my ($liab_classes, $freqs, 
	$numresultalleles) = $self->_rearrange([qw(LIAB_CLASSES 
						   FREQUENCIES
						   NUM_RESULT_ALLELES )],
					       @args);
    if( defined $liab_classes ) {
	if( ref($liab_classes) !~ /hash/i ) {
	    $self->warn("Trying to initialize liab_classes without a properly formatted hash reference");
	} else {
	    while( my ($liab, $pen) = each %{$liab_classes} ) {
		if( ref($pen) !~ /array/i ||
		    scalar @$pen != 3 ) { 
		    $self->warn("Improperly formatted data for liability $liab - $pen, expected 3 entry array ref\n");
			last;
		}		  
		$self->add_Liability_class( $liab, @$pen);
	    }
	}	    
    }
    $freqs            && $self->frequencies(@$freqs);
    $numresultalleles && $self->num_result_alleles($numresultalleles);
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

sub type { return 'DISEASE'; }

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
    # classes (extended pedformat)
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

sub type_code { return 1 }

=head1 Bio::Pedigree::Marker::disease specific methods 

=head2 add_Liability_class

 Title   : add_Liability_class
 Usage   : my $count = $marker->add_Liability_class('N10', 
						    0.000, 0.000, 1.000);
 Function: Add a Liability class and associated penetrance
 Returns : count of total number of liability classes 
 Args    : 4 entry consisting of
           class name,
           dominant homozygous penetrance
           heterozygous penetetrance
           reccessive homozygous penetrance

=cut

sub add_Liability_class {
    my($self,$class,@pens) =@_;
    if( @pens != 3  ) { 
	$self->warn("Must specify a 4 entry array to add_liability_class");
	return 0;
    }
    $self->{'_liab_classes'}->{uc $class} = [ @pens ];
    return scalar keys %{ $self->{'_liab_classes'} };
}

=head2 each_Liability_class

 Title   : each_Liability_class
 Usage   : my @liab_classes = $marker->each_Liability_class();
 Function: Return a list of each liability class
 Returns : array of liability classes
 Args    : none

=cut

sub each_Liability_class {
    my ($self) = @_;    
    return keys %{$self->{'_liab_classes'}};
}

=head2 remove_Liability_class

 Title   : remove_Liability_class
 Usage   : $marker->remove_Liability_class('N10');
 Function: remove a liability class for a disease marker
 Returns : boolean of success
 Args    : class name

=cut

sub remove_Liability_class {
   my ($self,$class) = @_;
   return 0 if ! defined $class;
   $class = uc $class;
   return 0 if( ! $self->{'_liab_classes'}->{$class} );
   delete $self->{'_liab_classes'}->{$class};
   return 1;
}

=head2 get_Penetrance_for_Class

 Title   : get_Penetrance_for_Class
 Usage   : my ($dom,$het,$rec) = $marker->get_Penetrance_for_Class('N10');
 Function: Retrieves the penetrance associated with a liability class
 Returns : 3-pule array of Dom, Het, and Reccessive penetrance 
 Args    : class name


=cut

sub get_Penetrance_for_Class {
   my ($self,$class) = @_;
   return () if ! defined $class;
   $class = uc $class;
   return ( defined $self->{'_liab_classes'}->{$class} ?
	    @{$self->{'_liab_classes'}->{$class}} : () );
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


__END__
1;
