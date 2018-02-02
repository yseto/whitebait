package Whitebait::Base;

use strict;
use warnings;
use utf8;
use Exporter 'import';
our @EXPORT = qw(route config throw);

# some ref. https://github.com/cho45/starter.pl/tree/master/templates/mywebapp

use Plack::Request;
use Plack::Response;

use Module::Load;
use Router::Simple;
use Try::Tiny;

use Whitebait::Config;
use Whitebait::Exception;
use Whitebait::View;

use Whitebait::Data;
use Whitebait::Data::Schema;

our $router = Router::Simple->new;

sub new {
    my $class = shift;
    my $env = shift;

    bless {
        req => Plack::Request->new($env),
        res => Plack::Response->new(200),
    }, $class;
}

sub req { shift->{req} }
sub res { shift->{res} }

sub route ($$) {
    $router->connect($_[0], $_[1]);
}

sub throw (%) {
    Whitebait::Exception->throw(@_);
}

sub before_dispatch {
    my ($r) = @_;
}

sub after_dispatch {
    my ($r) = @_;
}

sub run {
    my ($r) = @_;

    $r->before_dispatch;
    try {
        if (my $p = $router->match($r->req->env)) {
            my $action = delete $p->{action};
            my $controller = delete $p->{controller};
            $r->req->env->{'router'} = $p;

            load $controller;
            if ($controller->can($action)) {
                $controller->$action($r);
            } else {
                $r->res->code(404);
            }
        } else {
            $r->res->code(404);
        }
    } catch {
        my ($e) = @_;
        if (ref $e eq 'Whitebait::Exception') {
            $r->res->code($e->code);
            $r->res->body($e->body);
        } else {
            warn $e;
            $r->res->code(503);
            $r->res->body("Internal Server Error");
        }
    };

    $r->after_dispatch;
    $r;
}

sub dbh {
    my $dbh = DBI->connect('dbi:SQLite:dbname=' . config->param('db'), '', '',
    +{
        sqlite_unicode => 1,
    });
    my $teng = Whitebait::Data->new(
        dbh    => $dbh,
        schema => Whitebait::Data::Schema->instance(),
    );
}

1;

