#!/usr/bin/perl -w
use strict;
use Bio::Pedigree::Draw;
use Bio::Pedigree::PedIO;
use Getopt::Long;
use Carp;
use vars qw($USAGE);

$USAGE = 
qq{pedplot.pl -p pedfile [-d datafile] -f format -o outfile
default format is 'linkage', available formats are 'lapis' and 'linkage'
datafile is only needed when using linkage format
};

my ($dat,$ped,$format,$dformat,$verbose,$out) = ('','','linkage','png');
GetOptions(
	   'd|dat:s'    => \$dat,
	   'p|ped:s'    => \$ped,
	   'f|format:s' => \$format,
	   'o|output:s' => \$out,
	   'oformat|dformat:s' => \$dformat,
	   'v|verbose'  => \$verbose,
	   );

if( ! defined $ped ) { 
    carp("Must define a valid pedfile\n$USAGE");
} elsif( $format =~ /linkage/i && ! defined $dat ) {
    carp("Must define a valid datfile for linkage format\n$USAGE");
}

my $pedio = new Bio::Pedigree::PedIO(-format => $format,
				     -verbose => $verbose);

# -datfile will be ignored for lapis entries
my $pedigree = $pedio->read_pedigree(-datfile => $dat,
				     -pedfile => $ped);

my $draw = new Bio::Pedigree::Draw(-verbose =>$verbose);
my $count = 0;
foreach my $group ( $pedigree->each_Group ) {
    my $outfile = "group_". ($count + 1) . ".$dformat";
    if( $out ) { 
	$outfile = $out;
	$outfile .= ".$count" if ($count > 0 && $format !~ /(ps|post)/i );
    }

    $draw->draw(-pedigree   => $pedigree,
		-group      => $count++,
		-rendertype => 'pedplot',
		-file       => ">$outfile",
		-format     => $dformat);
}
