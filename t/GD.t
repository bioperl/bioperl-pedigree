# -*-Perl-*-

use strict;
use vars qw($error $NUMTESTS);

BEGIN { 

    $error = 0;
    $NUMTESTS = 2;

    eval { require Test; };
    if( $@ ) {
	use lib 't';
    }
    use Test;
    plan tests => $NUMTESTS;

    eval { require GD; 
	   require Bio::Pedigree::Draw::GD;
	   require Bio::Pedigree::Draw;
       };
    if( $@ ) {
	print STDERR "cannot load a module GD or Tie::IxHash, skipping tests\n";
	$error = 1;
    }
}
END {
    for ($Test::ntest..$NUMTESTS) {
	skip("unable to run all of the Draw tests, check your GD installation",1);
    }
}

if( $error == 1 ) {
    exit(0);
}


use Bio::Root::IO;

my $gd = new GD::Image(1,1);
my $type = $gd->can('png') ? 'png' : 'gif';

my $io = new Bio::Root::IO;
my ($fh,$tmpfile) = $io->tempfile();
my $gdengine = new Bio::Pedigree::Draw::GD(-height => 100,
					   -width  => 100,
					   -fh => $fh,
					   -type => $type);
ok($gdengine);
$gdengine->draw_line('50','50', '60', '60', '1', 'BLACK');

undef $gdengine;
ok ( -s $tmpfile);
