package Whitebait;

use strict;
use warnings;
use utf8;

use Whitebait::Base;
use parent qw(Whitebait::Base);

route '/',    { controller => 'Whitebait', action => 'index' };
#     '/git' => on app psgi
route '/xen', { controller => 'Whitebait::Xen', action => 'index' };
route '/xen/whoami', { controller => 'Whitebait::Xen', action => 'whoami' };
route '/xen/update/:server', { controller => 'Whitebait::Xen', action => 'update' };
route '/xen/insert/:server', { controller => 'Whitebait::Xen', action => 'insert' };
route '/repos/pull/:name', { controller => 'Whitebait::Git', action => 'pull' };

sub index {
    my ($class, $r) = @_;
    $r->res->content_type('text/plain');
# http://patorjk.com/software/taag/#p=display&f=Slant&t=Whitebait
    $r->res->body(<<EOT);
 _       ____    _ __       __          _ __ 
| |     / / /_  (_) /____  / /_  ____ _(_) /_
| | /| / / __ \/ / __/ _ \/ __ \/ __ `/ / __/
| |/ |/ / / / / / /_/  __/ /_/ / /_/ / / /_  
|__/|__/_/ /_/_/\__/\___/_.___/\__,_/_/\__/  
                                             

/ - HERE
/git/mackerel - git repository for mackerel
/xen - Where are you from.
/xen/whoami - Are you on Xen?
EOT
}

1;

