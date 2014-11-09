=head1 NAME

Mon::Client - Methods for interaction with Mon client

=head1 SYNOPSIS

    use Mon::Client;

=head1 DESCRIPTION

    Mon::Client is used to interact with "mon" clients. It supports
    a protocol-independent API for retrieving the status of the mon
    server, and performing certain operations, such as disableing hosts
    and service checks.

=head1 METHODS

=over 4

=item new

Creates a new object. A hash can be supplied which sets the
default values. An example which contains all of the variables
that you can initialize:

    $c = new Mon::Client (
    	host => "monhost",
	port => 2583,
	username => "foo",
	password => "bar",
    );

=item password (pw)

If I<pw> is provided, sets the password. Otherwise, returns the
currently set password.

=item host (host)

If I<host> is provided, sets the mon host. Otherwise, returns the
currently set mon host.


=item port (portnum)

If I<portnum> is provided, sets the mon port number. Otherwise, returns the
currently set port number.


=item username (user)

If I<user> is provided, sets the user login. Otherwise, returns the
currently set user login.

=item prot

If I<protocol> is provided, sets the protocol, specified by a string
which is of the form "1.2.3", where "1" is the major revision, "2" is
the minor revision, and "3" is the sub-minor revision.
If I<protocol> is not provided, the currently set protocol is returned.

=item prot_cmp prot_a prot_b

Compares two protocol versions and returns -1, 0, or 1 if prot_a is
less than, equal, or greater than prot_b, respectively. The protocols
must be specified in the form described by above entry for "prot".

=item version

Returns the protocol version of the remote server.

=item error

Returns the error string from set by the last method, or undef if
there was no error.

=item connected

Returns 0 (not connected) or 1 (connected).

=item connect

Connects to the server. If B<host> and B<port> have not
been set, uses the defaults. Returns I<undef> on error.

=item disconnect

Disconnects from the server. Return I<undef> on error.

=item login ( %hash )

B<%hash> is optional, but if specified, should contain two keys,
B<username> and B<password>.

Performs the "login" command to authenticate the user to the server.
Uses B<username> and B<password> if specified, otherwise uses
the username and password previously set by those methods, respectively.


=item disable_watch ( watch )

Disables B<watch>.

=item disable_service ( watch, service )

Disables a service, as specified by B<watch> and B<service>.


=item disable_host ( host )

Disables B<host>.

=item enable_watch ( watch )

Enables B<watch>.

=item enable_service ( watch, service )

Enables a service as specified by B<watch> and B<service>.

=item enable_host ( host )

Enables B<host>.

=item quit

Logs out of the server. This method should be followed
by a call to the B<disconnect> method.

=item list_descriptions

Returns a hash of service descriptions, indexed by watch
and service. For example:

    %desc = $mon->list_descriptions;
    print "$desc{'watchname'}{'servicename'}\n";


=item list_group ( hostgroup )

Lists members of B<hostgroup>. Returns an array of each
member.

=item list_opstatus

Returns a hash of per-service operational statuses, as indexed by
watch and service.

    %s = $mon->list_opstatus;
    foreach $watch (keys %s) {
    	foreach $service (keys %{$s{$watch}}) {
	    foreach $var (keys %{$s{$watch}{$service}}) {
	    	print "$watch $service $var=$s{$watch}{$service}{$var}\n";
	    }
	}
    }

=item list_failures

Returns a hash in the same manner as B<list_opstatus>, but only
the services which are in a failure state.

=item list_successes

Returns a hash in the same manner as B<list_opstatus>, but only
the services which are in a success state.

=item list_disabled

Returns a hash of disabled watches, services, and hosts.

    %d = $mon->list_disabled;

    foreach $group (keys %{$d{"hosts"}}) {
    	foreach $host (keys %{$d{"hosts"}{$group}}) {
	    print "host $group/$host disabled\n";
	}
    }

    foreach $watch (keys %{$d{"services"}}) {
    	foreach $service (keys %{$d{"services"}{$watch}}) {
	    print "service $watch/$service disabled\n";
	}
    }

    for (keys %{$d{"watches"}}) {
    	print "watch $_ disabled\n";
    }

=item list_alerthist

Returns an array of hash references containing the alert history.

    @a = $mon->list_alerthist;

    for (@a) {
    	print join (" ",
	    $_->{"type"},
	    $_->{"watch"},
	    $_->{"service"},
	    $_->{"time"},
	    $_->{"alert"},
	    $_->{"args"},
	    $_->{"summary"},
	    "\n",
	);
    }

=item list_failurehist

Returns an array of hash references containing the failure history.

    @f = $mon->list_failurehist;

    for (@f) {
    	print join (" ",
	    $_->{"watch"},
	    $_->{"service"},
	    $_->{"time"},
	    $_->{"summary"},
	    "\n",
	);
    }

=item list_pids

Returns an array of hash references containing the list of process IDs
of currently active monitors run by the server.

    @p = $mon->list_pids;

    $server = shift @p;

    for (@p) {
    	print join (" ",
	    $_->{"watch"},
	    $_->{"service"},
	    $_->{"pid"},
	    "\n",
	);
    }

=item list_state

Lists the state of the scheduler.

    @s = $mon->list_state;

    if ($s[0] == 0) {
    	print "scheduler stopped since " . localtime ($s[1]) . "\n";
    }

=item start

Starts the scheduler.

=item stop

Stops the scheduler.

=item reset

Resets the server.

=item reload

Causes the server to reload its configuration.

=item term

Terminates the server.

=item set_maxkeep

Sets the maximum number of history entries to store in memory.

=item get_maxkeep

Returns the maximum number of history entries to store in memory.

=item test ( group, service )

Schedules a service to run immediately.

=item ack ( group, service, text )

When B<group/service> is in a failure state,
acknowledges this with B<text>, and disables all further
alerts during this failure period.

=item loadstate ( state )

Loads B<state>.

=item savestate ( state )

Saves B<state>.

=item servertime

Returns the time on the server using the same output as the
time(2) system call.

=item send_trap ( %vars )

Sends a trap to a remote mon server. Here is an example:

    $mon->send_trap (
    	group		=> "remote-group",
	service		=> "remote-service",
	retval		=> 1,
	opstatus	=> "operational status",
	summary		=> "summary line",
	detail		=> "multi-line detailed information",
    );

I<retval> must be a nonnegative integer.

I<opstatus> must be one of I<fail>, I<ok>, I<coldstart>, I<warmstart>,
I<linkdown>, I<unknown>, I<timeout>,  I<untested>.

Returns I<undef> on error.

=back

=cut
#
# Perl module for interacting with a mon server
#
# $Id: Client.pm,v 1.20 1999/06/16 00:46:26 trockij Exp $
#
# Copyright (C) 1998 Jim Trocki
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#

package Mon::Client;
require Exporter;
require 5.004;
use IO::File;
use Socket;
use Text::ParseWords;

@ISA = qw(Exporter);
@EXPORT_OK = qw(%OPSTAT $VERSION);

$VERSION = do { my @r = (q$Revision: 1.20 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r }; # must be all one line, for MakeMaker

my ($STAT_FAIL, $STAT_OK, $STAT_COLDSTART, $STAT_WARMSTART, $STAT_LINKDOWN,
$STAT_UNKNOWN, $STAT_TIMEOUT, $STAT_UNTESTED, $STAT_DEPEND, $STAT_WARN) = (0..9);

my ($TRAP_COLDSTART, $TRAP_WARMSTART, $TRAP_LINKDOWN, $TRAP_LINKUP,
    $TRAP_AUTHFAIL, $TRAP_EGPNEIGHBORLOSS, $TRAP_ENTERPRISE, $TRAP_HEARTBEAT) = (0..7);
	
%OPSTAT = ("fail" => $STAT_FAIL, "ok" => $STAT_OK, "coldstart" =>
   $STAT_COLDSTART, "warmstart" => $STAT_WARMSTART, "linkdown" =>
   $STAT_LINKDOWN, "unknown" => $STAT_UNKNOWN, "timeout" => $STAT_TIMEOUT,
   "untested" => $STAT_UNTESTED, "dependency" => $STAT_DEPEND);

my %TRAPS = ( "coldstart" => $TRAP_COLDSTART, "warmstart" =>
   $TRAP_WARMSTART, "linkdown" => $TRAP_LINKDOWN, "linkup" => $TRAP_LINKUP,
   "authfail" => $TRAP_AUTHFAIL, "egpneighborloss" => $TRAP_EGPNEIGHBORLOSS,
   "enterprise" => $TRAP_ENTERPRISE, "heartbeat" => $TRAP_HEARTBEAT );



sub _sock_write;
sub _sock_readline;
sub _do_cmd;
sub _list_opstatus;
sub _start_stop;

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self  = {};
    my %vars = @_;

    if ($ENV{MONHOST}) {
	$self->{HOST} = $ENV{MONHOST};
    } else {
	$self->{HOST} = undef;
    }

    $self->{CONNECTED} = undef;
    $self->{HANDLE} = new IO::File;

    $self->{PORT} = getservbyname ("mon", "tcp") || 2583;
    $self->{PROT} = "0.38.0";
    $self->{TRAP_PRO_VERSION} = "0.3807";
    $self->{PASSWORD} = undef;
    $self->{USERNAME} = undef;
    $self->{DESCRIPTIONS} = undef;
    $self->{GROUPS} = undef;
    $self->{ERROR} = undef;
    $self->{VERSION} = undef;

    if ($ENV{USER}) {
    	$self->{USERNAME} = $ENV{USER};
    } else {
    	$self->{USERNAME} = (getpwuid ($<))[0];
    }

    $self->{OPSTATUS} = undef;
    $self->{DISABLED} = undef;

    foreach my $k (keys %vars) {
	if ($k eq "host" && $vars{$k} ne "") {
	    $self->{"HOST"} = $vars{$k};
	} elsif ($k eq "port" && $vars{$k} ne "") {
	    $self->{"PORT"} = $vars{$k};
	} elsif ($k eq "username") {
	    $self->{"USERNAME"} = $vars{$k};
	} elsif ($k eq "password") {
	    $self->{"PASSWORD"} = $vars{$k};
	}
    }

    bless ($self, $class);
    return $self;
}

sub password {
    my $self = shift;
    if (@_) { $self->{PASSWORD} = shift }
    return $self->{PASSWORD};
}

sub host {
    my $self = shift;
    if (@_) { $self->{HOST} = shift }
    return $self->{HOST};
}

sub port {
    my $self = shift;
    if (@_) { $self->{PORT} = shift }
    return $self->{PORT};
}

sub username {
    my $self = shift;
    if (@_) { $self->{USERNAME} = shift }
    return $self->{USERNAME};
}


sub prot {
    my $self = shift;

    undef $self->{"ERROR"};

    if (@_) {
	if ($_[0] =~ /^\d+\.\d+\.\d+$/) {
	    $self->{"PROT"} = shift;
	} else {
	    $self->{"ERROR"} = "invalid protocol version";
	    return undef;
	}
    }
    return $self->{"PROT"};
}


sub prot_cmp {
    my $self = shift;

    undef $self->{"ERROR"};

    if ($_[0] !~ /^\d+\.\d+\.\d+$/ ||
	    $_[1] !~ /^\d+\.\d+\.\d+$/) {
	$self->{"ERROR"} = "invalid protocol version";
	return undef;
    }

    my @a = split (/\./, $_[0]);
    my @b = split (/\./, $_[1]);

    for (my $i = 0; $i < @a; $i++) {
    	return -1 if ($a[$i] < $b[$i]);
	return 1  if ($a[$i] > $b[$i]);
    }

    return 0;
}


sub DESTROY {
    my $self = shift;

    if ($self->{CONNECTED}) { $self->disconnect; }
}

sub error {
    my $self = shift;

    return $self->{ERROR};
}

sub connected {
    my $self = shift;

    return $self->{CONNECTED};
}


sub connect {
    my $self = shift;
    my ($iaddr, $paddr, $proto);

    undef $self->{ERROR};

    if ($self->{HOST} eq "") {
    	$self->{ERROR} = "no host defined";
	return undef;
    }

    if (!defined ($iaddr = inet_aton ($self->{HOST}))) {
	$self->{ERROR} = "could not resolve host";
    	return undef;
    }

    if (!defined ($paddr = sockaddr_in ($self->{PORT}, $iaddr))) {
	$self->{ERROR} = "could not generate sockaddr";
    	return undef;
    }

    if (!defined ($proto = getprotobyname ('tcp'))) {
	$self->{ERROR} = "could not getprotobyname for tcp";
    	return undef;
    }

    if (!defined socket ($self->{HANDLE}, PF_INET, SOCK_STREAM, $proto)) {
	$self->{ERROR} = "socket failed, $!";
    	return undef;
    }

    if (!defined connect ($self->{HANDLE}, $paddr)) {
	$self->{ERROR} = "connect failed, $!";
    	return undef;
    }

    $self->{CONNECTED} = 1;
}


sub disconnect {
    my $self = shift;

    undef $self->{ERROR};

    if (!defined close ($self->{HANDLE})) {
	$self->{ERROR} = "could not close: $!";
    	return undef;
    }

    $self->{CONNECTED} = 0;

    return 1;
}


sub login {
    my $self = shift;
    my %l = @_;
    my ($r, $l);

    undef $self->{ERROR};

    $self->{"USERNAME"} = $l{"username"} if (defined $l{"username"});
    $self->{"PASSWORD"} = $l{"password"} if (defined $l{"password"});

    if (!$self->{CONNECTED}) {
    	$self->{ERROR} = "not connected";
	return undef;
    }

    if (!defined $self->{USERNAME} || $self->{USERNAME} eq "") {
    	$self->{ERROR} = "no username";
	return undef;
    }

    if (!defined $self->{PASSWORD} || $self->{PASSWORD} eq "") {
    	$self->{ERROR} = "no password";
	return undef;
    }

    ($r, $l) = _do_cmd ($self->{HANDLE}, "login $self->{USERNAME} $self->{PASSWORD}");

    if (!defined $r) {
	$self->{ERROR} = "error ($l)";
    	return undef;
    } elsif ($r !~ /^220/) {
	$self->{ERROR} = $r;
    	return undef;
    }

    return 1;
}


sub disable_watch {
    my $self = shift;
    my ($watch) = @_;
    my ($r, $l);

    undef $self->{ERROR};

    if (!$self->{CONNECTED}) {
    	$self->{ERROR} = "not connected";
	return undef;
    }

    if ($watch !~ /\S+/) {
    	$self->{ERROR} = "invalid watch";
	return undef;
    }

    ($r, $l) = _do_cmd ($self->{HANDLE}, "disable watch $watch");

    if (!defined $r) {
	$self->{ERROR} = "error ($l)";
    	return undef;
    } elsif ($r !~ /^220/) {
	$self->{ERROR} = $r;
    	return undef;
    }

    return $r;
}


sub disable_service {
    my $self = shift;
    my ($watch, $service) = @_;
    my ($r, $l);

    undef $self->{ERROR};

    if (!$self->{CONNECTED}) {
    	$self->{ERROR} = "not connected";
	return undef;
    }

    if ($watch !~ /\S+/) {
    	$self->{ERROR} = "invalid watch";
	return undef;
    }

    if ($service !~ /\S+/) {
    	$self->{ERROR} = "invalid service";
	return undef;
    }

    ($r, $l) = _do_cmd ($self->{HANDLE}, "disable service $watch $service");

    if (!defined $r) {
	$self->{ERROR} = "error ($l)";
    	return undef;
    } elsif ($r !~ /^220/) {
	$self->{ERROR} = $r;
    	return undef;
    }

    return $r;
}


sub disable_host {
    my $self = shift;
    my (@hosts) = @_;
    my ($r, $l);

    undef $self->{ERROR};

    if (!$self->{CONNECTED}) {
    	$self->{ERROR} = "not connected";
	return undef;
    }

    ($r, $l) = _do_cmd ($self->{HANDLE}, "disable host @hosts");

    if (!defined $r) {
	$self->{ERROR} = "error ($l)";
    	return undef;
    } elsif ($r !~ /^220/) {
	$self->{ERROR} = $r;
    	return undef;
    }

    return $r;
}


sub enable_watch {
    my $self = shift;
    my ($watch) = @_;
    my ($r, $l);

    undef $self->{ERROR};

    if (!$self->{CONNECTED}) {
    	$self->{ERROR} = "not connected";
	return undef;
    }

    if ($watch !~ /\S+/) {
    	$self->{ERROR} = "invalid watch";
	return undef;
    }

    ($r, $l) = _do_cmd ($self->{HANDLE}, "enable watch $watch");

    if (!defined $r) {
	$self->{ERROR} = "error ($l)";
    	return undef;
    } elsif ($r !~ /^220/) {
	$self->{ERROR} = $r;
    	return undef;
    }

    return $r;
}


sub enable_service {
    my $self = shift;
    my ($watch, $service) = @_;
    my ($r, $l);

    undef $self->{ERROR};

    if (!$self->{CONNECTED}) {
    	$self->{ERROR} = "not connected";
	return undef;
    }

    if ($watch !~ /\S+/) {
    	$self->{ERROR} = "invalid watch";
	return undef;
    }

    if ($service !~ /\S+/) {
    	$self->{ERROR} = "invalid service";
	return undef;
    }

    ($r, $l) = _do_cmd ($self->{HANDLE}, "enable service $watch $service");

    if (!defined $r) {
	$self->{ERROR} = "error ($l)";
    	return undef;
    } elsif ($r !~ /^220/) {
	$self->{ERROR} = $r;
    	return undef;
    }

    return $r;
}


sub enable_host {
    my $self = shift;
    my (@hosts) = @_;
    my ($r, $l);

    undef $self->{ERROR};

    if (!$self->{CONNECTED}) {
    	$self->{ERROR} = "not connected";
	return undef;
    }

    ($r, $l) = _do_cmd ($self->{HANDLE}, "enable host @hosts");

    if (!defined $r) {
	$self->{ERROR} = "error ($l)";
    	return undef;
    } elsif ($r !~ /^220/) {
	$self->{ERROR} = $r;
    	return undef;
    }

    return $r;
}

sub version {
    my $self = shift;

    undef $self->{ERROR};

    if (!$self->{CONNECTED}) {
    	$self->{ERROR} = "not connected";
	return undef;
    }

    unless (defined($self->{VERSION})) {
	my ($r, $l);
	($r, $l) = _do_cmd ($self->{HANDLE}, "version");

	if (!defined $r) {
	    $self->{ERROR} = "error ($l)";
	    return undef;
	} elsif ($r !~ /^220/) {
	    $self->{ERROR} = $r;
	    return undef;
	}
	($self->{VERSION} = $l) =~ s/^version\s+//;;
    }

    return $self->{VERSION};
}


sub quit {
    my $self = shift;
    my ($r, $l);

    undef $self->{ERROR};

    if (!$self->{CONNECTED}) {
    	$self->{ERROR} = "not connected";
	return undef;
    }

    ($r, $l) = _do_cmd ($self->{HANDLE}, "quit");

    return $r;
}


sub list_descriptions {
    my $self = shift;
    my ($r, @d, $d, $group, $service, $desc, %desc);

    undef $self->{ERROR};

    my $v = $self->prot_cmp ($self->prot, "0.38.0");
    if (!defined $v) {
	return undef;
    } elsif ($v < 0) {
    	$self->{ERROR} = "list descriptions not supported";
	return undef;
    }

    if (!$self->{CONNECTED}) {
    	$self->{ERROR} = "not connected";
	return undef;
    }

    ($r, @d) = _do_cmd ($self->{HANDLE}, "list descriptions");

    if (!defined $r) {
	$self->{ERROR} = "error (@d)";
    	return undef;
    } elsif ($r !~ /^220/) {
	$self->{ERROR} = $r;
    	return undef;
    }

    return $r if (!defined $r);

    foreach $d (@d) {
	($group, $service, $desc) = split (/\s+/, $d, 3);
	$desc{$group}{$service} = $desc;
    }

    return %desc;
}


sub list_group {
    my $self = shift;
    my ($group) = @_;

    my ($r, $l);

    undef $self->{ERROR};

    if (!$self->{CONNECTED}) {
    	$self->{ERROR} = "not connected";
	return undef;
    }

    if ($group eq "") {
    	$self->{ERROR} = "invalid group";
    	return undef;
    }

    ($r, $l) = _do_cmd ($self->{HANDLE}, "list group $group");

    if ($r =~ /^220/) {
    	$l =~ s/^hostgroup\s+$group\s+//;;
		return split (/\s+/, $l);
    } else {
	$self->{ERROR} = $l;
    	return undef;
    }

}


sub list_opstatus {
    my $self = shift;

    _list_opstatus($self, "list opstatus");
}


sub list_failures {
    my $self = shift;

    _list_opstatus($self, "list failures");
}


sub list_successes {
    my $self = shift;

    _list_opstatus($self, "list successes");
}


sub list_disabled {
    my $self = shift;
    my ($r, @d, %disabled, $h);

    undef $self->{ERROR};

    if (!$self->{CONNECTED}) {
    	$self->{ERROR} = "not connected";
	return undef;
    }

    ($r, @d) = _do_cmd ($self->{HANDLE}, "list disabled");

    if (!defined $r) {
	$self->{ERROR} = $d[0];
    	return undef;
    } elsif ($r !~ /^220/) {
	$self->{ERROR} = $r;
    	return undef;
    }

    foreach $r (@d) {
    	if ($r =~ /^group (\S+): (.*)$/) {
	    foreach $h (split (/\s+/, $2)) {
		$disabled{hosts}{$1}{$h} = 1;
	    }

	} elsif ($r =~ /^watch (\S+) service (\S+)$/) {
	    $disabled{services}{$1}{$2} = 1;

	} elsif ($r =~ /^watch (\S+)/) {
	    $disabled{watches}{$1} = 1;

	} else {
	    next;
	}
    }

    return %disabled;
}


sub list_alerthist {
    my $self = shift;
    my ($r, @h, @alerts, $h, $group, $service, $time, $alert, $args, $summary);

    undef $self->{ERROR};

    if (!$self->{CONNECTED}) {
    	$self->{ERROR} = "not connected";
	return undef;
    }

    ($r, @h) = _do_cmd ($self->{HANDLE}, "list alerthist");

    if (!defined $r) {
	$self->{ERROR} = "error (@h)";
    	return undef;
    } elsif ($r !~ /^220/) {
	$self->{ERROR} = $r;
    	return undef;
    }

    foreach $h (@h) {
    	my ($type, $group, $service, $time, $alert, $args, $summary) =
	    ($h =~ /^(\S+) \s+ (\S+) \s+ (\S+) \s+
		    (\d+) \s+ (\S+) \s+ \(([^)]*)\) \s+ (.*)$/x);
	push @alerts, { type => $type,
		    watch => $group,
		    group => $group,
		    service => $service,
		    time => $time,
		    alert => $alert,
		    args => $args,
		    summary => $summary };
    }

    return @alerts;
}


sub list_failurehist {
    my $self = shift;
    my ($r, @f, $f, $group, $service, $time, $summary, @failures);

    undef $self->{ERROR};

    if (!$self->{CONNECTED}) {
    	$self->{ERROR} = "not connected";
	return undef;
    }

    ($r, @f) = _do_cmd ($self->{HANDLE}, "list failurehist");

    if (!defined $r) {
	$self->{ERROR} = "@f";
    	return undef;
    } elsif ($r !~ /^220/) {
	$self->{ERROR} = $r;
    	return undef;
    }

    foreach $f (@f) {
    	($group, $service, $time, $summary) = split (/\s+/, $f, 4);
	push @failures, {
	    	watch => $group,
		service => $service,
		time => $time,
		summary => $summary
	    };
    }

    return @failures;
}


sub list_pids {
    my $self = shift;
    my ($r, $l, @pids, @p, $p, $pid, $group, $service, $server);

    undef $self->{ERROR};

    if (!$self->{CONNECTED}) {
    	$self->{ERROR} = "not connected";
	return undef;
    }

    ($r, @p) = _do_cmd ($self->{HANDLE}, "list pids");

    if (!defined $r) {
	$self->{ERROR} = "@p";
    	return undef;
    } elsif ($r !~ /^220/) {
	$self->{ERROR} = $r;
    	return undef;
    }

    foreach $p (@p) {
    	if ($p =~ /(\d+) server/) {
	    $server = $1;

	} else {
	    ($pid, $group, $service) = split (/\s+/, $p);
	    push @pids, { watch => $group, service => $service, pid => $pid };
	}
    }

    return ($server, @pids);
}


sub list_state {
    my $self = shift;
    my ($r, $l);

    undef $self->{ERROR};

    if (!$self->{CONNECTED}) {
    	$self->{ERROR} = "not connected";
	return undef;
    }

    ($r, $l) = _do_cmd ($self->{HANDLE}, "list state");

    if (!defined $r) {
	$self->{ERROR} = $l;
    	return undef;
    } elsif ($r !~ /^220/) {
	$self->{ERROR} = $r;
    	return undef;
    }

    if ($l =~ /scheduler running/) {
    	return (1, $l);
    } elsif ($l =~ /scheduler stopped since (\d+)/) {
    	return (0, $1);
    }
}


sub start {
    my $self = shift;

    _start_stop ($self, "start");
}


sub stop {
    my $self = shift;

    _start_stop ($self, "stop");
}


sub reset {
    my $self = shift;
    my @opts = @_;
    my ($r, $l);

    undef $self->{ERROR};

    if (!$self->{CONNECTED}) {
    	$self->{ERROR} = "not connected";
	return undef;
    }

    if (@opts == 0) {
	($r, $l) = _do_cmd ($self->{HANDLE}, "reset");
    } else {
	($r, $l) = _do_cmd ($self->{HANDLE}, "reset @opts");
    }

    if (!defined $r) {
	$self->{ERROR} = $l;
    	return undef;
    } elsif ($r !~ /^220/) {
	$self->{ERROR} = $r;
    	return undef;
    }

    return $r;
}


sub reload {
    my $self = shift;
    my ($r, $l);

    undef $self->{ERROR};

    if (!$self->{CONNECTED}) {
    	$self->{ERROR} = "not connected";
	return undef;
    }

    ($r, $l) = _do_cmd ($self->{HANDLE}, "reload");

    if (!defined $r) {
	$self->{ERROR} = $l;
    	return undef;
    } elsif ($r !~ /^220/) {
	$self->{ERROR} = $r;
    	return undef;
    }

    return $r;
}


sub term {
    my $self = shift;
    my ($r, $l);

    undef $self->{ERROR};

    if (!$self->{CONNECTED}) {
    	$self->{ERROR} = "not connected";
	return undef;
    }

    ($r, $l) = _do_cmd ($self->{HANDLE}, "term");

    if (!defined $r) {
	$self->{ERROR} = $l;
    	return undef;
    } elsif ($r !~ /^220/) {
	$self->{ERROR} = $r;
    	return undef;
    }

    return $r;
}


sub set_maxkeep {
    my $self = shift;
    my $val = shift;
    my ($r, $l);

    undef $self->{ERROR};

    if (!$self->{CONNECTED}) {
    	$self->{ERROR} = "not connected";
	return undef;
    }

    if ($val !~ /^\d+$/) {
    	$self->{ERROR} = "invalid value for maxkeep";
	return undef;
    }

    ($r, $l) = _do_cmd ($self->{HANDLE}, "set maxkeep $val");

    if (!defined $r) {
	$self->{ERROR} = $l;
    	return undef;
    } elsif ($r !~ /^220/) {
	$self->{ERROR} = $r;
    	return undef;
    }

    return $r;
}

sub get_maxkeep {
    my $self = shift;
    my ($r, $l, $val);

    undef $self->{ERROR};

    if (!$self->{CONNECTED}) {
    	$self->{ERROR} = "not connected";
	return undef;
    }

    ($r, $l) = _do_cmd ($self->{HANDLE}, "set maxkeep");

    if (!defined $r) {
	$self->{ERROR} = $l;
    	return undef;
    } elsif ($r !~ /^220/) {
	$self->{ERROR} = $r;
    	return undef;
    }

    $l =~ /maxkeep = (\d+)/;

    return $1;
}


sub test {
    my $self = shift;
    my ($group, $service) = @_;
    my ($r, $l);

    undef $self->{ERROR};

    if (!$self->{CONNECTED}) {
    	$self->{ERROR} = "not connected";
	return undef;
    }

    if (!defined $group) {
    	$self->{ERROR} = "group not specified";
	return undef;
    }

    if (!defined $service) {
    	$self->{ERROR} = "service not specified";
	return undef;
    }


    ($r, $l) = _do_cmd ($self->{HANDLE}, "test $group $service");

    if (!defined $r) {
	$self->{ERROR} = $l;
    	return undef;
    } elsif ($r !~ /^220/) {
	$self->{ERROR} = $r;
    	return undef;
    }

    return $r;
}


sub ack {
    my $self = shift;
    my ($group, $service, $text) = @_;
    my ($r, $l);

    undef $self->{ERROR};

    if (!$self->{CONNECTED}) {
    	$self->{ERROR} = "not connected";
	return undef;
    }

    ($r, $l) = _do_cmd ($self->{HANDLE}, "ack $group $service $text");

    if (!defined $r) {
	$self->{ERROR} = $l;
    	return undef;
    } elsif ($r !~ /^220/) {
	$self->{ERROR} = $r;
    	return undef;
    }

    return $r;
}


sub loadstate {
    my $self = shift;
    my (@state) = @_;
    my ($r, $l);

    undef $self->{ERROR};

    if (!$self->{CONNECTED}) {
    	$self->{ERROR} = "not connected";
	return undef;
    }

    ($r, $l) = _do_cmd ($self->{HANDLE}, "loadstate @state");

    if (!defined $r) {
	$self->{ERROR} = $l;
    	return undef;
    } elsif ($r !~ /^220/) {
	$self->{ERROR} = $r;
    	return undef;
    }

    return $r;
}


sub savestate {
    my $self = shift;
    my (@state) = @_;
    my ($r, $l);

    undef $self->{ERROR};

    if (!$self->{CONNECTED}) {
    	$self->{ERROR} = "not connected";
	return undef;
    }

    ($r, $l) = _do_cmd ($self->{HANDLE}, "savestate @state");

    if (!defined $r) {
	$self->{ERROR} = $l;
    	return undef;
    } elsif ($r !~ /^220/) {
	$self->{ERROR} = $r;
    	return undef;
    }

    return $r;
}


sub servertime {
    my $self = shift;
    my ($r, $l, $t);

    undef $self->{ERROR};

    if (!$self->{CONNECTED}) {
    	$self->{ERROR} = "not connected";
	return undef;
    }

    ($r, $l) = _do_cmd ($self->{HANDLE}, "servertime");

    if (!defined $r) {
	$self->{ERROR} = $l;
    	return undef;
    } elsif ($r !~ /^220/) {
	$self->{ERROR} = $r;
    	return undef;
    }

    $l =~ /^(\d+)/;
    return $1;
}


#
# clear timers
#
sub clear {
    my $self = shift;
    my ($r, $l);

    undef $self->{ERROR};

    if (!$self->{CONNECTED}) {
    	$self->{ERROR} = "not connected";
	return undef;
    }

    ($r, $l) = _do_cmd ($self->{HANDLE}, "clear timers");

    if (!defined $r) {
	$self->{ERROR} = $l;
    	return undef;
    } elsif ($r !~ /^220/) {
	$self->{ERROR} = $r;
    	return undef;
    }

}


# sub crap_cmd {
#     my $self = shift;
#     my ($r, $l);
# 
#     undef $self->{ERROR};
# 
#     if (!$self->{CONNECTED}) {
#     	$self->{ERROR} = "not connected";
# 	return undef;
#     }
# 
#     ($r, $l) = _do_cmd ($self->{HANDLE}, "COMMAND");
# 
#     if (!defined $r) {
# 	$self->{ERROR} = $l;
#     	return undef;
#     } elsif ($r !~ /^220/) {
# 	$self->{ERROR} = $r;
#     	return undef;
#     }
# 
# }

sub send_trap {
    my $self = shift;
    my %v = @_;

    undef $self->{ERROR};

    if ($v{"retval"} !~ /^\d+$/) {
	$self->{ERROR} = "invalid value for retval";
	return undef;
    }

    if ($v{"opstatus"} =~ /^[a-z_]+$/) {
    	if (!defined ($v{"opstatus"} = $OPSTAT{$v{"opstatus"}})) {
	    $self->{ERROR} = "Undefined opstatus type";
	    return undef;
	}
    }

    my $pkt = "";
    $pkt .= "pro=".$self->{TRAP_PRO_VERSION}."\n";
    $pkt .= "usr=" . $self->{USERNAME} . "\n" .
	   "pas=" . $self->{PASSWORD} . "\n" if ($self->{USERNAME} ne "");

    $pkt .= "spc=$v{opstatus}\n" .
	"seq=0\n" .
	"typ=trap\n" .
	"grp=$v{group}\n" .
	"svc=$v{service}\n" .
	"sta=$v{retval}\n" .
	"spc=$v{opstatus}\n" .
	"tsp=".time."\n" .
	"sum=$v{summary}\n" .
	"dtl=$v{detail}\n.\n";

    my $proto = getprotobyname ("udp") || die "could not get proto\n";
    socket (TRAP, AF_INET, SOCK_DGRAM, $proto) ||
	die "could not create UDP socket: $!\n";

    my $port = $self->{PORT};

    my $paddr = sockaddr_in ($port, inet_aton ($self->{HOST}));
    if (!defined (send (TRAP, $pkt, 0, $paddr))) {
       $self->{ERROR} = "could not send trap to ".$self->{HOST}.": $!\n";
       return undef;
    }

    close (TRAP);

    return 1;
}


sub _start_stop {
    my $self = shift;
    my $cmd = shift;
    my ($r, $l);

    undef $self->{ERROR};

    if (!$self->{CONNECTED}) {
    	$self->{ERROR} = "not connected";
	return undef;
    }

    if ($cmd ne "start" && $cmd ne "stop") {
    	$self->{ERROR} = "undefined command";
	return undef;
    }

    ($r, $l) = _do_cmd ($self->{HANDLE}, "$cmd");

    if (!defined $r) {
	$self->{ERROR} = $l;
    	return undef;
    } elsif ($r !~ /^220/) {
	$self->{ERROR} = $r;
    	return undef;
    }

    return $r;
}


sub _list_opstatus {
    my ($self, $cmd) = @_;
    my (%op, $o, %opstatus);
    my ($group, $service, $last, $timer, $summary);
    my ($w, $var, $val);

    undef $self->{ERROR};

    if (!$self->{CONNECTED}) {
    	$self->{ERROR} = "not connected";
	return undef;
    }

    my ($r, @op) = _do_cmd ($self->{HANDLE}, "$cmd");

    if (!defined $r) {
	$self->{ERROR} = $op[0];
    	return undef;
    } elsif ($r !~ /^220/) {
	$self->{ERROR} = $r;
    	return undef;
    }

    my $v = $self->prot_cmp ($self->prot, "0.38.0");
    return undef if (!defined $v);

    if ($v >= 0) {		# 0.38.0 and above
    	foreach $o (@op) {
	    foreach $w (quotewords ('\s+', 0, $o)) {
	    	($var, $val) = split (/=/, $w);
		$op{$var} = $val;
	    }

	    next if ($op{group} eq "");
	    next if ($op{service} eq "");
	    $group = $op{"group"};
	    $service = $op{"service"};
	    foreach $w (keys %op) {
	    	$opstatus{$group}{$service}{$w} = $op{$w};
	    }
	}

    #
    # old protocol, 0.37
    #
    } else {
    	foreach my $o (@op) {
	    ($group, $service, $last, $timer, $summary) = split (/\s+/, $o, 5);
	    if ($last == 0) {
		%{$opstatus{$group}{$service}} = (
		    opstatus => $STAT_UNTESTED,
		    last_failure => undef,
		    last_success => undef,
		    last_trap => undef,
		    timer => $timer,
		    ack => undef,
		    ackcomment => undef,
		    last_summary => "untested",
		    exitval => undef,
		    group => $group,
		    service => $service
		);
	    } elsif ($summary =~ /^succeeded/) {
		$summary =~ s/^succeeded\s+//;
		%{$opstatus{$group}{$service}} = (
		    opstatus => $STAT_OK,
		    last_failure => undef,
		    last_success => $last,
		    last_check => $last,
		    last_trap => undef,
		    timer => $timer,
		    ack => undef,
		    ackcomment => undef,
		    last_summary => $summary,
		    exitval => 0,
		    group => $group,
		    service => $service
		);
	    } elsif ($summary =~ /^failed/) {
		$summary =~ s/^failed\s+//;
		%{$opstatus{$group}{$service}} = (
		    opstatus => $STAT_FAIL,
		    last_failure => $last,
		    last_success => undef,
		    last_trap => undef,
		    last_check => $last,
		    timer => $timer,
		    ack => undef,
		    ackcomment => undef,
		    last_summary => $summary,
		    exitval => 1,
		    group => $group,
		    service => $service
		);
	    }
	}
    }

    return %opstatus;
}


sub _sock_write {
    my ($sock, $buf) = @_;
    my ($nleft, $nwritten);

    $nleft = length ($buf);
    while ($nleft) {
        $nwritten = syswrite ($sock, $buf, $nleft);
        return undef if (!defined ($nwritten));
        $nleft -= $nwritten;
        substr ($buf, 0, $nwritten) = "";
    }
}


sub _do_cmd {
    my ($fd, $cmd) = @_;
    my ($l, @out);

    @out = ();
    return (undef) if (!defined _sock_write ($fd, "$cmd\n"));

        for (;;) {
            $l = _sock_readline ($fd);
            return (undef) if (!defined $l);
	    chomp ($l);

            if ($l =~ /^(\d{3}\s)/) {
                last;
            }
            push (@out, $l);
        }

        ($l, @out);
}


sub _sock_readline {
    my ($sock) = @_;

    my $l = <$sock>;
    return $l;
}

1;

#
# not yet implemented
#
#set group service var value
#get group service var
#list aliases
#list aliasgroups
