#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use DBI;
use Teng::Schema::Dumper;

use Whitebait::Config;

my $dbh = DBI->connect('dbi:SQLite:dbname=' . config->param('db'), '', '',
+{
    sqlite_unicode => 1,
});

my $datetime = <<__DATETIME__;
    inflate qr/.+_at/ => sub {
        use Time::Piece;
        return Time::Piece->strptime(shift, '%s');
    };
    deflate qr/.+_at/ => sub {
        my (\$col_value) = \@_;
        return ref \$col_value eq 'Time::Piece' ? \$col_value->strftime('%s') : \$col_value;
    };
__DATETIME__

sub any_datetime {
    my $column = shift;
my $datetime = <<__DATETIME__;
    inflate '__COLUMN__' => sub {
        use Time::Piece;
        return Time::Piece->strptime(shift, '%s');
    };
    deflate '__COLUMN__' => sub {
        my (\$col_value) = \@_;
        return ref \$col_value eq 'Time::Piece' ? \$col_value->strftime('%s') : \$col_value;
    };
__DATETIME__

    $datetime =~ s/__COLUMN__/$column/g;
    return $datetime;
}


print Teng::Schema::Dumper->dump(
    dbh       => $dbh,
    namespace => 'Whitebait::Data',
    inflate   => +{
        xen_host => $datetime,
        xen_vm => $datetime,
        xen_ip => $datetime,
    },
);
