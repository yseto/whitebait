package Whitebait::Xen::XMLRPC;

use strict;
use warnings;
use utf8;

use RPC::XML;
$RPC::XML::FORCE_STRING_ENCODING = 1;
use RPC::XML::Client;

sub new {
    my ($class, %arg) = @_;

    bless \%arg, $class;
}

sub login {
    my $self = shift;
    die "need username" unless $self->{username};
    die "need password" unless $self->{password};
    die "need hostname" unless $self->{hostname};

    my $xenserver = $self->{hostname};
    $self->{client} = RPC::XML::Client->new("http://$xenserver/");

    my $response = $self->{client}->simple_request(
        'session.login_with_password',
        $self->{username},
        $self->{password}
    );
    die $RPC::XML::ERROR if $RPC::XML::ERROR;
    $self->{session} = $self->value($response);

    $self;
}

# https://metacpan.org/source/BENBOOTH/Xen-API-0.08/lib/Xen/API.pm
sub value {
    my $self = shift;
    my ($val) = @_;
    my $xenserver = $self->{hostname};

    return $val && ($val->{Status}||'') eq "Success"
        ? $val->{Value}
        : die "Received status \"$val->{Status}\" from xen server at ".$xenserver.": "
          .join(', ',@{$val->{ErrorDescription}||[]});
}

sub request {
    my $self     = shift;
    my $request  = shift or return;
    my $response = $self->{client}->simple_request($request, $self->{session}, @_);
    die $RPC::XML::ERROR if $RPC::XML::ERROR;
    return $self->value($response);
}

1;
