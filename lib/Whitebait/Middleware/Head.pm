package Whitebait::Middleware::Head;
use strict;
use warnings;
use parent qw(Plack::Middleware);

sub call {
    my($self, $env) = @_;

    return $self->app->($env)
        unless $env->{REQUEST_METHOD} eq 'HEAD';

    my $ua = $env->{HTTP_USER_AGENT} || '';
    if ($ua =~ /^git\/1.6.4/) {
        $env->{REQUEST_METHOD} = 'GET';
    }

    $self->response_cb($self->app->($env), sub {
        my $res = shift;
        if ($res->[2]) {
            $res->[2] = [];
        } else {
            return sub {
                return defined $_[0] ? '': undef;
            };
        }
    });
}

1;

__END__

refer Plack::Middleware::Head

一部のサーバーのgitが古く、 P::A::GitSmartHttp との相性が
悪かった。どちらを直すこともできなかった。

git/1.6.4 が HEAD リクエストを行っており、 405 Method Not Allowed
を返したのが問題であると見受けられた。
P::A::GitSmartHttp には、 GET であれば動作することがわかったので、
P::M::Head をコピーして、この Middleware を書いた

後続の $app については、gitのクライアントだった場合は、 HEAD
リクエストを GET として書き換えてリレーする

