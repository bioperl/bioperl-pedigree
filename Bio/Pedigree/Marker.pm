# $Id$
#
# module for Bio::Pedigree::Marker
#
# Cared for by Jason Stajich  <jason@bioperl.org>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Pedigree::Marker - generic module for managing Marker data

=head1 SYNOPSIS

    use Bio::Pedigree::Marker;
    my $marker = new Bio::Pedigree::Marker(-name        => $name,
					   -type        => $type,
					   -description => $desc
					   -display     => $display_name
					);

=head1 DESCRIPTION

This module manages Pedigree Marker information.  This was originally
written to support the LAPIS system at Duke Center for Human Genetics.
It has been expanded to be general enough for TSC usage as well.

=head1 AUTHOR - Jason Stajich

Email jason-at-bioperl-dot-org

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

# Let the code begin...

package Bio::Pedigree::Marker;
use vars qw(@ISA %MARKERTYPES);
use strict;
use Bio::PopGen::Marker;
use Bio::Pedigree::MarkerI;

@ISA = qw(Bio::PopGen::Marker Bio::Pedigree::MarkerI );


# move this to implementation specific stuff

BEGIN { 
    %MARKERTYPES = ( 'DISEASE'         => 1,
		     'VNTR'            => 2,
		     'VARIATION'       => 3,
		     'BIN'             => 4,
		     'QUANTITATIVE'    => 5,
		     'RFLP'            => 6,
		     'PCR'             => 7,
		     );
}

=head2 new

 Title   : new
 Usage   : my $marker = new Bio::Pedigree::Marker(-name => $name);
 Function: creates a new Bio::Pedigree::MarkerI object
 Returns : CHG::Lapis::Marker
 Args    : -name          => [string] marker name
           -description   => [string] marker description
           -display_name  => [string] a display name for the marker (optional)
           -type          => [string] marker type
           -unique_id     => (optional) [string/int] unique id
           -allele_freq   => (optional) [hash ref] allele frequencies 
 

=cut

sub new {
    my($caller,@args) = @_;
    
    my ($class) = ref($caller) || $caller;
    my $self;
    if( $class =~ /Bio::Pedigree::Marker::(\S+)/ ) {
	$self = $class->SUPER::new(@args);
	$self->_initialize(@args);
    } else {
	my %param = @args;
	@param{ map { lc $_ } keys %param } = values %param; # lowercase keys
	my $type = $param{'-type'} || $param{'-TYPE'} || die("Did not specify a TYPE value for a new Marker");
	$type = lc($type);
	if( defined($type = $class->_load_format_module($type) ) ) {
	    $self = new $type(@args);
	}
    }
    return $self;
}

sub _initialize {
    my ($self,@args) = @_;    
    my ($display,$dname) = $self->_rearrange([qw(DISPLAY 
						 DISPLAY_NAME)], @args);
    $display = $dname if( defined $dname );
    defined $display && $self->display_name($display);
    return;
}

=head2 name

 Title   : name
 Usage   : my $name = $marker->name();
 Function: Get/Set marker name
 Returns : string
 Args    : [optional] marker name to set

=cut

sub name {
    my ($self, $value) = @_;
    if( defined $value || ! defined $self->{'_name'}) {
	$value = '' unless defined $value;
	$self->{'_name'} = $value;
    }
    return $self->{'_name'};
}

=head2 type

 Title   : type
 Usage   : my $type = $marker->type();
 Function: Get/Set marker type
 Returns : string
 Args    : [optional] marker type to set

=cut

sub type {
    my ($self, $value) = @_;
    if( defined $value ) {
	$self->{'_type'} = lc($value);
    }
    return $self->{'_type'};
}

=head2 description

 Title   : description
 Usage   : my $desc = $marker->description();
 Function: Get/Set marker description
 Returns : string
 Args    : [optional] marker description to set

=cut

sub description {
    my ($self, $value) = @_;
    if( defined $value || ! defined $self->{'_desc'}) {
	$value = '' unless defined $value;
	$self->{'_desc'} = $value;
    }
    return $self->{'_desc'};
}

=head2 display_name

 Title   : display_name
 Usage   : $obj->display_name($newval)
 Function: 
 Example : 
 Returns : value of display_name
 Args    : newvalue (optional)


=cut

sub display_name {
    my $self = shift;
    $self->{'_display_name'} = shift if @_;
    return $self->{'_display_name'};

}

=head2 type_code

 Title   : type_code
 Usage   : my $code_type = $marker->type_code();
 Function: Get marker code type
 Returns : integer
 Args    : none

=cut

sub type_code {
    return $MARKERTYPES{uc(shift->type)} || 0;
}

=head2 num_result_alleles

 Title   : num_result_alleles
 Usage   : my $numalleles = $marker->num_result_alleles();
 Function: Get number of results for this type of marker           
 Returns : integer
 Args    : none

=cut

sub num_result_alleles {
    my ($self) = @_;
    $self->throw("Must implement this method(\&".ref($self).
		 "::num_result_alleles, cannot use a default value");
}

=head2 _load_format_module

 Title   : _load_format_module
 Usage   : *INTERNAL Bio::Pedigree::Marker stuff*
 Function: Loads up (like use) a module at run time on demand
 Example :
 Returns :
 Args    :

=cut

sub _load_format_module {
  my ($self, $format) = @_;
  my $ok;
  my $module = "Bio::Pedigree::Marker::".$format;
  eval { 
      $ok = $self->_load_module($module);
      $ok = $module;
  };
  if ( $@ ) {
      print STDERR <<END;
$self: $format cannot be found
Exception $@
For more information about the Bio::Pedigree::Marker system please see
the Bio::Pedigree::Marker docs.  This includes ways of checking for
formats at compile time, not run time
END
;
  }
  return $ok;      
}

__END__
1;
