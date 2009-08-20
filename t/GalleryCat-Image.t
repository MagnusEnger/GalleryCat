use strict;
use warnings;
use Test::More tests => 6;

use Cwd;

BEGIN { use_ok 'GalleryCat::Gallery' }
BEGIN { use_ok 'GalleryCat::Image' }

# Create test gallery

#`rm -rf t/galleries; cp -r t/fixtures t/galleries`;

# Create a Gallery object to use for these tests. Do a couple of quick
# tests to make sure the Gallery is sane.

my $gallery = new GalleryCat::Gallery(
    id              => 'market2',
    base_path       => getcwd() . '/t/galleries',
);

is( $gallery->id, 'market2', 'gallery id sanity check' );

my $image = $gallery->images->[0];

is( ref($image), 'GalleryCat::Image', 'image from gallery is a GalleryCat::Image');

is( $image->width, 602, 'image width');
is( $image->height, 400, 'image height');