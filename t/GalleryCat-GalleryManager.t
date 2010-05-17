use strict;
use warnings;
use Test::More tests => 2;

use Cwd;

BEGIN { 
    use_ok 'GalleryCat::GalleryManager'
}

my $gallery_manager = new GalleryCat::GalleryManager(
    shared_config => {},

    gallery_store_module => '',
    gallery_store_config => {},
    image_store_module => '',
    image_store_config => {},
);

isa_ok( $gallery_manager, 'GalleryCat::GalleryManager', 'gallery_manager');
