use strict;
use warnings;
use Test::More tests => 9;

use Cwd;
use URI;

BEGIN { use_ok 'GalleryCat::Image' }

# Create test gallery

my $test_gallery_dir = '/tmp/galcat_galleries';
`rm -rf $test_gallery_dir; cp -r t/fixtures/* $test_gallery_dir/`;
my $base_path = $test_gallery_dir;

# Create an Image 

my $image = new GalleryCat::Image(
    id          => 'market2',
    path        => "${test_gallery_dir}/galleries/exif/lightroom1.jpg",
    uri         => URI->new('http://www.test.com/uri'),
    width       => 200,
    height      => 300,
    title       => 'Test Image',
    description => 'Test Description',
    keywords    => 'test, keywords',
);

isa_ok( $image, 'GalleryCat::Image', 'mocked first image');

my $thumbnail = new GalleryCat::Image(
    id          => 'thumbnail-market2',
    path        => "${test_gallery_dir}/galleries/exif/thumbnails/lightroom1.jpg",
    uri         => 'http://www.test.com/uri/thumbnail',
    width       => 67,
    height      => 100,
);

isa_ok( $thumbnail, 'GalleryCat::Image', 'mocked thumbnail image');

$image->thumbnail( $thumbnail );

isa_ok( $image->thumbnail,      'GalleryCat::Image', 'got back a thumbnail image');
is(     $image->thumbnail->id,  'thumbnail-market2', 'got back expected thumbnail image');

isa_ok( $image->uri,      'URI', 'explicit URI object' );
isa_ok( $thumbnail->uri,  'URI', 'coerced URI object' );

is( $image->width,  200, 'image width');
is( $image->height, 300, 'image height');

# is( $exif_image1->id, 'lightroom1.jpg', 'File ID read.' );
# is( $exif_image1->title, 'Test Title', 'EXIF title read.' );
# is( $exif_image1->description, 'Test Description', 'EXIF description read.' );
# is( $exif_image1->keywords, 'keywords, multiple word keyword, test', 'EXIF keywords read.');
