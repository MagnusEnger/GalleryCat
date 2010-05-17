use strict;
use warnings;
use Test::More tests => 3;

use Cwd;

BEGIN { 
    use_ok('GalleryCat::Logger::Default');
}

my $logger = new GalleryCat::Logger::Default();

isa_ok( $logger, 'GalleryCat::Logger::Default', 'default logger');
can_ok( $logger, 'warn', 'info', 'trace', 'fatal', 'error', 'debug' );
