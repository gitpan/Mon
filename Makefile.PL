#
# $Id: Makefile.PL,v 1.7 2000/02/16 04:17:30 trockij Exp $
#

use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'      => 'Mon',
    'VERSION'   => do { my @r = (q$Name: monperl-0-8 $ =~ /\d+/g); sprintf "%d.%d" x $#r, @r },
);
