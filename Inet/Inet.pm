# Copyright 1995 Spider Boardman.
# All rights reserved.
#
# Automatic licensing for this software is available.  This software
# can be copied and used under the terms of the GNU Public License,
# version 1 or (at your option) any later version, or under the
# terms of the Artistic license.  Both of these can be found with
# the Perl distribution, which this software is intended to augment.
#
# THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
# WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.


package Net::Inet;
use Carp;

use strict qw(refs subs);

my $myclass = 'Net::Inet';
my $Version = '0.51-alpha';
sub Version { "$myclass v$Version" }

require Exporter;
require AutoLoader;
require DynaLoader;
use Net::Gen;
use Socket;

@ISA = qw(Net::Gen Exporter DynaLoader);

*Net::Inet::Inherit::ISA = \@ISA; # delegation support

# Items to export into callers namespace by default
# (move infrequently used names to @EXPORT_OK below)
@EXPORT = qw(
	INADDR_ALLHOSTS_GROUP
	INADDR_ANY
	INADDR_BROADCAST
	INADDR_LOOPBACK
	INADDR_MAX_LOCAL_GROUP
	INADDR_NONE
	INADDR_UNSPEC_GROUP
	IPPORT_RESERVED
	IPPORT_USERRESERVED
	IPPROTO_EGP
	IPPROTO_EON
	IPPROTO_GGP
	IPPROTO_HELLO
	IPPROTO_ICMP
	IPPROTO_IDP
	IPPROTO_IGMP
	IPPROTO_IP
	IPPROTO_MAX
	IPPROTO_PUP
	IPPROTO_RAW
	IPPROTO_TCP
	IPPROTO_TP
	IPPROTO_UDP
	htonl
	htons
	inet_addr
	inet_aton
	inet_ntoa
	ntohl
	ntohs
);

# Other items we are prepared to export if requested
@EXPORT_OK = qw(
	ICMP_ADVLENMIN
	ICMP_ECHO
	ICMP_ECHOREPLY
	ICMP_IREQ
	ICMP_IREQREPLY
	ICMP_MASKLEN
	ICMP_MASKREPLY
	ICMP_MASKREQ
	ICMP_MAXTYPE
	ICMP_MINLEN
	ICMP_PARAMPROB
	ICMP_REDIRECT
	ICMP_REDIRECT_HOST
	ICMP_REDIRECT_NET
	ICMP_REDIRECT_TOSHOST
	ICMP_REDIRECT_TOSNET
	ICMP_SOURCEQUENCH
	ICMP_TIMXCEED
	ICMP_TIMXCEED_INTRANS
	ICMP_TIMXCEED_REASS
	ICMP_TSLEN
	ICMP_TSTAMP
	ICMP_TSTAMPREPLY
	ICMP_UNREACH
	ICMP_UNREACH_HOST
	ICMP_UNREACH_NEEDFRAG
	ICMP_UNREACH_NET
	ICMP_UNREACH_PORT
	ICMP_UNREACH_PROTOCOL
	ICMP_UNREACH_SRCFAIL
	IN_CLASSA_HOST
	IN_CLASSA_MAX
	IN_CLASSA_NET
	IN_CLASSA_NSHIFT
	IN_CLASSA_SUBHOST
	IN_CLASSA_SUBNET
	IN_CLASSA_SUBNSHIFT
	IN_CLASSB_HOST
	IN_CLASSB_MAX
	IN_CLASSB_NET
	IN_CLASSB_NSHIFT
	IN_CLASSB_SUBHOST
	IN_CLASSB_SUBNET
	IN_CLASSB_SUBNSHIFT
	IN_CLASSC_HOST
	IN_CLASSC_MAX
	IN_CLASSC_NET
	IN_CLASSC_NSHIFT
	IN_CLASSD_HOST
	IN_CLASSD_NET
	IN_CLASSD_NSHIFT
	IN_LOOPBACKNET
	IPFRAGTTL
	IPOPT_CONTROL
	IPOPT_DEBMEAS
	IPOPT_EOL
	IPOPT_LSRR
	IPOPT_MINOFF
	IPOPT_NOP
	IPOPT_OFFSET
	IPOPT_OLEN
	IPOPT_OPTVAL
	IPOPT_RESERVED1
	IPOPT_RESERVED2
	IPOPT_RR
	IPOPT_SATID
	IPOPT_SECURITY
	IPOPT_SECUR_CONFID
	IPOPT_SECUR_EFTO
	IPOPT_SECUR_MMMM
	IPOPT_SECUR_RESTR
	IPOPT_SECUR_SECRET
	IPOPT_SECUR_TOPSECRET
	IPOPT_SECUR_UNCLASS
	IPOPT_SSRR
	IPOPT_TS
	IPOPT_TS_PRESPEC
	IPOPT_TS_TSANDADDR
	IPOPT_TS_TSONLY
	IPPORT_TIMESERVER
	IPTOS_LOWDELAY
	IPTOS_PREC_CRITIC_ECP
	IPTOS_PREC_FLASH
	IPTOS_PREC_FLASHOVERRIDE
	IPTOS_PREC_IMMEDIATE
	IPTOS_PREC_INTERNETCONTROL
	IPTOS_PREC_NETCONTROL
	IPTOS_PREC_PRIORITY
	IPTOS_PREC_ROUTINE
	IPTOS_RELIABILITY
	IPTOS_THROUGHPUT
	IPTTLDEC
	IPVERSION
	IP_ADD_MEMBERSHIP
	IP_DEFAULT_MULTICAST_LOOP
	IP_DEFAULT_MULTICAST_TTL
	IP_DF
	IP_DROP_MEMBERSHIP
	IP_HDRINCL
	IP_MAXPACKET
	IP_MAX_MEMBERSHIPS
	IP_MF
	IP_MSS
	IP_MULTICAST_IF
	IP_MULTICAST_LOOP
	IP_MULTICAST_TTL
	IP_OPTIONS
	IP_RECVDSTADDR
	IP_RECVOPTS
	IP_RECVRETOPTS
	IP_RETOPTS
	IP_TOS
	IP_TTL
	MAXTTL
	SUBNETSHIFT
	pack_sockaddr_in
	unpack_sockaddr_in
);


sub AUTOLOAD
{
    local($constname);
    ($constname = $AUTOLOAD) =~ s/.*:://;
    $val = constant($constname, @_ + 0);
    if ($! != 0) {
	if ($! =~ /Invalid/) {
	    $AutoLoader::AUTOLOAD = $AUTOLOAD;
	    goto &AutoLoader::AUTOLOAD;
	}
	else {
	    croak "Your vendor has not defined Net::Inet macro $constname, used";
	}
    }
    eval "sub $AUTOLOAD { $val }";
    goto &$AUTOLOAD;
}

use strict;

if (defined &{"${myclass}::bootstrap"}) {
    bootstrap $myclass;
}
else {
    $myclass->DynaLoader::bootstrap;
}

# Preloaded methods go here.  Autoload methods go after __END__, and are
# processed by the autosplit program.

my %sockopts;

%sockopts = (
	     # socket options from the list above
	     # simple booleans first

	     'IP_HDRINCL' => ['I'],
	     'IP_RECVDSTADDR' => ['I'],
	     'IP_RECVOPTS' => ['I'],
	     'IP_RECVRETOPTS' => ['I'],

	     # simple integer options

	     'IP_TOS' => ['I'],
	     'IP_TTL' => ['I'],

	     # structured options

	     'IP_ADD_MEMBERSHIP' => ['a4a4'], # ip_mreq
	     'IP_DROP_MEMBERSHIP' => ['a4a4'], # ip_mreq
	     'IP_MULTICAST_IF' => ['a4'], # inet_addr
	     'IP_MULTICAST_LOOP' => ['C'], # u_char
	     'IP_MULTICAST_TTL' => ['C'], # u_char
	     'IP_OPTIONS' => ['a4C40'], # ip_options
	     'IP_RETOPTS' => ['a4C40'], # ip_options

	     # out of known IP options
	     );

$myclass->initsockopts( &IPPROTO_IP, \%sockopts );

sub _htons
{
    unpack('S*',pack('n*',@_));
}

sub _htonl
{
    unpack('L*',pack('N*',@_));
}

sub _nullop
{
    wantarray ? @_ : $_[0];
}


if (&_htons(2) != 2) {	# if lilliputian machine
    *htons = \&_htons;	# make these calls a bit faster
    *htonl = \&_htonl;
}
else {			# if blefuscuan machine
    *htons = \&_nullop;	# make the no-ops a bit faster
    *htonl = \&_nullop;
}

sub ntohs; sub ntohl;		# (helps with -w)
*ntohs = \&htons;		# synonyms that callers may expect
*ntohl = \&htonl;


sub inet_aton			# (string) ; returns packed n_long or undef
{
#   use integer;		# can't do this--hi-order bit gets lost
    return undef unless @_ == 1;
    my(@pieces,$val,$accum,$mask,$shift,$piece);
    @pieces = split(/\./,$_[0],-1);
    return undef if @pieces > 4 or !@pieces or $pieces[-1] eq '';
    $mask = 0xffffffff;
    $shift = 32;
    $accum=0;
    $val = 0;
    foreach $piece (@pieces) {
	return undef unless ($val & 0xff) == $val;
	return undef unless $piece =~ /^(0x[a-f\d]+|0[0-7]*|[1-9]\d*)$/s;
	$accum |= ($val << $shift);
	$shift -= 8;
	$val = 0 + ((substr($piece, 0, 1) eq '0') ? oct($piece) : $piece);
	return undef unless ($val & $mask) == $val;
	($mask >>= 8) &= 0xffffff;
    }
    $accum |= $val;		# finish assembling the value
    pack('N',$accum);		# return as n_long (eqv to inet_addr)
}

sub inet_addr;			# (helps with -w)
*inet_addr = \&inet_aton;	# same code for old interface

sub inet_ntoa			# (packed n_long) returns string
{
    my $str = shift;
    if (length($str) > 4 and substr($str,4) !~ /[^\0]/) {
	substr($str,4) = '';
    }
    join('.',unpack('C*',$str));
}

sub pack_sockaddr_in		# [$family,] $port, $in_addr
{
    my(@args) = @_;
    unshift(@args,AF_INET) if @args == 2;
    _pack_sockaddr_in(@args);
}

my $debug = 0;

my @hostkeys = qw(thishost desthost host);
my @hostkeyHandlers = (\&_sethost) x @hostkeys;
my @portkeys = qw(thisservice thisport destservice destport service port);
my @portkeyHandlers = (\&_setport) x @portkeys;
my @protokeys = qw(IPproto proto);
my @protokeyHandlers = (\&_setproto) x @protokeys;
# Don't include "handled" keys in this list, since that's redundant.
my @Keys = qw(lclhost lcladdr lclservice lclport
	      remhost remaddr remservice remport);

sub new				# $class, [\%params]
{
    print STDERR "${myclass}::new(@_)\n" if $debug;
    my($class,@Args,$self) = @_;
    $self = $class->Net::Inet::Inherit::new(@Args);
    print STDERR "${myclass}::new(@_), self=$self after sub-new\n"
	if $debug > 1;
    if ($self) {
	dump if $debug > 1 and
	    ref $self ne $class || "$self" !~ /HASH/;
	# register our keys and their handlers
	$self->registerParamKeys(\@Keys);
	$self->registerParamHandlers(\@portkeys,\@portkeyHandlers);
	$self->registerParamHandlers(\@hostkeys,\@hostkeyHandlers);
	$self->registerParamHandlers(\@protokeys,\@protokeyHandlers);
	# register our socket options
	$self->registerOptions('IPPROTO_IP', &IPPROTO_IP+0, \%sockopts);
	# set our required parameters
	$self->setparams({'PF' => PF_INET, 'AF' => AF_INET});
	$self = $self->init(@Args) if $class eq $myclass;
    }
    print STDERR "${myclass}::new returning self=$self\n" if $debug;
    $self;
}

sub _hostport			# $self, {'this'|'dest'}, [\]@list
{
    my($self,$which,@args,$aref) = @_;
    $aref = \@args;		# assume in-line list unless proved otherwise
    $aref = $args[0] if @args == 1 and ref $args[0] eq 'ARRAY';
    return undef if $which ne 'dest' and $which ne 'this';
    if (@$aref) {		# assume this is ('desthost','destport')
	my %p;			# where we'll build the params list
	if (@$aref == 3 and ref($$aref[2]) eq 'HASH') {
	    %p = %{$$aref[2]};
	}
	else {
	    %p = splice(@$aref,2); # assume valid params after
	}
	$p{"${which}host"} = $$aref[0] if defined $$aref[0];
	$p{"${which}port"} = $$aref[1] if defined $$aref[1];
	$self->setparams(\%p);
    }
    else {
	1;			# succeed vacuously if no work
    }
}

sub init			# $self, [\%params || @speclist]
{				# returns updated $self
    print STDERR "${myclass}::init(@_)\n" if $debug > 1;
    my($self,@args) = @_;
    return $self unless $self = $self->Net::Inet::Inherit::init(@args);
    if (@args > 1 or @args == 1 and ref $args[0] ne 'HASH') {
	return undef unless $self->_hostport('dest',@args);
    }
    my @r;			# dummy array needed in 5.000
    if ((@r=$self->getparams([qw(type proto)],1)) == 4) { # have type and proto
	unless ($self->open) {	# create the socket
	    return undef;	# and refuse to make less object than requested
	}
    }
    if ($self->isopen and $self->getparam('dstaddrlist')) {
	# have enough object already to attempt the connection
	return undef unless $self->connect; # make no less object than requested
    }
    # I think this is all we need here ?
    $self;
}

sub connect			# $self, [\]@([host],[port])
{
    my($self,@args) = @_;
    return undef if @args and not $self->_hostport('dest',@args);
    $self->Net::Inet::Inherit::connect;
}

sub _sethost			# $self,$key,$newval
{
    my($self,$key,$newval) = @_;
    return "Invalid args to ${myclass}::_sethost(@_), called"
	if @_ != 3 or ref($$self{'Keys'}{$key}) ne 'CODE';
    # check for call from delparams
    if (!defined $newval) {
	my @delkeys;
	if ($key eq 'thishost') {
	    @delkeys =
		qw(srcaddrlist srcaddr lclhost lcladdr lclport lclservice);
	}
	elsif ($key eq 'desthost') {
	    @delkeys =
		qw(dstaddrlist dstaddr remhost remaddr remport remservice);
	}
	splice(@delkeys, 1) if @delkeys and $self->isconnected;
	$self->delparams(@delkeys) if @delkeys;
	return '';		# ok to delete
    }
    # here we're really trying to set some kind of address (we think)
    my ($pkey,$port);
    ($pkey = $key) =~ s/host$/port/;
    my (@addrs,$addr);
    if ($newval =~ m/^(\[?)([a-fx.\d]+)(\]?)$/si) {
	return "Invalid address literal $newval found"
	    if length($1) != length($3);
	$addr = inet_aton($2);
    }
    if (defined $addr and substr($newval, 0, 1) eq '[') {
	push(@addrs,$addr);
	$addr = '[' . inet_ntoa($addr) . ']';
    }
    else {
	my(@hinfo,$hname);
	$hname = $newval;
	do {
	    @hinfo = gethostbyname($hname);
	} while (!@hinfo && $hname =~ s/\.$//);
	if (!@hinfo and defined $addr) {
	    push(@addrs, $addr);
	    $addr = inet_ntoa($addr);
	}
	else {
	    return "Host $newval not found ($?)," unless @hinfo > 4;
	    return "Host $newval has strange address family ($hinfo[2]),"
		if $self->getparam('AF',AF_INET,1) != $hinfo[2];
	    @addrs = splice(@hinfo,4);
	    $addr = $hinfo[0];	# save canonical name for real setup
	}
    }
    # valid so far, get out if can't form addresses yet
    return '' unless
	($port = $$self{'Parms'}{$pkey}) =~ /^\d+$/s or
	    !defined $port and $pkey eq 'thisport'; # allow for 'bind'
    return '' if $key eq 'host'; # don't know yet whether 'dest' or 'this'
    my $af = $self->getparam('AF',AF_INET,1);
    for (@addrs) {
	$_ = pack_sockaddr_in($af, $port+0, $_);
    }
    $pkey = (($key eq 'desthost') ? 'dstaddrlist' : 'srcaddrlist');
    $self->setparams({$pkey => [@addrs]});
    # finally, we have validation
    $_[2] = $addr;		# update the canonical representation to store
    print STDERR " - ${myclass}::_sethost $self $key ",
	$self->format_addr($addr,1),"\n"
	    if $debug;
    '';				# return nullstring for goodness
}

sub _setport			# ($self,$key,$newval)
{
    my($self,$key,$newval) = @_;
    return "Invalid arguments to ${myclass}::_setport(@_), called"
	if @_ != 3 || !exists($$self{'Keys'}{$key});
    print STDERR " - ${myclass}::_setport(@_)\n" if $debug;
    my($skey,$hkey,$pkey,$svc,$port,$proto,$type,$host,$reval,$pname,@serv);
    ($skey = $key) =~ s/port$/service/;	# a key known to be for a service
    ($pkey = $key) =~ s/service$/port/;	# and one for the port
    ($hkey = $pkey) =~ s/port$/host/; # another for calling _sethost
    if (!defined $newval) {	# deleting a service or port
	delete $$self{'Parms'}{$skey};
	delete $$self{'Parms'}{$pkey} unless
	    $pkey ne 'port' and $self->isconnected;
	my @delkeys;
	if ($pkey eq 'thisport') {
	    @delkeys = qw(srcaddrlist srcaddr);
	}
	elsif ($pkey eq 'destport') {
	    @delkeys = qw(dstaddrlist dstaddr);
	}
	pop(@delkeys) if @delkeys and $self->isconnected;
	$self->delparams(@delkeys) if @delkeys;
	return '';		# ok to delete
    }
    # here, we're trying to set a port or service
    $pname = $self->getparam('IPproto');
    $proto = $self->getparam('proto'); # try to find our protocol
    if (!defined($pname) && !$proto
	&& defined($type = $self->getparam('type'))) {
	# try to infer protocol from SO_TYPE
	if ($type == SOCK_STREAM) {
	    $proto = &IPPROTO_TCP;
	}
	elsif ($type == SOCK_DGRAM) {
	    $proto = &IPPROTO_UDP;
	}
    }
    if (defined $proto and not defined $pname) {
	$pname = getprotobynumber($proto);
	unless (defined $pname) {
	    if ($proto == &IPPROTO_UDP) {
		$pname = 'udp';
	    }
	    elsif ($proto == &IPPROTO_TCP) {
		$pname = 'tcp';
	    }
	}
    }
    $reval = $newval;		# make resetting $_[2] simple
    $svc = $$self{'Parms'}{$skey}; # keep earlier values around (to preserve)
    $port = $$self{'Parms'}{$pkey};
    $port = undef if
	defined($port) and $port =~ /\D/; # but stored ports must be numeric
    if ($skey eq $key || $newval =~ /\D/) { # trying to set a service
	@serv = getservbyname($newval,$pname); # try to find the port info
    }
    if ($newval !~ /\D/ && !@serv) { # setting a port number (even if service)
	$port = $newval+0;	# just in case no servent is found
	@serv = getservbyport(htons($port),$pname) if $pname;
    }
    if (@serv) {		# if we resolved name/number input
	$svc = $serv[0];	# save the canonical service name (and number?)
	$port = 0+$serv[2] unless $key eq $pkey and $newval !~ /\D/;
    }
    elsif ($key eq $skey or $newval =~ /\D/) { # setting unknown service
	return "Unknown service $newval, found";
    }
    $reval = (($key eq $skey) ? $svc : $port); # in case we get that far
    $$self{'Parms'}{$skey} = $svc if $svc; # in case no port change
    $_[2] = $reval;
    print STDERR " - ${myclass}::_setport $self $skey $svc\n" if
	$debug and $svc;
    print STDERR " - ${myclass}::_setport $self $pkey $port\n" if
	$debug and defined $port;
    return '' if defined($$self{'Parms'}{$pkey}) and
	$$self{'Parms'}{$pkey} == $port; # nothing to update if same number
    $$self{'Parms'}{$pkey} = $port; # in case was service key
    # check for whether we can ask _sethost to set {dst,src}addrlist now
    return '' if $pkey eq 'port'; # not if don't know local/remote yet
    return '' unless
	$host = $$self{'Parms'}{$hkey} or $hkey eq 'thishost';
    $host = '0' if !defined $host; # 'thishost' value was null
    $self->setparams({$hkey => $host},0,1); # try it
    '';				# return goodness from here
}

sub _setproto			# $this, $key, $newval
{
    my($self,$key,$newval) = @_;
    if (!defined $newval) {	# delparams call?
	delete $$self{'Parms'}{'IPproto'}; # make both go away at once
	delete $$self{'Parms'}{'proto'};
	return '';
    }
    my($pname,$proto);
    if ($key ne 'proto' or $newval =~ /\D/) { # have to try for name->number
	my @pval = getprotobyname($newval);
	if (@pval) {
	    $pname = $pval[0];
	    $proto = $pval[2];
	}
    }
    if (!defined($proto) and $newval !~ /\D/) { # numeric proto, find name
	$proto = $newval+0;
	$pname = getprotobynumber($proto);
    }
    return "Unknown protocol ($newval), seen"
	unless defined $proto;
    unless (defined $pname) {
	if ($proto == &IPPROTO_UDP) {
	    $pname = 'udp';
	}
	elsif ($proto == &IPPROTO_TCP) {
	    $pname = 'tcp';
	}
    }
    $$self{'Parms'}{'IPproto'} = $pname; # update our values
    $$self{'Parms'}{'proto'} = $proto;
    $_[2] = $$self{'Parms'}{$key}; # make sure the right value gets set
    '';				# return goodness
}

sub _addrinfo			# $this, $sockaddr
{
    my($this,$sockaddr) = @_;
    my($fam,$port,$serv,$name,$addr,@hinfo);
    ($fam,$port,$addr) = unpack_sockaddr_in($sockaddr);
    @hinfo = gethostbyaddr($addr,$fam);
    $addr = inet_ntoa($addr);
    $name = (!@hinfo) ? $addr : $hinfo[0];
    $serv = getservbyport(htons($port),
			  (ref $this) && $this->getparam('IPproto')) || $port;
    ($name, $addr, $serv, $port);
}

sub getsockinfo			# $this
{
    my($self) = @_;
    my($rem,$lcl,$port,$serv,$name,$addr);
    return undef unless $rem = $self->Net::Inet::Inherit::getsockinfo;
    ($name, $addr, $serv, $port) = $self->_addrinfo($rem);
    $self->setparams({'remhost' => $name, 'remaddr' => $addr,
		      'remservice' => $serv, 'remport' => $port});
    $lcl = $self->getparam('srcaddr');
    ($name, $addr, $serv, $port) = $self->_addrinfo($lcl);
    $self->setparams({'lclhost' => $name, 'lcladdr' => $addr,
		      'lclservice' => $serv, 'lclport' => $port});
    $rem;
}

sub format_addr			# $this, $sockaddr, [numeric_only]
{
    my($this,$sockaddr,$numeric) = @_;
    my($name,$addr,$serv,$port,$rval) = $this->_addrinfo($sockaddr);
    if ($numeric) {
	$rval = "${addr}:${port}";
    }
    else {
	$rval = "${name}:${serv}";
    }
    $rval;
}


1;

# these would have been autoloaded, but autoload and inheritance conflict

sub setdebug			# $this, [bool, [norecurse]]
{
    my $prev = $debug;
    shift;
    $debug = @_ ? $_[0] : 1;
    @_ > 1 && $_[1] ? $prev :
	$prev . setdebug Net::Inet::Inherit @_;
}

sub bind			# $self, [\]@([host],[port])
{
    my($self,@args) = @_;
    return undef if @args and not $self->_hostport('this',@args);
    $self->Net::Inet::Inherit::bind;
}

sub unbind			# $self
{
    my($self,@args) = @_;
    carp "Excess args to ${myclass}::unbind ignored" if @args;
    $self->delparams([qw(thishost thisport)]) || return undef;
    $self->Net::Inet::Inherit::unbind;
}

# autoloaded methods go after the END token (& pod) below

__END__

=head1 NAME

Net::Inet - Internet socket interface module

=head1 SYNOPSIS

    use Net::Gen;		# optional
    use Net::Inet;

=head1 DESCRIPTION

The C<Net::Inet> module provides basic services for handling
socket-based communications for the Internet protocol family.  It
inherits from C<Net::Gen>, and is a base for C<Net::TCP> and
C<Net::UDP> (future).

=head2 Public Methods

=over 6

=item new

Usage:

    $obj = new Net::TCP;
    $obj = new Net::TCP $host, $service;
    $obj = new Net::TCP \%parameters;
    $obj = new Net::TCP $host, $service, \%parameters;

Returns a newly-initialised object of the given class.  If called
for a derived class, no validation of the supplied parameters
will be performed.  (This is so that the derived class can add
the parameter validation it needs to the object before allowing
the validation.)  Otherwise, it will cause the parameters to be
validated by calling its C<init> method.  In particular, this
means that if both a host and a service are given, and a protocol
and socket type are already known, then an object will only be
returned if a connect() call was successful.

=item init

Usage:

    return undef unless $self = $self->init;
    return undef unless $self = $self->init(\%parameters);
    return undef unless $self = $self->init($host, $service, \%parameters);

Verifies that all previous parameter assignments are valid (via
C<checkparams>).  Returns the incoming object on success, and
C<undef> on failure.  Usually called only via a derived class's
C<init> method or its own C<new> call.

=item bind

Usage:

    $ok = $obj->bind;
    $ok = $obj->bind($host, $service);

Sets up the C<srcaddrlist> object parameter with the specified
$host and $service arguments if supplied (via the C<thishost> and
C<thisport> object parameters), and then returns the value from
the inherited C<bind> method.

Example:

    $ok = $obj->bind(0, 'echo'); # attach to the TCP echo port

=item unbind

Usage:

    $obj->unbind;

Deletes the C<thishost> and C<thisport> object parameters, and
then (assuming that succeeds, which it should) returns the value
from the inherited C<unbind> method.

=item connect

Usage:

    $ok = $obj->connect;
    $ok = $obj->connect($host, $service);
    $ok = $obj->connect([$host, $service]);

Attempts to establish a connection for the object.  If the $host
or $service arguments are specified, they will be used to set the
C<desthost> and C<destservice>/C<destport> object parameters,
with side-effects of setting up the C<dstaddrlist> object
parameter.  Then, the result of a call to the inherited C<bind>
method will be returned.

=item format_addr

Usage:
{
    $string = $obj->format_addr($sockaddr);
    $string = $obj->format_addr($sockaddr, $numeric_only);
    $string = format_addr Module $sockaddr;
    $string = format_addr Module $sockaddr, $numeric_only;

Returns a formatted representation of the address.  This is a
method so that it can be overridden by derived classes.  It is
used to implement ``pretty-printing'' methods for source and
destination addresses.  If the $numeric_only argument is true,
the address and port number will be used even if they can be
resolved to names.  Otherwise, the resolved hostname and service
name will be used if possible.

=item format_local_addr

Usage:

    $string = $obj->format_local_addr;
    $string = $obj->format_local_addr($numeric_only);

Returns a formatted representation of the local socket address
associated with the object.  A sugar-coated way of calling the
C<format_addr> method for the F<srcaddr> object parameter.

=item format_remote_addr

Usage:

    $string = $obj->format_remote_addr;

Returns a formatted representation of the remote socket address
associated with the object.  A sugar-coated way of calling the
C<format_addr> method for the F<dstaddr> object parameter.

=item getsockinfo

An augmented form of C<Net::Gen::getsockinfo>.  Aside from
updating more object parameters, it behaves the same as that in
the base class.  The additional object parameters which get set
are C<lcladdr>, C<lclhost>, C<lclport>, C<lclservice>,
C<remaddr>, C<remhost>, C<remport>, and C<remservice>.  (They are
described below.)

=back

=head2 Protected Methods

[See the note in Net::Gen about my definition of protected methods
in Perl.]

none.

=head2 Known Socket Options

These are the socket options known to the C<Net::Inet> module
itself:

=over 6

=item Z<>

C<IP_HDRINCL>,
C<IP_RECVDSTADDR>,
C<IP_RECVOPTS>,
C<IP_RECVRETOPTS>,
C<IP_TOS>,
C<IP_TTL>,
C<IP_ADD_MEMBERSHIP>,
C<IP_DROP_MEMBERSHIP>,
C<IP_MULTICAST_IF>,
C<IP_MULTICAST_LOOP>,
C<IP_MULTICAST_TTL>,
C<IP_OPTIONS>,
C<IP_RETOPTS>

=back

=head2 Known Object Parameters

These are the object parameters registered by the C<Net::Inet>
module itself:

=over 6

=item IPproto

The name of the Internet protocol in use on the socket associated
with the object.  Set as a side-effect of setting the C<proto>
object parameter, and vice versa.

=item proto

Used the same way as with C<Net::Gen>, but has a handler attached
to keep it in sync with C<IPproto>.

=item thishost

The source host name or address to use for the C<bind> method.
When used in conjunction with the C<thisservice> or C<thisport>
object parameter, causes the C<srcaddrlist> object parameter to
be set, which is how it affects the bind() action.  This
parameter is validated, and must be either a valid internet
address or a hostname for which an address can be found.  If a
hostname is given, and multiple addresses are found for it, then
each address will be entered into the C<srcaddrlist> array
reference.

=item desthost

The destination host name or address to use for the C<connect>
method.  When used in conjunction with the C<destservice> or
C<destport> object parameter, causes the C<dstaddrlist> object
parameter to be set, which is how it affects the connect()
action.  This parameter is validated, and must be either a valid
internet address or a hostname for which an address can be found.
If a hostname is given, and multiple addresses are found for it,
then each address will be entered into the C<dstaddrlist> array
reference, in order.  This allows the C<connect> method to
attempt a connection to each address, as per RFC 1123.

=item thisservice

The source service name (or number) to use for the C<bind>
method.  An attempt will be made to translate the supplied
service name with getservbyname().  If that succeeds, or if it
fails but the supplied value was strictly numeric, the port
number will be set in the C<thisport> object parameter.  If the
supplied value is not numeric and can't be translated, the
attempt to set the value will fail.  Otherwise, this causes the
C<srcaddrlist> object parameter to be updated, in preparation for
an invocation of the C<bind> method (possibly implicitly from the
C<connect> method).

=item thisport

The source service number (or name) to use for the C<bind>
method.  An attempt will be made to translate the supplied
service name with getservbyname() if it is not strictly numeric.
If that succeeds, the given name will be set in the
C<thisservice> parameter, and the resolved port number will be
set in the C<thisport> object parameter.  If the supplied value
is strictly numeric, and a call to getservbyport can resolve a
name for the service, the C<thisservice> parameter will be
updated appropriately.  If the supplied value is not numeric and
can't be translated, the attempt to set the value will fail.
Otherwise, this causes the C<srcaddrlist> object parameter to be
updated, in preparation for an invocation of the C<bind> method
(possibly implicitly from the C<connect> method).

=item destservice

The destination service name (or number) to use for the
C<connect> method.  An attempt will be made to translate the
supplied service name with getservbyname().  If that succeeds, or
if it fails but the supplied value was strictly numeric, the port
number will be set in the C<destport> object parameter.  If the
supplied value is not numeric and can't be translated, the
attempt to set the value will fail.  Otherwise, if the
C<desthost> parameter has a defined value, this causes the
C<dstaddrlist> object parameter to be updated, in preparation for
an invocation of the C<connect> method.

=item destport

The destination service number (or name) to use for the
C<connect> method.  An attempt will be made to translate the
supplied service name with getservbyname() if it is not strictly
numeric.  If that succeeds, the given name will be set in the
C<destservice> parameter, and the resolved port number will be
set in the C<destport> parameter.  If the supplied value is
strictly numeric, and a call to getservbyport can resolve a name
for the service, the C<destservice> parameter will be updated
appropriately.  If the supplied value is not numeric and can't be
translated, the attempt to set the value will fail.  Otherwise,
if the C<desthost> parameter has a defined value, this causes the
C<dstaddrlist> object parameter to be updated, in preparation for
an invocation of the C<connect> method.

=item lcladdr

The local IP address stashed by the C<getsockinfo> method after a
successful connect() call.

=item lclhost

The local hostname stashed by the C<getsockinfo> method after a
successful connect(), as resolved from the F<lcladdr> object
parameter.

=item lclport

The local port number stashed by the C<getsockinfo> method after a
successful connect() call.

=item lclservice

The local service name stashed by the C<getsockinfo> method after
a successful connect(), as resolved from the F<lclport> object
parameter.

=item remaddr

The remote IP address stashed by the C<getsockinfo> method after a
successful connect() call.

=item remhost

The remote hostname stashed by the C<getsockinfo> method after a
successful connect(), as resolved from the F<remaddr> object
parameter.

=item remport

The remote port number stashed by the C<getsockinfo> method after a
successful connect() call.

=item remservice

The remote service name stashed by the C<getsockinfo> method after
a successful connect(), as resolved from the F<remport> object
parameter.

=back

=head2 Non-Method Subroutines

=over 6

=item inet_aton

Usage:

    $in_addr = inet_aton('192.0.2.1');

Returns the packed C<AF_INET> address in network order, if it is
validly formed, or C<undef> on error.

=item inet_addr

A synonym for inet_aton() (for old fogeys like me who forget
about the new name).  (Yes, I know it's different in C, but in
Perl there's no need to propagate the old inet_addr()
braindamage, so I didn't.)

=item inet_ntoa

Usage:

    $addr_string = inet_ntoa($in_addr);

Returns the ASCII representation of the C<AF_INET> address
provided (if possible), or C<undef> on error.

=item htonl/htons/ntohl/ntohs

As you'd expect, I think.

=item pack_sockaddr_in

Usage:

    $connect_address = pack_sockaddr_in($family, $port, $in_addr);

Returns the packed C<struct sockaddr_in> corresponding to the
provided $family, $port, and $in_addr arguments.  The $family and
$port arguments must be numbers, and the $in_addr argument must
be a packed C<struct in_addr> such as the trailing elements from
perl's gethostent() return list.

=item unpack_sockaddr_in

Usage:

    ($family, $port, $in_addr) = unpack_sockaddr_in($connected_address);

Returns the address family, port, and packed C<struct in_addr>
from the supplied packed <struct sockaddr_in>.  This is the
inverse of pack_sockaddr_in().

=back

=head2 Exports

=over 6

=item default

C<INADDR_ALLHOSTS_GROUP>,
C<INADDR_ANY>,
C<INADDR_BROADCAST>,
C<INADDR_LOOPBACK>,
C<INADDR_MAX_LOCAL_GROUP>,
C<INADDR_NONE>,
C<INADDR_UNSPEC_GROUP>,
C<IPPORT_RESERVED>,
C<IPPORT_USERRESERVED>,
C<IPPROTO_EGP>,
C<IPPROTO_EON>,
C<IPPROTO_GGP>,
C<IPPROTO_HELLO>,
C<IPPROTO_ICMP>,
C<IPPROTO_IDP>,
C<IPPROTO_IGMP>,
C<IPPROTO_IP>,
C<IPPROTO_MAX>,
C<IPPROTO_PUP>,
C<IPPROTO_RAW>,
C<IPPROTO_TCP>,
C<IPPROTO_TP>,
C<IPPROTO_UDP>,
C<htonl>,
C<htons>,
C<inet_addr>,
C<inet_aton>,
C<inet_ntoa>,
C<ntohl>,
C<ntohs>

=item exportable

C<ICMP_ADVLENMIN>,
C<ICMP_ECHO>,
C<ICMP_ECHOREPLY>,
C<ICMP_IREQ>,
C<ICMP_IREQREPLY>,
C<ICMP_MASKLEN>,
C<ICMP_MASKREPLY>,
C<ICMP_MASKREQ>,
C<ICMP_MAXTYPE>,
C<ICMP_MINLEN>,
C<ICMP_PARAMPROB>,
C<ICMP_REDIRECT>,
C<ICMP_REDIRECT_HOST>,
C<ICMP_REDIRECT_NET>,
C<ICMP_REDIRECT_TOSHOST>,
C<ICMP_REDIRECT_TOSNET>,
C<ICMP_SOURCEQUENCH>,
C<ICMP_TIMXCEED>,
C<ICMP_TIMXCEED_INTRANS>,
C<ICMP_TIMXCEED_REASS>,
C<ICMP_TSLEN>,
C<ICMP_TSTAMP>,
C<ICMP_TSTAMPREPLY>,
C<ICMP_UNREACH>,
C<ICMP_UNREACH_HOST>,
C<ICMP_UNREACH_NEEDFRAG>,
C<ICMP_UNREACH_NET>,
C<ICMP_UNREACH_PORT>,
C<ICMP_UNREACH_PROTOCOL>,
C<ICMP_UNREACH_SRCFAIL>,
C<IN_CLASSA_HOST>,
C<IN_CLASSA_MAX>,
C<IN_CLASSA_NET>,
C<IN_CLASSA_NSHIFT>,
C<IN_CLASSA_SUBHOST>,
C<IN_CLASSA_SUBNET>,
C<IN_CLASSA_SUBNSHIFT>,
C<IN_CLASSB_HOST>,
C<IN_CLASSB_MAX>,
C<IN_CLASSB_NET>,
C<IN_CLASSB_NSHIFT>,
C<IN_CLASSB_SUBHOST>,
C<IN_CLASSB_SUBNET>,
C<IN_CLASSB_SUBNSHIFT>,
C<IN_CLASSC_HOST>,
C<IN_CLASSC_MAX>,
C<IN_CLASSC_NET>,
C<IN_CLASSC_NSHIFT>,
C<IN_CLASSD_HOST>,
C<IN_CLASSD_NET>,
C<IN_CLASSD_NSHIFT>,
C<IN_LOOPBACKNET>,
C<IPFRAGTTL>,
C<IPOPT_CONTROL>,
C<IPOPT_DEBMEAS>,
C<IPOPT_EOL>,
C<IPOPT_LSRR>,
C<IPOPT_MINOFF>,
C<IPOPT_NOP>,
C<IPOPT_OFFSET>,
C<IPOPT_OLEN>,
C<IPOPT_OPTVAL>,
C<IPOPT_RESERVED1>,
C<IPOPT_RESERVED2>,
C<IPOPT_RR>,
C<IPOPT_SATID>,
C<IPOPT_SECURITY>,
C<IPOPT_SECUR_CONFID>,
C<IPOPT_SECUR_EFTO>,
C<IPOPT_SECUR_MMMM>,
C<IPOPT_SECUR_RESTR>,
C<IPOPT_SECUR_SECRET>,
C<IPOPT_SECUR_TOPSECRET>,
C<IPOPT_SECUR_UNCLASS>,
C<IPOPT_SSRR>,
C<IPOPT_TS>,
C<IPOPT_TS_PRESPEC>,
C<IPOPT_TS_TSANDADDR>,
C<IPOPT_TS_TSONLY>,
C<IPPORT_TIMESERVER>,
C<IPTOS_LOWDELAY>,
C<IPTOS_PREC_CRITIC_ECP>,
C<IPTOS_PREC_FLASH>,
C<IPTOS_PREC_FLASHOVERRIDE>,
C<IPTOS_PREC_IMMEDIATE>,
C<IPTOS_PREC_INTERNETCONTROL>,
C<IPTOS_PREC_NETCONTROL>,
C<IPTOS_PREC_PRIORITY>,
C<IPTOS_PREC_ROUTINE>,
C<IPTOS_RELIABILITY>,
C<IPTOS_THROUGHPUT>,
C<IPTTLDEC>,
C<IPVERSION>,
C<IP_ADD_MEMBERSHIP>,
C<IP_DEFAULT_MULTICAST_LOOP>,
C<IP_DEFAULT_MULTICAST_TTL>,
C<IP_DF>,
C<IP_DROP_MEMBERSHIP>,
C<IP_HDRINCL>,
C<IP_MAXPACKET>,
C<IP_MAX_MEMBERSHIPS>,
C<IP_MF>,
C<IP_MSS>,
C<IP_MULTICAST_IF>,
C<IP_MULTICAST_LOOP>,
C<IP_MULTICAST_TTL>,
C<IP_OPTIONS>,
C<IP_RECVDSTADDR>,
C<IP_RECVOPTS>,
C<IP_RECVRETOPTS>,
C<IP_RETOPTS>,
C<IP_TOS>,
C<IP_TTL>,
C<MAXTTL>,
C<SUBNETSHIFT>,
C<pack_sockaddr_in>,
C<unpack_sockaddr_in>

=item tags

None, since that version of F<Exporter.pm> is not yet standard.
Wait for Perl version 5.002.

=back

=head1 NYI

This is still missing a way to pretty-print the connection
information after a successful connect() or accept().
[Not still true, but the following yet holds.]  This is
largely because I'm not satisfied with any of the obvious ways to
do it.  Now taking suggestions.  Proposals so far:

    ($peerproto, $peername, $peeraddr, $peerport, $peerservice) =
	$obj->getsockinfo;
    @conninfo = $obj->getsockinfo($sockaddr_in);
    # the above pair are a single proposal

    %conninfo = $obj->getsockinfo;
    %conninfo = $obj->getsockinfo($sockaddr_in);
    # for these, the keys would be qw(proto hostname address port service)

Of course, it's probably better to return references rather than actual
arrays, but you get the idea.

=head1 AUTHOR

Spider Boardman <F<spider@Orb.Nashua.NH.US>>

=cut

#other sections should be added, sigh.

#any real autoloaded methods go after this line
