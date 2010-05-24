package GalleryCat::Image;

# use Image::Info qw(image_info);

use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Types::URI qw(Uri);
use MooseX::Types::Path::Class qw(File);


has id => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

has uri => (
    is          => 'rw',
    isa         => Uri,
    required    => 0,
    coerce      => 1,
);

has file => (
    is          => 'rw',
    isa         => File,
    coerce      => 1,
    required    => 0,
);

has thumbnail => (
    is          => 'rw',
    isa         => 'GalleryCat::Image',
    required    => 0,
);

has image_data => (
    is          => 'rw',
    isa         => 'Maybe',
);

has title => (
    is          => 'rw',
    isa         => 'Maybe[Str]',
    required    => 0,
);

has description => (
    is          => 'rw',
    isa         => 'Maybe[Str]',
    required    => 0,
);

has keywords => (
    is          => 'rw',
    isa         => 'Maybe[Str]',
    required    => 0,
);


# Image attributes like sizes, things from EXIF data, etc.

has width => (
    is  => 'rw',
    isa => 'Int',
);

has height => (
    is  => 'rw',
    isa => 'Int',
);




sub data {
    return undef;
}

no Moose;

1;

=head1 NAME

GalleryCat::Model::GalleryCat::Image - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

Todd Holbrook

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
