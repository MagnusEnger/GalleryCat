use strict;
use warnings;
use Test::More tests => 16;

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
    gallery_id => 'market1',
    path => $base_path . 'market1/',
});

isa_ok( $store, 'GalleryCat::Store::Images::File', 'images store file');
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
