use strict;
use warnings;
use Test::More tests => 7;

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
    store_config    => {
        base_path       => $base_path,
    }
);

my $gallery2 = new GalleryCat::Gallery(
    id              => 'market',
    store_config    => {
        gallery_path    => 'market1',
        base_path       => $base_path,
    }
);

is( $gallery1->id, 'market2', 'id' );
is( ref($gallery1->store), 'GalleryCat::Store::File', 'default File store loaded');
is( ref($gallery1->resizer), 'GalleryCat::Resizer::Resize', 'default Resize resizer loaded');

is( scalar( @{$gallery1->images}), 8, 'count of images' );
is( scalar( @{$gallery2->images}), 11, 'count of images' );

is( ref($gallery1->images->[0]), 'GalleryCat::Image', 'images are GalleryCat::Images');


# Test failing conditions
# my $bad_gallery = GalleryCat::Gallery->new(
#     id => 'foobar',
# );
#     
# is( $bad_gallery, undef, 'do not create a gallery if the path is bad' );
