package Whitebait::Data::Schema;
use strict;
use warnings;
use DBI qw/:sql_types/;
use Teng::Schema::Declare;
table {
    name 'xen_host';
    pk 'id';
    columns (
        'id',
        'hostname',
        'create_at',
        'update_at',
    );
    inflate qr/.+_at/ => sub {
        use Time::Piece;
        return Time::Piece->strptime(shift, '%s');
    };
    deflate qr/.+_at/ => sub {
        my ($col_value) = @_;
        return ref $col_value eq 'Time::Piece' ? $col_value->strftime('%s') : $col_value;
    };
};

table {
    name 'xen_ip';
    pk 'id';
    columns (
        'id',
        'ipaddr',
        'xen_vm_id',
        'create_at',
        'update_at',
    );
    inflate qr/.+_at/ => sub {
        use Time::Piece;
        return Time::Piece->strptime(shift, '%s');
    };
    deflate qr/.+_at/ => sub {
        my ($col_value) = @_;
        return ref $col_value eq 'Time::Piece' ? $col_value->strftime('%s') : $col_value;
    };
};

table {
    name 'xen_vm';
    pk 'id';
    columns (
        'id',
        'hostname',
        'xen_host_id',
        'create_at',
        'update_at',
    );
    inflate qr/.+_at/ => sub {
        use Time::Piece;
        return Time::Piece->strptime(shift, '%s');
    };
    deflate qr/.+_at/ => sub {
        my ($col_value) = @_;
        return ref $col_value eq 'Time::Piece' ? $col_value->strftime('%s') : $col_value;
    };
};

1;
