package GalleryCat::Store::Images;

use Moose;
use Carp;

use GalleryCat::Image;

has 'gallery_id' => (
    is      => 'ro',
    isa     => 'Str',
    required => 1,
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
