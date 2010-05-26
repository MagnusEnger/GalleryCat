use strict;
use warnings;
use Test::More tests => 3;

use Cwd;

BEGIN {
    use_ok 'GalleryCat::GalleryManager';
}

my $gallery_manager = new GalleryCat::GalleryManager(
    shared_config => {},

    gallery_store_config => {
        main_gallery => 'test1',
        galleries_config => {
            test1 => {
                name => 'Test1',
            },
            test2 => {
                name => 'Test2',
            },
        },
    },


    # image_store_module => '',
    # image_store_config => {},
);

isa_ok( $gallery_manager,                   'GalleryCat::GalleryManager',   'gallery_manager');
isa_ok( $gallery_manager->gallery_store,    'GalleryCat::Store::Galleries', 'default gallery_store');

