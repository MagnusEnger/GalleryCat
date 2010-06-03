package GalleryCat::Store::Images;

use Moose;
use Carp;

extends 'GalleryCat::Store';

use GalleryCat::Image;

has 'gallery_id' => (
    is      => 'ro',
    isa     => 'Str',
    required => 1,
);

has 'thumbnail_width' => (
    is          => 'rw',
    isa         => 'Int',
    required    => 1,
);

has 'thumbnail_height' => (
    is          => 'rw',
    isa         => 'Int',
    required    => 1,
);

has 'read_exif' => (
    is => 'ro',
    required => 1,
    default => 1,
);

has 'resizer_module' => (
    is      => 'ro',
    isa     => 'Str',
    default => 'GDCenterCrop',
);



no Moose;

=head1 NAME

GalleryCat::Store::Images - Base class for images stores

=head1 DESCRIPTION


=head1 AUTHOR

Todd Holbrook

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
