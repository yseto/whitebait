package Whitebait::Config;

use strict;
use warnings;
use utf8;

use Config::ENV 'PLACK_ENV', export => 'config';
use File::Spec::Functions ':ALL';

use constant root => rel2abs(".");

common +{
    db => '/app/var/main.db',
#   load('')
};

1;

