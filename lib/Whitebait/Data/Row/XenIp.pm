package Whitebait::Data::Row::XenIp;
use strict;
use parent qw(Whitebait::Data::Row);

sub vm {
    my $self = shift;
    $self->handle->single('xen_vm', { id => $self->xen_vm_id });
}

1;
