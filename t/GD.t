# -*-Perl-*-

use Test;
use strict;

BEGIN { 
    use vars qw($NUMTESTS);
    $NUMTESTS = 2;
    plan tests => $NUMTESTS;
}

use Bio::Pedigree::Draw;
use Bio::Pedigree::Draw::GD;
use Bio::Root::IO;

my $io = new Bio::Root::IO;
my ($fh,$tmpfile) = $io->tempfile();
my $gdengine = new Bio::Pedigree::Draw::GD(-height => 100,
					   -width  => 100,
					   -fh => $fh,
					   -type => 'png');
ok($gdengine);
$gdengine->draw_line('50','50', '60', '60', '1', 'BLACK');

undef $gdengine;
ok ( -s $tmpfile);
