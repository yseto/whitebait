#!/usr/bin/env perl

use utf8;
use strict;
use warnings;

use FindBin;
use Plack::App::GitSmartHttp;
use Plack::Builder;

use lib qq($FindBin::Bin/lib/);
use Whitebait;

builder {
    enable 'ReverseProxy';
    enable 'AccessLog', format => 'common';

    enable '+Whitebait::Middleware::Head';

    mount '/git' => Plack::App::GitSmartHttp->new(
        root          => "/app/var/git",
        upload_pack   => 1,
        received_pack => 0
    )->to_app;

    mount '/' => sub {
        Whitebait->new(shift)->run->res->finalize;
    }
};


