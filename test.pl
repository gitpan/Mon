exit;
use Mon::Client;
my $n = new Mon::Client ( host => "localhost" );
die if (!defined $n);
$n->connect;
@l = $n->list_alerthist;
$n->disconnect;

for my $line (sort {$a->{"time"} <=> $b->{"time"}} (@l)) {
    print "$line->{group} $line->{service} $line->{time}\n";
}

exit;
use Mon::Client;

$c = new Mon::Client (
    host => "localhost",
    port => 2583
);

die if (!defined $c);

$c->connect;

die "connect: " . $c->error . "\n" if ($c->error ne "");

%o = $c->list_opstatus;

die "list_opstatus: " . $c->error . "\n" if ($c->error ne "");

$c->quit;

foreach $g (keys %o) {
    foreach $s (keys %{$o{$g}}) {
    	foreach $v (keys %{$o{$g}->{$s}}) {
		print "[$g] [$s] [$v] = [$o{$g}->{$s}->{$v}]\n";
	}
    }
}

__END__
#
# $Id: test.pl,v 1.9 1999/06/16 00:46:25 trockij Exp $
#

use Mon::Client;

$a = new Mon::Client (
	host => "uplift",
);

if (!defined $a->connect) {
    die "could not connect: " . $a->error . "\n";
} else {
    print "connected\n";
}

if ((%o = $a->list_opstatus) == 0) {
    die "could not get optstatus: " . $a->error . "\n";
} else {
    print "got opstatus\n";
}

#$a->username ("mon");
#$a->password ("supermon");
#if (!defined ($a->login)) {
#    die "could not log in: " . $a->error . "\n";
#} else {
#    print "logged in\n";
#}

#if (!defined $a->stop) {
#    die "could not stop: " . $a->error . "\n";
#}

#if (!defined $a->start) {
#    die "could not start: " . $a->error . "\n";
#} else {
#    print "started scheduler\n";
#}

#if (!defined (%o = $a->list_failures)) {
#    die "could not get failures: " . $a->error . "\n";
#}

%d = $a->list_disabled();
if ($a->error) {
    die "could not get disabled: " . $a->error . "\n";
}

#if (!defined (@group = $a->list_group ("software"))) {
#    die "could not list group: " . $a->error . "\n";
#}


#if (!defined ($a->enable_host ("pgupta-dsl"))) {
#    die "could not enable host: " . $a->error . "\n";
#}

#if (!defined (($server, @pids) = $a->list_pids)) {
#    die "could not get failures: " . $a->error . "\n";
#}

if (!defined $a->disconnect) {
    die "could not disconnect: " . $a->error . "\n";
} else {
    print "disconnected\n";
}


&show_disabled;
&show_opstatus;

exit 0;




sub show_disabled {
    print "HOSTS\n";
    foreach $g (keys %{$d{hosts}}) {
	foreach $h (keys %{$d{hosts}{$g}}) {
	    print "group $g [$h]\n";
	}
    }

    print "SERVICES\n";
    foreach $g (keys %{$d{services}}) {
	foreach $s (keys %{$d{services}{$g}}) {
	    print "[$g] [$s]\n";
	}
    }

    print "WATCHES\n";
    foreach $g (keys %{$d{watches}}) {
	print "[$g]\n";
    }
}

sub show_opstatus {
    my ($g, $s, $k);

    print "OPSTATUS\n";
    foreach $g (keys %o) {
    	foreach $s (keys %{$o{$g}}) {
	    foreach $k (keys %{$o{$g}{$s}}) {
	    	print "[$g] [$s] [$k] [$o{$g}{$s}{$k}]\n";
	    }
	}
    }
}
