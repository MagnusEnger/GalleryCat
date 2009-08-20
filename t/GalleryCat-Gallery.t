use strict;
use warnings;
use Test::More tests => 8;

use Cwd;

BEGIN { 
    use_ok 'GalleryCat::Gallery'
}

# Create test gallery

`rm -rf t/galleries; cp -r t/fixtures/* t/`;

my $base_path = getcwd() . '/t/galleries';


# Create a Gallery object to use for these tests. Do a couple of quick
# tests to make sure the Gallery is sane.

my $gallery1 = new GalleryCat::Gallery(
    id              => 'market2',
    base_path       => $base_path,
);

my $gallery2 = new GalleryCat::Gallery(
    id              => 'market',
    gallery_path    => 'market1',
    base_path       => $base_path,
);

is( $gallery1->id, 'market2', 'id' );
my $expected_path = "${base_path}/market2";
is( $gallery1->path, $expected_path, 'path from id' );

$expected_path = "${base_path}/market1";
is( $gallery2->path, $expected_path, 'path from gallery_path' );

is( scalar( @{$gallery1->images}), 8, 'count of images' );
is( scalar( @{$gallery2->images}), 11, 'count of images' );

is( ref($gallery1->images->[0]), 'GalleryCat::Image', 'images are GalleryCat::Images');

is( $gallery1->build_thumbnails, 8, 'thumbnails built' );

# Test failing conditions
# my $bad_gallery = GalleryCat::Gallery->new(
#     id => 'foobar',
# );
#     
# is( $bad_gallery, undef, 'do not create a gallery if the path is bad' );
