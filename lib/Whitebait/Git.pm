package Whitebait::Git;

use strict;
use warnings;
use utf8;

use Cwd ();
use File::chdir;
use File::Spec::Functions;
use File::Which qw(which);

use Whitebait::Base qw(throw);

sub pull {
    my ($class, $r) = @_;
    my $reponame = $r->req->env->{router}{name};

    my $root = "/app/var/git/";
    my $dir = catdir($root, $reponame);

    unless (-d $dir) {
        throw code => 400, body => 'repository not found';
    }

    {
        local $CWD = $dir;
        system($class->git_command(qw(fetch origin refs/heads/*:refs/heads/*)) );
    }

    $r->res->body("pull done");
}

sub git_command {
    my $class = shift;
    my @commands = @_;
    my $git_bin = which('git');
    return ($git_bin, @commands);
}

1;

