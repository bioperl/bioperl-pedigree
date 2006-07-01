# $Id$
#
# BioPerl module for Bio::Pedigree::Draw::PedPlot
#
# Cared for by Jason Stajich <jason@bioperl.org>
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
PedPlot.  

Stajich JE, Haynes C, Pericak-Vance, Am J Hum Genet, suppl, 1998 63,A242.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to
the Bioperl mailing list.  Your participation is much appreciated.

  bioperl-l@bioperl.org            - General discussion
http://bioperl.org/wiki/Mailing_lists  - About the mailing lists

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


package Bio::Pedigree::Draw::PedPlot;
use vars qw(@ISA $DEFAULTSTARTX $DEFAULTSTARTY 
	    $COUPLESPACE $GENERATIONSPACE
	    $WIDTH $HEIGHT
	    $LINEWIDTH $LABELFONTSIZE $RESULTFONTSIZE
	    $LINECOLOR $TEXTCOLOR
	    $AFFFILLCOLOR $UNAFFFILLCOLOR);
use strict;

use Bio::Root::Root;
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

@ISA = qw( Bio::Root::Root Bio::Pedigree::Draw::PedRenderI  );

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
    $self->{'_min_width'} = $self->{'max_width'} = 0;
    $self->{'_min_height'} = $self->{'max_height'} = 0;
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
    if( defined $marker && ! $code ) { $code = 'A'}
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
	$self->affected_marker($marker,$code);
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
    if( $self->min_width < $WIDTH ) {
	if( $self->min_width > 0 ) {
	    $shiftright = $self->min_width;    
	} else {
	    $shiftright = abs($self->min_width) + $WIDTH;
	}
	
	$self->{'_min_width'} = 0;
    }
    $self->max_width($self->max_width + $shiftright + 2*$WIDTH);

    if( $self->min_height < $HEIGHT ) {
	if( $self->min_height > 0 ) {
	    $shiftup = $self->min_height;    
	} else {
	    $shiftup = abs($self->min_height) + $HEIGHT;
	}
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
    
    my ($nextx,$nexty,
	$firstchild) = $self->_draw_children($child->father,
					     $child->mother, 
					     $x+$WIDTH, $y + $GENERATIONSPACE );
   
    my ($couple_center_x,$childlinestart,$childlineend);
    if(! $child->patsib && ! $child->matsib ) {

	# handle centering different when there is more than one child
	if( $child->child ) {
	    # handle centering different when the only child is married
	    $couple_center_x = $firstchild - ($COUPLESPACE + $WIDTH)/2;
	} else {
	    $couple_center_x = $firstchild - 5/4*$WIDTH;
	}
    }  else { 
	# these are children with multiple sibs
	$couple_center_x = ($firstchild + $nextx)/2 - 5/4*$WIDTH;
	my $lastchild = $child->get_last_sib($father); 
	($childlinestart,$childlineend) = ($firstchild-$WIDTH/2,
					   $nextx-$WIDTH/2);
	# if the last sib in a list is married draw them differently
	if( $lastchild->child ) {
	    $couple_center_x = ( $nextx - ($COUPLESPACE+2*$WIDTH) + $x )/2 - $COUPLESPACE/2; 
	    ($childlinestart,$childlineend) = ( $firstchild-$WIDTH/2,
						$nextx - ($COUPLESPACE+2*$WIDTH)-$WIDTH/2)
	}
    }
    if( defined $childlinestart ) {
	$self->add_Command(new Bio::Pedigree::Draw::LineCommand
			   (-startx     => $childlinestart,
			    -endx       => $childlineend,
			    -starty     => $y + $GENERATIONSPACE - 
			    ($HEIGHT/2),
			    -endy       => $y + $GENERATIONSPACE - 
			    ($HEIGHT/2),
			    -linewidth  => $LINEWIDTH,
			    -color      => $LINECOLOR)
			   );
    } 
    my ($one,$two) = ($father,$mother);
    # if this person is someone's child, draw them first
    if( $mother->father ) { ($two,$one) = ( $father, $mother) }
    ($nextx, $nexty) = $self->_draw_person($one, $couple_center_x - $WIDTH,$y);
    $firstchild = $nextx;
    # draw the couple connection lines
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
    return ($nextx+$WIDTH,$nexty,$firstchild);
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
	    sprintf('Father gender was not "M" (%s)', $father->person_id) );
    assert( $mother->gender eq 'F', 
	    sprintf('Mother gender was not "F" (%s)',$mother->person_id ) );
    
    my ($nextx,$nexty);

    my $first_p_child = $father->child;
    my $first_m_child = $mother->child;

    assert($first_p_child, 
	   sprintf("Father (%s) did not have a valid child pointer",
		   $father->person_id) );
    assert($first_m_child, 
	   sprintf("Mother (%s) did not have a valid child pointer",
		   $mother->person_id) );

    if( $first_p_child->person_id != $first_m_child->person_id ) {
	# multi-married

	printf "multimarried couple (%s,%s)\n",$father->person_id, 
	$mother->person_id;  
    }
    my $child = $first_p_child;
    my $firstchild;

    if( $child->child ) {
     # This child is married, so draw them as a couple first
    	( $nextx,$nexty,$firstchild) = $self->_draw_couple($child->child->father, 
					       $child->child->mother,
					       $x,$y);
    } else {
	($nextx,$nexty) = $self->_draw_person($child, $x,$y);
	$firstchild = $nextx;
    }
    $self->debug( "nextx $nextx\n");    
    # deal with siblings
    if( $child->patsib ) {
	($nextx,$nexty) = $self->_draw_sibling($child->patsib, 
					       'patsib', 
					       $nextx + $WIDTH, 
					       $nexty);	
    }
    return ($nextx,$nexty,$firstchild);
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
					       MAX($self->max_width,$x),$y);
    } else {
	($nextx,$nexty) = $self->_draw_person($person, 
					      MAX($self->max_width,$x),$y);
    }
    my ($sib) = $person->$sibtype();
    if( defined $sib ) {	
	($nextx, $nexty) = $self->_draw_sibling($sib,
						$sibtype, 
						$nextx + $WIDTH, $y);
    }

    return ($nextx, $nexty);
}

sub _draw_person {
    my ($self,$person,$x,$y) = @_;
    
    my $command;    
    my ($marker,$code) = $self->affected_marker();
    my $affstatus = 0;
    if( defined $marker && $marker ne '' ) {
	my ($class,$result) = ($person->get_Genotypes($marker)->get_Alleles);
	$affstatus = ( defined $result && $result eq $code );
    }
    $self->debug("Drawing ".$person->person_id."\n");
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
			( -startx    => $x,
			  -starty    => $y + $HEIGHT,
			  -text      => $person->display_id,
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
