# $Id$
#
# BioPerl module for Bio::Pedigree::Draw::PedPlot
#
# Cared for by Jason Stajich <jason@chg.mc.duke.edu>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Pedigree::Draw::PedPlot - An object to plot pedigrees

=head1 SYNOPSIS

    use Bio::Pedigree::Draw::PedPlot;
    # get a Bio::Pedigree somehow
    my $plotter = new Bio::Pedigree::Draw::PedPlot();
    $plotter->add_group_to_draw($group,$dxmarker);
    $plotter->write();

=head1 DESCRIPTION

This is an implementation of Bio::Pedigree::Draw::PedRenderI.
This is based on code by Jason Stajich for pedigree plotting in 
PedPlot - see ASHG ..... 
 

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


package Bio::Pedigree::Draw::PedPlot;
use vars qw(@ISA $DEFAULTSTARTX $DEFAULTSTARTY 
	    $COUPLESPACE $GENERATIONSPACE
	    $WIDTH $HEIGHT
	    $LINEWIDTH $LABELFONTSIZE $RESULTFONTSIZE
	    $LINECOLOR $TEXTCOLOR
	    $AFFFILLCOLOR $UNAFFFILLCOLOR);
use strict;

use Bio::Root::RootI;
use Bio::Pedigree::Draw::PedRenderI;
use Bio::Pedigree::Draw::Command;

$DEFAULTSTARTX   = 0;
$DEFAULTSTARTY   = 0;
$COUPLESPACE     = 30;
$GENERATIONSPACE = 50;
$HEIGHT          = 20;
$WIDTH           = 20;
$LINEWIDTH       = 1;
$LABELFONTSIZE   = 8;
$RESULTFONTSIZE  = 6;
$LINECOLOR       = 'BLACK';
$TEXTCOLOR       = 'BLACK';
$AFFFILLCOLOR    = 'BLACK';
$UNAFFFILLCOLOR  = 'WHITE';

@ISA = qw( Bio::Pedigree::Draw::PedRenderI Bio::Root::RootI );

=head2 new

 Title   : new
 Usage   : my $plotter = new Bio::Pedigree::Draw::PedPlot();
 Function: Initializes a Pedigree::Draw::PedPlot object for plotting pedigrees
 Returns : Bio::Pedigree::Draw::PedPlot object
 Args    :

=cut

sub new{
    my($class,@args) = @_;    
    my $self = $class->SUPER::new(@args);

    $self->{'_coveredareas'} = [];
    $self->{'_commands'}     = [];
    return $self;
}

=head2 add_group_to_draw

 Title   : add_group_to_draw
 Usage   : $renderer->add_group_to_draw($group,$marker)
 Function: Draws a group on a page, can be called multiple times
           and will insure that no group overwrites another.

           Data is not final until renderer object is closed 
           (data is synced out to disk/filestream at that point).
 Returns : none 
 Args    : group to draw
           marker which will determine affection status (if not defined 
           affection status will not be reported)

=cut

sub add_group_to_draw {
    my ($self,$group,$marker, $code) = @_;
    if( ! defined $group || ! ref($group) || 
	! $group->isa('Bio::Pedigree::GroupI') ) {
	$self->warn("No valid group passed in to plot");
	return;
    }
    if( $marker && ( ! ref($marker) || 
		     ! $marker->isa('Bio::Pedigree::Marker::disease') ) ) {
	$self->warn("Invalid object passed in for marker - $marker, must have a Bio::Pedigree::Marker::disease object to code for affecction status");
	$marker = undef;
    } elsif( ! defined $code ) {
	$code = 'A';
    }
    
    # make sure that the relationships have been calculated
    $group->calculate_relationships;

    # find the founder
    my @people = $group->each_Person();

    my @founders = $group->find_founders();
    if( ! @founders ) {
	$self->warn("No Founders to be had -- impossible or badly formed pedigree group!");
	return 0;
    } elsif( @founders > 1 ) {
	$self->warn("Currently cannot draw a family with more than one set of founders");
	return 0;
    } 
    if( defined $marker ) { 
	$self->affected_marker($marker->name,$code);
    }
    
    my ($x,$y) = $self->_draw_couple(@{$founders[0]},$DEFAULTSTARTX,
				     $DEFAULTSTARTY);
    return 1;
}

=head2 affected_marker

 Title   : affected_marker
 Usage   : $pedplot->affected_marker($name,$code)
 Function: Get/Set the affected marker and the code to look for
           when drawing individuals
 Returns : 2-pule of name and code if no arguments specified
 Args    : (optional) marker name and code to set

=cut

sub affected_marker {
   my ($self,@args) = @_;
   if( @args ) {
       if( @args != 2 ) { $self->warn("Trying to set affected marker without passing in exactly 2 arguments --". join(' ', @args)); }
       $self->{'_affectedmarker'} = [ @args ];
   }  
   return defined $self->{'_affectedmarker'} ? @{$self->{'_affectedmarker'}} : ('','');
}

=head2 write

 Title   : write
 Usage   : $renderer->write;
 Function: Writes pedigree output to data stream using drawengine
 Returns : boolean of success
 Args    : (optional) drawengine to use


=cut

sub write {
    my ($self, $drawengine) = @_;
    if( ! $drawengine ||
	! ref($drawengine) ||
	! $drawengine->isa('Bio::Pedigree::Draw::GraphicsI') 
	) {
	$self->throw("Asking to draw with engine $drawengine which is not a GrahpicsI object");	
    }
    foreach my $command ( $self->each_Command ) {
	$command->execute($drawengine);
    }
    return 1;
}

sub calibrate {
    my ($self) = @_;
    my ($shiftright,$shiftup) = (0,0);
    if( $self->min_width < 0 ) {
	$shiftright = abs($self->min_width) + $WIDTH;
	$self->{'_min_width'} = 0;
    }
    $self->max_width($self->max_width + $shiftright + $WIDTH);

    if( $self->min_height < 0 ) {
	$shiftup = abs($self->min_height) + $HEIGHT;
	$self->{'_min_height'} = 0;
    }
    $self->max_height($self->max_height + $shiftup + $GENERATIONSPACE);
    foreach my $command ( $self->each_Command ) {
	$command->shift_up($shiftup) if( $shiftup );
	$command->shift_right($shiftright) if( $shiftright);
    }    
}

=head2 add_Command

 Title   : add_Command
 Usage   : $pedplot->add_Command($command)
 Function: Adds a Bio::Pedigree::Draw::Command to the queue for drawing
 Returns : none
 Args    : Bio::Pedigree::Draw::Command


=cut

sub add_Command {
   my ($self,$cmd) = @_;
   if( !$cmd || ! ref($cmd) ||
       ! $cmd->isa('Bio::Pedigree::Draw::Command' ) ){
       
       $self->warn("Cannot call add_Command without a valid Command object -- $cmd -- is not valid");
       return;
   }
   push @{$self->{'_commands'}}, $cmd;
}

=head2 each_Command

 Title   : each_Command
 Usage   : my @commands = $pedplot->each_Command;
 Function: returns the list of Commands that are stored
 Returns : list of Bio::Pedigree::Draw::Command objects
 Args    : none

=cut

sub each_Command {
   my ($self) = @_;
   return @{$self->{'_commands'}};
}

# private helper methods
sub _draw_couple {
    my($self,$father,$mother,$x,$y) = @_;
    
    # need to draw the children first
    my $child = $father->child;
    
    my ($nextx,$nexty) = $self->_draw_children($child->father,$child->mother, 
					       $x, $y + $GENERATIONSPACE );

    my ($couple_center_x) = (($nextx + $x)/2 - $COUPLESPACE);
    
    if(! $child->patsib && ! $child->matsib ) {
	# handle centering different when there is more than one child
	if( $child->child ) {
	    # handle centering different when only child is married
	    $couple_center_x = $nextx - (2*$COUPLESPACE) - (3*$WIDTH/4);
	} else {
	    $couple_center_x = $x - ($COUPLESPACE/2) + ($WIDTH/2);
	}
    }  else { 
	print "using default\n";
    }
    my ($one,$two) = ($father,$mother);
    # if this person is someone's child, draw them first
    if( $mother->father ) { ($two,$one) = ( $father, $mother) }
    ($nextx, $nexty) = $self->_draw_person($one, $couple_center_x - $WIDTH,$y);

    # horiz connection line
    $self->add_Command(new Bio::Pedigree::Draw::LineCommand
		       (-startx     => $couple_center_x,
			-endx       => $nextx + $COUPLESPACE,
			-starty     => $y + ($HEIGHT/2),
			-endy       => $y + ($HEIGHT/2),
			-linewidth  => $LINEWIDTH,
			-color      => $LINECOLOR)
		       );

    # vertical connection line

    $self->add_Command(new Bio::Pedigree::Draw::LineCommand
		       (-startx     => $nextx + ($COUPLESPACE/2),
			-endx       => $nextx + ($COUPLESPACE/2),
			-starty     => $y + ($HEIGHT/2),
			-endy       => $y + $GENERATIONSPACE-($HEIGHT/2),
			-linewidth  => $LINEWIDTH,
			-color      => $LINECOLOR)
		       );
 
    ($nextx, $nexty) = $self->_draw_person($two, $nextx + $COUPLESPACE,$y);
    
    # draw the couple connection lines
    return ($nextx,$nexty);
}

=head2 _draw_children

 Title   : _draw_children
 Usage   :
 Function: Draws all
 Example :
 Returns : 
 Args    : father  - ptr to PersonI object that is a father
           mother  - ptr to PersonI object that is a mother
           xstart  - x-coordinate for top left corner to start drawing
           ystart  - y-coordinate for top left corner to start drawing

=cut

sub _draw_children {
    my ($self, $father,$mother,$x,$y) = @_;
    
    assert( $father->gender eq 'M', 
	    sprintf('Father gender was not "M" (%s)', $father->personid) );
    assert( $mother->gender eq 'F', 
	    sprintf('Mother gender was not "F" (%s)',$mother->personid ) );
    
    my ($nextx,$nexty);

    my $first_p_child = $father->child;
    my $first_m_child = $mother->child;

    assert($first_p_child, 
	   sprintf("Father (%s) did not have a valid child pointer",
		   $father->personid) );
    assert($first_m_child, 
	   sprintf("Mother (%s) did not have a valid child pointer",
		   $mother->personid) );

    if( $first_p_child->personid != $first_m_child->personid ) {
	# multi-married

	printf "multimarried couple (%s,%s)\n",$father->personid, 
	$mother->personid;  
    }
    my $child = $first_p_child;
    
    if( $child->child ) {
     # This child is married, so draw them as a couple first
    	( $nextx,$nexty) = $self->_draw_couple($child->child->father, 
					       $child->child->mother,
					       $x,$y);
    } else {
	($nextx,$nexty) = $self->_draw_person($child, $x,$y);
    }
    print "nextx $nextx\n";    
    # deal with siblings
    if( $child->patsib ) {
	my ($startx) = $nextx + $WIDTH;
	($nextx,$nexty) = $self->_draw_sibling($child->patsib, 
					       'patsib', $startx, $nexty);    
	
    }

    return ($nextx,$nexty);
}

=head2 _draw_sibling

 Title   : _draw_sibling
 Usage   :
 Function: Draw the siblings (recursively)
 Example :
 Returns : 
 Args    :


=cut

sub _draw_sibling {
    my($self,$person,$sibtype,$x,$y) = @_;

    return if( ! defined $person );

    my ($nextx,$nexty);
    if( $person->child ) {
	( $nextx,$nexty) = $self->_draw_couple($person->child->father, 
					       $person->child->mother,
					       $x,$y);
    } else {
	($nextx,$nexty) = $self->_draw_person($person, $x, $y);
    }
    my ($sib) = $person->$sibtype();
    if( defined $sib ) {	
	($nextx, $nexty) = $self->_draw_sibling($sib,$sibtype, $nextx, $y);
    }

    return ($nextx, $nexty);
}

sub _draw_person {
    my ($self,$person,$x,$y) = @_;
    
    my $command;
    my ($marker,$code) = $self->affected_marker();
    my $affstatus = 0;
    if( !defined $marker || $marker ne '' ) {
	my ($result) = ($person->get_Result($marker)->alleles);
	$affstatus = ( defined $result && $result eq $code );
    }
    if( $person->gender eq 'M' ) {
	$self->add_Command( new Bio::Pedigree::Draw::BoxCommand
			    (-startx    => $x,
			     -width     => $WIDTH,
			     -starty    => $y,
			     -height    => $HEIGHT,
			     -linewidth => $LINEWIDTH,
			     -color     => $LINECOLOR,
			     -fillcolor => $affstatus ? $AFFFILLCOLOR : 
			     $UNAFFFILLCOLOR));	       
	
    } elsif( $person->gender eq 'F' ) {
	$self->add_Command( new Bio::Pedigree::Draw::OvalCommand
			    (-startx    => $x,
			     -starty    => $y,
			     -width     => $WIDTH,
			     -height    => $HEIGHT,
			     -linewidth => $LINEWIDTH,
			     -color  => $LINECOLOR,
			     -fillcolor => $affstatus ? $AFFFILLCOLOR :
			     $UNAFFFILLCOLOR
			     )
			    );
    } else {
	$self->throw("Do not know how to draw a person with gender ". $person->gender);
    }
    $self->add_Command( new Bio::Pedigree::Draw::TextCommand
			( -startx    => $x + ($WIDTH/4), 
			  -starty    => $y + $HEIGHT,
			  -text      => $person->personid,
			  -fontsize  => $LABELFONTSIZE,
			  -direction => 'horizontal')
			);
    if( $person->father ) {
	$self->add_Command(new Bio::Pedigree::Draw::LineCommand
			   (-startx     => $x + ($WIDTH/2),
			    -endx       => $x + ($WIDTH/2),
			    -starty     => $y,
			    -endy       => $y - ($HEIGHT/2),
			    -linewidth  => $LINEWIDTH,
			    -color      => $LINECOLOR)
			   );
    }
    $x += $WIDTH;
#    $y -= $HEIGHT;
    $self->max_width($x);
    $self->max_height($y + $HEIGHT);
    
    $self->min_width($x);
    $self->min_height($y);
    return ($x,$y);
}

=head2 max_height

 Title   : max_height
 Usage   : my $height = $rendered->max_height
 Function: returns the maximum height needed to draw the pedigree
 Returns : integer
 Args    : none

=cut

sub max_height {
    my ($self,$value) = @_;
    if( defined $value ) {
	$self->{'_max_height'} = MAX($value, $self->{'_max_height'});
    }
    return $self->{'_max_height'};
}

=head2 max_width

 Title   : max_width
 Usage   : my $width = $renderer->max_width
 Function: returns the maximum width needed to draw the pedigree
 Returns : integer
 Args    : none


=cut

sub max_width {
    my ($self,$value) = @_;
    if( defined $value ) {
	$self->{'_max_width'} = MAX($value, $self->{'_max_width'});
    }
    return $self->{'_max_width'};
}


=head2 min_height

 Title   : min_height
 Usage   : my $height = $rendered->min_height
 Function: returns the minimum height needed to draw the pedigree
 Returns : integer
 Args    : none

=cut

sub min_height {
    my ($self,$value) = @_;
    
    if( defined $value ) {
	$self->{'_min_height'} = MIN($value, $self->{'_min_height'});
    }
    return $self->{'_min_height'};
}

=head2 min_width

 Title   : min_width
 Usage   : my $width = $renderer->min_width
 Function: returns the minimum width needed to draw the pedigree
 Returns : integer
 Args    : none


=cut

sub min_width {
    my ($self,$value) = @_;
    if( defined $value ) {
	$self->{'_min_width'} = MIN($value, $self->{'_min_width'});
    }
    return $self->{'_min_width'};
}

sub assert {
    if( ! shift ) { die(shift);   }
}

sub MAX {
    my($a,$b) = @_;
    return $a if( ! $b );
    return $b if( ! $a );

    return $a > $b ? $a : $b;
}

sub MIN {
    my ($a,$b) = @_;
    return $a if( ! $b );
    return $b if( ! $a );

    return $a < $b ? $a : $b;
}

1;
