use strict;
use warnings;
use Test::More tests => 20;

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

my $exif_image = $exif_store->images_by_index(0)->[0];
is( $exif_image->title,       'Test Title', 'image title from EXIF' );
is( $exif_image->description, 'Test Description', 'image description from EXIF' );
is( $exif_image->keywords,    'keywords, multiple word keyword, test', 'image keywords from EXIF' );



# 
# my $internal_galleries = $store->_galleries;
# isa_ok( $internal_galleries, 'HASH', 'internal galleries stored');
# is( scalar keys %{$internal_galleries}, 3, '3 internal galleries stored');
# 
# is( $store->gallery_count(), 3, 'gallery count()' );
# 
# ok( defined($store->logger), 'inherited a logger object' );
# 
# is( $store->main_gallery, 'test1', 'main gallery set');
# 
# # Get single gallery
# my $gallery = $store->gallery('test1');
# isa_ok( $gallery, 'GalleryCat::Gallery', 'gallery object by id');
# is( $gallery->id, 'test1', 'gallery object by id');
# 
# # Get multiple galleries
# my $galleries = $store->galleries( 'test1', 'test3' );
# isa_ok( $galleries, 'ARRAY', 'multiple galleries' );
# is( scalar(@$galleries), 2, 'Got two galleries' );
# is( $galleries->[0]->id, 'test1', 'correct first gallery');
# is( $galleries->[1]->id, 'test3', 'correct second gallery');
# 
# 
# # Check that parent/child relationships were set up correctly.
# my $gallery_kids = $gallery->galleries;
# isa_ok( $gallery_kids, 'ARRAY', 'galleries' );
# is( scalar(@$gallery_kids), 2, 'Got two gallery children' );
# is_deeply( $gallery_kids, ['test3', 'test2'], 'correctly ordered children' );
# 
