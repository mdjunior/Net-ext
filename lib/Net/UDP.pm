# Copyright 1995,2002 Spider Boardman.
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

# rcsid: "@(#) $Id: UDP.dat,v 1.21 2002/03/30 10:10:55 spider Exp $"

package Net::UDP;
use 5.004_04;			# new minimum Perl version for this package

use strict;
#use Carp;
sub carp { require Carp; goto &Carp::carp; }
sub croak { require Carp; goto &Carp::croak; }
use vars qw($VERSION @ISA *AUTOLOAD);

BEGIN {
    $VERSION = '1.0';
    eval "sub Version () { __PACKAGE__ . ' v$VERSION' }";
}

use AutoLoader;

use Net::Inet 1.0;
use Net::Gen 1.0 ':sockvals', ':families';

BEGIN {
    @ISA = 'Net::Inet';
    *AUTOLOAD = \$Net::Gen::AUTOLOAD;
}

# Cheat on AUTOLOAD inheritance.
sub AUTOLOAD
{
    #$Net::Gen::AUTOLOAD = $AUTOLOAD;
    goto &Net::Gen::AUTOLOAD;
}

# Preloaded methods go here.  Autoload methods go after
# __END__, and are processed by the autosplit program.

# No new socket options for UDP

# Module-specific object options

my @Keys = qw(unbuffered_input unbuffered_output);
my @CodeKeys = qw(unbuffered_IO unbuffered_io);
my %CodeKeys;
@CodeKeys{@CodeKeys} = (\&_setbuf_unbuf) x @CodeKeys;

my %Keys;			# for only calling registration routines once

sub new : locked
{
    my($class,@args) = @_;
    my $self = $class->SUPER::new(@args);
    $class = ref $class if ref $class;
    if ($self) {
	if (%Keys) {
	    $ {*$self}{Keys} = { %Keys } ;
	}
	else {
	    $self->register_param_keys(\@Keys);
	    $self->register_param_handlers(\%CodeKeys);
	    %Keys = %{ $ {*$self}{Keys} } ;
	}
	# no new sockopts for UDP?
	# set our required parameters
	$self->setparams({type => SOCK_DGRAM,
			  proto => IPPROTO_UDP,
			  IPproto => 'udp',
			  netgen_fakeconnect => 1,
			  unbuffered_output => 0,
			  unbuffered_input => 0}, -1);
	if ($class eq __PACKAGE__) {
	    unless ($self->init(@args)) {
		local $!;	# protect returned errno value
		undef $self;	# against excess closes in perl core
		undef $self;	# another statement needed for sequencing
	    }
	}
    }
    $self;
}

#& _addrinfo($this, $sockaddr, [numeric_only]) : @list
sub _addrinfo
{
    my($this,@args,@r) = @_;
    @r = $this->SUPER::_addrinfo(@args);
    unless(!@r or $args[1] or ref($this) or $r[2] ne $r[3]) {
	$this = getservbyport(htons($r[3]), 'udp');
	$r[2] = $this if defined $this;
    }
    @r;
}

# autoloaded methods go after the END token (& pod) below

# hack to ensure that autoloading in Net::Gen doesn't override these...
# not needed currently, but keep it in mind
#sub PRINT { goto &_UDP_PRINT; }
#sub READLINE { goto &_UDP_READLINE; }

1;
__END__

=head1 NAME

Net::UDP - UDP sockets interface module

=head1 SYNOPSIS

    use Net::Gen;		# optional
    use Net::Inet;		# optional
    use Net::UDP;

=head1 DESCRIPTION

The C<Net::UDP> module provides services for UDP communications
over sockets.  It is layered atop the
L<C<Net::Inet>|Net::Inet>
and
L<C<Net::Gen>|Net::Gen>
modules, which are part of the same distribution.

=head2 Public Methods

The following methods are provided by the C<Net::UDP> module
itself, rather than just being inherited from
L<C<Net::Inet>|Net::Inet>
or
L<C<Net::Gen>|Net::Gen>.

=over 4

=item new

Usage:

    $obj = new Net::UDP;
    $obj = new Net::UDP $desthost, $destservice;
    $obj = new Net::UDP \%parameters;
    $obj = new Net::UDP $desthost, $destservice, \%parameters;
    $obj = 'Net::UDP'->new();
    $obj = 'Net::UDP'->new($desthost);
    $obj = 'Net::UDP'->new($desthost, $destservice);
    $obj = 'Net::UDP'->new(\%parameters);
    $obj = 'Net::UDP'->new($desthost, $destservice, \%parameters);

Returns a newly-initialised object of the given class.  If called
for a derived class, no validation of the supplied parameters
will be performed.  (This is so that the derived class can add
the parameter validation it needs to the object before allowing
the validation.)  Otherwise, it will cause the parameters to be
validated by calling its C<init> method, which C<Net::UDP>
inherits from
L<C<Net::Inet>|Net::Inet/init>.  In particular, this means that if
both a host and a service are given, that an object will only be
returned if a connect() call was successful.

The examples above show the indirect object syntax which many prefer,
as well as the guaranteed-to-be-safe static method call.  There
are occasional problems with the indirect object syntax, which
tend to be rather obscure when encountered.  See
http://www.xray.mpe.mpg.de/mailing-lists/perl5-porters/1998-01/msg01674.html
for details.

=item PRINT

Usage:

    $ok = $obj->PRINT(@args);
    $ok = print $tied_fh @args;

This method, intended to be used with tied filehandles, behaves like one
of two inherited methods from the
L<C<Net::Gen>|Net::Gen> class, depending on the
setting of the object parameter C<unbuffered_output>.  If that parameter
is false (the default), then the normal print() builtin is used.
If the C<unbuffered_output> parameter is true, then each print()
operation will actually result in a call to the C<send> method,
requiring that the object be connected or that its message is in
response to its last normal recv() (with a C<flags> parameter of
C<0>).  The value of the $\ variable is ignored in that case, but
the $, variable is still used if the C<@args> array has multiple
elements.

=item READLINE

Usage:

    $line_or_datagram = $obj->READLINE;
    $line_or_datagram = <TIED_FH>;
    $line_or_datagram = readline(TIED_FH);
    @lines_or_datagrams = $obj->READLINE;
    @lines_or_datagrams = <TIED_FH>;
    @lines_or_datagrams = readline(TIED_FH);

This method, intended to be used with tied filehandles, behaves
like one of two inherited methods from the L<C<Net::Gen>|Net::Gen> class,
depending on the setting of the object parameter
C<unbuffered_input>.  If that parameter is false (the default),
then this method does line-buffering of its input as defined by
the current setting of the $/ variable.  If the
<unbuffered_input> parameter is true, then the input records will
be exact recv() datagrams, disregarding the setting of the $/
variable.  Note that invoking the C<READLINE> method in list
context is likely to hang, since UDP sockets typically don't
return EOF.

=back

=head2 Protected Methods

none.

=head2 Known Socket Options

There are no object parameters registered by the C<Net::UDP> module itself.

=head2 Known Object Parameters

The following object parameters are registered by the C<Net::UDP> module
(as distinct from being inherited from
L<C<Net::Gen>|Net::Gen>
or
L<C<Net::Inet>|Net::Inet>):

=over 4

=item unbuffered_input

If true, the C<READLINE> operation on tied filehandles will return each recv()
buffer as though it were a single separate line, independently of the setting
of the $/ variable.  The default is false, which causes the C<READLINE>
interface to return lines split at boundaries as appropriate for $/.
(The C<READLINE> method for tied filehandles is the C<E<lt>FHE<gt>>
operation.)  Note that calling the C<READLINE> method
in list context is likely to hang for UDP sockets.

=item unbuffered_output

If true, the C<PRINT> operation on tied filehandles will result in calls to
the send() builtin rather than the print() builtin, as described in L</PRINT>
above.  The default is false, which causes the C<PRINT> method to use the
print() builtin.

=item unbuffered_IO

This object parameter's value is unreliable on C<getparam> or C<getparams>
method calls.  It is provided as a handy way to set both the
C<unbuffered_output> and C<unbuffered_input> object parameters to the same
value at the same time during C<new> calls.

=back

=head2 TIESCALAR support

Tieing of scalars to a UDP handle is supported by inheritance
from the C<TIESCALAR> method of
L<C<Net::Gen>|Net::Gen/TIESCALAR>.  That method only
succeeds if a call to a C<new> method results in an object for
which the C<isconnected> method returns true, which is why it is
mentioned in regard to this module.

Example:

    tie $x,'Net::UDP',0,'daytime' or die "tie to Net::UDP: $!";
    $x = "\n"; $x = "\n";
    print $y if defined($y = $x);
    untie $x;

This is an expensive re-implementation of C<date> on many
machines.

Each assignment to the tied scalar is really a call to the C<put>
method (via the C<STORE> method), and each read from the tied
scalar is really a call to the C<READLINE> method (via the
C<FETCH> method).

=head2 TIEHANDLE support

As inherited from
L<C<Net::Inet>|Net::Inet>
and
L<C<Net::Gen>|Net::Gen/TIEHANDLE>,
with the addition of
unbuffered I/O options for the C<READLINE> and C<PRINT> methods.

Example:

    tie *FH,'Net::UDP',{unbuffered_IO => 1, thisport => $n, thishost => 0}
	or die;
    while (<FH>) {
	last if is_shutdown_msg($_);
	print FH response($_);
    }
    untie *FH;

This shows how to make a UDP-based filehandle return (and send) datagrams
even when used in the usual perlish paradigm.  For some applications,
this can be helpful to avoid cluttering the message processing code with
the details of handling datagrams.  In particular, this example relies on
the underlying support for replying to the last address in a recvfrom()
for datagram sockets, thus hiding the details of tracking and using
that information.

=head2 Exports

none

=head1 THREADING STATUS

This module has been tested with threaded perls, and should be as thread-safe
as perl itself.  (As of 5.005_03 and 5.005_57, that's not all that safe
just yet.)  It also works with interpreter-based threads ('ithreads') in
more recent perl releases.

=head1 SEE ALSO

L<Net::Inet(3)|Net::Inet>,
L<Net::Gen(3)|Net::Gen>

=head1 AUTHOR

Spider Boardman E<lt>spidb@cpan.orgE<gt>

=cut

#other sections should be added, sigh.

#any real autoloaded methods go after this line

#& _setbuf_unbuf($self, $param, $newvalue) : {'' | "carp string"}
sub _setbuf_unbuf
{
    my ($self,$what,$newval) = @_;
    $self->setparams({unbuffered_input => $newval,
		      unbuffered_output => $newval});
    '';
}

#& PRINT($self, @args) : OKness
sub PRINT : locked method
{
    my $self = shift;
    if ($self->getparam('unbuffered_output')) {
	$self->send(join $, , @_);
    }
    else {
	print {$self} @_;
    }
}

#& READLINE($self) : $line | undef || @lines
sub READLINE : locked method
{
    my $whoami = $_[0]->_trace(\@_,5);
    carp "Excess arguments to ${whoami}, ignored" if @_ > 1;
    my $self = shift;
    if ($self->getparam('unbuffered_input')) {
	if (wantarray) {
	    my ($line,@lines);
	    push @lines, $line while defined($line = $self->recv);
	    @lines;
	}
	else {
	    $self->recv;
	}
    }
    else {
	$self->SUPER::READLINE;
    }
}
