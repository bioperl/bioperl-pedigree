# -*-Perl-*-

use Test;
use strict;

BEGIN { 
    use vars qw($NUMTESTS);
    $NUMTESTS = 1;
    plan tests => $NUMTESTS;
}

use Bio::Pedigree::Draw::PedPlot;

use Bio::Pedigree::Draw::PedPlot;
# get a Bio::Pedigree somehow
my $plotter = new Bio::Pedigree::Draw::PedPlot();

ok ($plotter);
