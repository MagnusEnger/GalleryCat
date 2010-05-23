use strict;
use warnings;
use Test::More tests => 11;

use Cwd;

BEGIN { 
    use_ok 'GalleryCat::Gallery'
}

# Create test gallery

my $test_gallery_dir = '/tmp/galcat_galleries';
`rm -rf $test_gallery_dir; cp -r t/fixtures/* $test_gallery_dir/`;
my $base_path = $test_gallery_dir;


# Create a Gallery object to use for these tests. Do a couple of quick
# tests to make sure the Gallery is sane.

my $gallery1 = new GalleryCat::Gallery(
    id              => 'market2',
    parent          => 'market',
    order           => 0,
    images_store_module => 'Null',
    images_store_config => {
        base_path       => $base_path,
    }
);

my $gallery2 = new GalleryCat::Gallery(
    id              => 'market',
    name            => 'Test Gallery',
    format          => 'galleries',
    images_store_module => 'Null',
    images_store_config => {
        gallery_path    => 'market1',
        base_path       => $base_path,
    }
);

my $gallery3 = new GalleryCat::Gallery(
    id              => 'subgallery',
    name            => 'Sub Gallery',
    parent          => 'market',
    order           => 1,
    images_store_module => 'Null',
    images_store_config => {
        gallery_path    => 'market-sub',
        base_path       => $base_path,
    }
);

is( $gallery1->id, 'market2', 'id' );
is( $gallery1->name, 'market2', 'default name' );
is( $gallery2->name, 'Test Gallery', 'explicit name' );

is( ref($gallery1->images_store), 'GalleryCat::Store::Images::Null', 'Null Images store loaded');
#is( ref($gallery1->resizer), 'GalleryCat::Resizer::Resize', 'default Resize resizer loaded');


is( $gallery1->format, 'images',    'correct set format');
is( $gallery2->format, 'galleries', 'correct default format');

# is( $gallery1->image_count,  8, 'count of images' );
# is( $gallery1->image_count, 11, 'count of images' );


# is( ref($gallery1->images->[0]), 'GalleryCat::Image', 'images are GalleryCat::Images');



# Test failing conditions
# my $bad_gallery = GalleryCat::Gallery->new(
#     id => 'foobar',
# );
#     
# is( $bad_gallery, undef, 'do not create a gallery if the path is bad' );
