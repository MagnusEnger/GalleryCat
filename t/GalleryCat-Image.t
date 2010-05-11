use strict;
use warnings;
use Test::More tests => 6;

use Cwd;

BEGIN { use_ok 'GalleryCat::Gallery' }
BEGIN { use_ok 'GalleryCat::Image' }

# Create test gallery

my $test_gallery_dir = '/tmp/galcat_galleries';
`rm -rf $test_gallery_dir; cp -r t/fixtures/* $test_gallery_dir/`;
my $base_path = $test_gallery_dir;

# Create a Gallery object to use for these tests. Do a couple of quick
# tests to make sure the Gallery is sane.

my $gallery = new GalleryCat::Gallery(
    id              => 'market2',
    store_config    => {
        base_path       => $base_path,
    }
);

my $gallery2 = new GalleryCat::Gallery(
    id              => 'exif',
    store_config    => {
        base_path       => $base_path,
    }
);

is( $gallery->id, 'market2', 'gallery id sanity check' );

my $image       = $gallery->images->[0];
my $exif_image1 = $gallery2->images->[0];

is( ref($image), 'GalleryCat::Image', 'image from gallery is a GalleryCat::Image');

is( $image->width, 602, 'image width');
is( $image->height, 400, 'image height');

isnt( $image->uri, undef, 'Got something back for uri()');
isnt( $image->thumbnail_uri, undef, 'Got something back for thumbnail_uri()');
#is( $image->uri, undef, 'Got something back for display_uri()');

is( $exif_image1->id, 'lightroom1.jpg', 'File ID read.' );
is( $exif_image1->title, 'Test Title', 'EXIF title read.' );
is( $exif_image1->description, 'Test Description', 'EXIF description read.' );
is( $exif_image1->keywords, 'keywords, multiple word keyword, test', 'EXIF keywords read.');
