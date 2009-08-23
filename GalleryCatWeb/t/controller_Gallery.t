use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'GalleryCatWeb' }
BEGIN { use_ok 'GalleryCatWeb::Controller::Gallery' }

ok( request('/gallery')->is_success, 'Request should succeed' );


