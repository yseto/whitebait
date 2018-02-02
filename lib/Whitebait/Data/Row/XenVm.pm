package Whitebait::Data::Row::XenVm;
use strict;
use parent qw(Whitebait::Data::Row);

sub host {
    my $self = shift;
    $self->handle->single('xen_host', { id => $self->xen_host_id });
}

sub expire_ips {
    my $self = shift;
    $_->delete for $self->handle->search('xen_ip', { xen_vm_id => $self->id });
}

1;
