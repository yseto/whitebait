package Whitebait::Xen;

use strict;
use warnings;
use utf8;

use Whitebait::Base qw(throw);

use Time::Piece;
use Whitebait::Xen::XMLRPC;

#
# VMがXenの親機でどこかを示す
#

sub index {
    my ($class, $r) = @_;
    my $ip = $r->req->env->{REMOTE_ADDR};
    my $rec = $r->dbh->single('xen_ip', +{ ipaddr => $ip });
    if ($rec) {
        $r->res->body($rec->vm->host->hostname);
        return;
    }
    throw code => 404, body => "missing on table\n";
}

#
# XenCenter上のホスト名を返します
#

sub whoami {
    my ($class, $r) = @_;
    my $ip = $r->req->env->{REMOTE_ADDR};
    my $rec = $r->dbh->single('xen_ip', +{ ipaddr => $ip });
    if ($rec) {
        $r->res->body($rec->vm->hostname);
        return;
    }
    throw code => 404, body => "missing on table\n";
}

########################################

#
# Xenの親機から情報を取得し、格納する
#

sub update {
    my ($class, $r) = @_;
    my $hostname = $r->req->env->{router}{server};

    my $server = $r->dbh->single('xen_host', +{ hostname => $hostname });

    unless ($server) {
        throw code => 404, body => 'server not found';
        return;
    }

    my @servers = $class->_xen($hostname);
    foreach my $vm (@servers) {
        my $rec = $r->dbh->single('xen_vm', +{
            hostname => $vm->{hostname},
        });
        if ($rec) {
            $rec->update(+{
                xen_host_id => $server->id,
                update_at => Time::Piece->new,
            });
        } else {
            $rec = $r->dbh->insert('xen_vm', +{
                hostname => $vm->{hostname},
                xen_host_id => $server->id,
                create_at => Time::Piece->new,
                update_at => Time::Piece->new,
            });
        }
        $rec->expire_ips;
        foreach my $ip (@{$vm->{ipaddrs}}) {
            my $iprec = $r->dbh->single('xen_ip', +{
                ipaddr => $ip,
            });
            if ($iprec) {
                $iprec->update(+{
                    xen_vm_id => $rec->id,
                    update_at => Time::Piece->new,
                });
            } else {
                $r->dbh->insert('xen_ip', +{
                    ipaddr => $ip,
                    xen_vm_id => $rec->id,
                    create_at => Time::Piece->new,
                    update_at => Time::Piece->new,
                });
            }
        }
    }
    $r->res->content_type('text/plain');
    throw code => 200, body => 'OK';
}

#
# Xenの親機を登録する
#

sub insert {
    my ($class, $r) = @_;
    my $hostname = $r->req->env->{router}{server};

    if ($r->dbh->single('xen_host', +{ hostname => $hostname })) {
        throw code => 400, body => 'already exists';
    }

    $r->dbh->insert('xen_host', +{
        hostname => $hostname,
        create_at => Time::Piece->new,
        update_at => Time::Piece->new,
    });

    $r->res->content_type('text/plain');
    throw code => 201, body => "insert $hostname";
}

########################################

sub rpc {
    my ($class, $server) = @_;
    my $username = $ENV{XENSERVER_USERNAME} || 'root';
    my $password = $ENV{XENSERVER_PASSWORD} || '';
    my $xmlrpc = Whitebait::Xen::XMLRPC->new(
        username => $username,
        password => $password,
        hostname => $server)->login;
}

sub _xen {
    my ($class, $server) = @_;
    my @servers;

    my $xmlrpc = $class->rpc($server);
    # http://tokibito.hatenablog.com/entry/20110126/1295967697
    foreach my $host (@{$xmlrpc->request('host.get_all')}) {
        my $target_host = $xmlrpc->request('host.get_record', $host);
        foreach my $vm (@{$target_host->{resident_VMs}}) {
            my $data = $xmlrpc->request('VM.get_record', $vm);
            #       warn Dumper $data->{tags};
            next if (
                $data->{other_config}{is_system_domain} and
                $data->{other_config}{is_system_domain} eq 'true');
    
            my $metric = $xmlrpc->request('VM.get_guest_metrics', $vm);
            my $network = $xmlrpc->request('VM_guest_metrics.get_networks', $metric);
            my %doc = (
                hostname => $data->{name_label},
            );
            my @ips;
            foreach (keys %$network) {
                next if $_ =~ /ipv6/;
                push @ips, $network->{$_};
            }
            $doc{ipaddrs} = \@ips;
            push @servers, \%doc;
        }
    }
    return @servers;
}

1;

__END__

