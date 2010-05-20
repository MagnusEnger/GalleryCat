use strict;
use warnings;
use Test::More tests => 6;

use Cwd;

BEGIN { 
    use_ok('GalleryCat::Store::Galleries::Memory');
}

my $store = new GalleryCat::Store::Galleries::Memory(
    main_gallery => 'test1',
    galleries_config => {
        test1 => {
            name => 'Test1',
        },
        test2 => {
            name => 'Test2',
        },
    },
);

isa_ok( $store, 'GalleryCat::Store::Galleries::Memory', 'galleries store memory');

my $internal_galleries = $store->_galleries;
isa_ok( $internal_galleries, 'HASH', 'internal galleries stored');
is( scalar keys %{$internal_galleries}, 2, '2 internal galleries stored');


is( $store->gallery_count(), 2, 'gallery count()' );

ok( defined($store->logger), 'inherited a logger object' );

is( $store->main_gallery, 'test1', 'main gallery set');

my $gallery = $store->galleries('test1');

isa_ok( $gallery, 'GalleryCat::Gallery', 'gallery object by id');
is( $gallery->id, 'test1', 'gallery object by id');