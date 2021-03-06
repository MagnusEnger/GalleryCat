use strict;
use warnings;
use Test::More tests => 24;

use Cwd;
use lib 't/lib';

BEGIN {
    use_ok('GalleryCat::Store::Images::File');
}

# Create test gallery

my $test_gallery_dir = '/tmp/galcat_galleries/';
`rm -rf $test_gallery_dir; cp -r t/fixtures/* $test_gallery_dir/`;
my $base_path = $test_gallery_dir;

my $store = new GalleryCat::Store::Images::File({
    gallery_id          => 'market1',
    path                => $base_path . 'market1/',
    thumbnail_width     => 100,
    thumbnail_height    => 100,
});

my $exif_store = new GalleryCat::Store::Images::File({
    gallery_id => 'exif',
    path => $base_path . 'exif/',
    thumbnail_width     => 100,
    thumbnail_height    => 100,
});


isa_ok( $store, 'GalleryCat::Store::Images::File', 'images store file');

is( $store->image_count, 11, 'found 11 images' );

isa_ok( $store->_image_cache, 'HASH',  'internal image cache' );
isa_ok( $store->_image_order, 'ARRAY', 'internal image order' );

is( $store->images_by_index(0)->[0]->id, '1.jpg', 'Correct first index');
is( $store->images_by_index(1)->[0]->id, '10.jpg', 'Correct second index');  # Images are string sorted


my $images = $store->images_by_index( 2, 4 );
is( $images->[0]->id, '11.jpg', 'Correct multiple index 1');
is( $images->[1]->id, '2.jpg', 'Correct multiple index 2');
is( $images->[2]->id, '3.jpg', 'Correct multiple index 3');

$images = $store->images_by_id( '3.jpg', '2.jpg', '1.jpg' );
is( $images->[0]->id, '3.jpg', 'Correct multiple id 1');
is( $images->[1]->id, '2.jpg', 'Correct multiple id 2');
is( $images->[2]->id, '1.jpg', 'Correct multiple id 3');

isa_ok( $images->[0]->thumbnail, 'GalleryCat::Image', 'thumbnail created' );

$images = $store->images;
is( $images->[0]->id, '1.jpg', 'Correct all id 1' );
is( $images->[10]->id, '9.jpg', 'Correct all id 11' );

# Check extended data from EXIF
# TODO: Add more images for better keyword testing

my $exif_image = $exif_store->images_by_id('lightroom1.jpg')->[0];
is( $exif_image->title,       'Test Title', 'image title from EXIF' );
is( $exif_image->description, 'Test Description', 'image description from EXIF' );
is( $exif_image->keywords,    'keywords, multiple word keyword, test', 'image keywords from EXIF' );

my $keyword_images = $exif_store->images_by_keyword('test');
is( scalar(@$keyword_images), 2, 'two keyword images returned' );

$keyword_images = $exif_store->images_by_keyword('exiftool');
is( $keyword_images->[0]->id, 'exiftool1.jpg', 'correct image returned');

my $keyword_list = $exif_store->keywords;
is( scalar(@$keyword_list), 4, 'got all gallery keywords' );

$keyword_list = $exif_store->keywords('keyword');
is( scalar(@$keyword_list), 2, 'got gallery keyword subset' );

$keyword_list = $exif_store->useful_keywords();
is( scalar(@$keyword_list), 3, 'got useful gallery keywords' );
