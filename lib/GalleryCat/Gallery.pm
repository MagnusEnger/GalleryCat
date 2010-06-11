package GalleryCat::Gallery;

use Moose;
use Moose::Util::TypeConstraints;
use Carp;

use GalleryCat::Image;

use String::Util qw(hascontent);

has 'id' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has 'name' => (
    is  => 'rw',
    isa => 'Str',
    lazy => 1,
    default => sub { $_[0]->id },
);

has 'description' => (
    is  => 'ro',
    isa => 'Str',
);

has 'date' => (
    is => 'ro',
    isa => 'Date',
);

has 'parent' => (
    is => 'rw',
    isa => 'Str|Int',
);

has 'order' => (
    is => 'rw',
    isa => 'Int',
    default => 0,
);

has 'format' => (
    is => 'rw',
    isa => enum([ qw( galleries images ) ]),
    default => 'images',
);

has 'theme' => (
    is => 'rw',
    isa => 'Str',
);

has 'hidden' => (
    is => 'ro',
    isa => 'Bool',
    default => 0,
);

has 'password' => (
    is => 'ro',
    isa => 'Bool',
    default => 0,
);

has 'galleries' => (
    is => 'rw',
    isa => 'ArrayRef',
    required => 0,
);

has 'uri_base' => (
    is  => 'ro',
    isa => 'Str',
);

has 'gallery_uri_path' => (
    is  => 'ro',
    isa => 'Str',
);


has 'gallery_height' => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    builder => 'max_image_height',
);

has 'gallery_image_width' => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    builder => 'max_image_width',
);

has 'gallery_info_width' => (
    is      => 'ro',
    isa     => 'Int',
);

has 'gallery_info_height' => (
    is      => 'ro',
    isa     => 'Int',
    default => 50,
);


has 'thumbnails_per_page' => (
    is      => 'ro',
    isa     => 'Int',
    default => 5,
);

has 'thumbnail_width' => (
    is      => 'ro',
    isa     => 'Int',
    default => 150,
);

has 'thumbnail_height' => (
    is      => 'ro',
    isa     => 'Int',
    default => 150,
);


has 'images_store_module' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    default  => 'File',
);

has 'images_store_config' => (
    is       => 'ro',
    isa      => 'HashRef',
    default  => sub {{}},
);

has 'images_store' => (
    is          => 'rw',
    isa         => 'Object',
    handles     => [ qw( images_count max_image_width max_image_height keywords ) ],

);

has 'cover_index' => (
    is      => 'rw',
    isa     => 'Int',
);

has 'cover_id' => (
    is      => 'rw',
    isa     => 'Str|Int',
);

sub BUILD {
    my $self = shift;

    my $store_module = 'GalleryCat::Store::Images::' . $self->images_store_module;
    eval "require $store_module;";
    my $store_config = $self->images_store_config;
    $store_config->{gallery_id} = $self->id;
    $store_config->{thumbnail_width} = $self->thumbnail_width;
    $store_config->{thumbnail_height} = $self->thumbnail_height;
    $self->images_store( $store_module->new( $store_config ) );
    return $self;
}


# Returns an image for the cover of a gallery.  Not sure what it should do if the gallery has no images for some reason.
# Perhaps return a default image?

sub cover {
    my ($self) = @_;
    return    $self->cover_id    ? $self->store->images_by_id( $self->cover_id )
            : $self->cover_index ? $self->store->images_by_index( $self->cover_index )
            : undef;
}

sub images {
    my ($self, @rest) = @_;
    return $self->images_store->images(@rest);
}

sub images_by_index {
    my ($self, @rest) = @_;
    return $self->images_store->images_by_index(@rest);
}

sub images_by_id {
    my ($self, @rest) = @_;
    return $self->images_store->images_by_id(@rest);
}

sub images_by_keyword {
    my ($self, @rest) = @_;
    return $self->images_store->images_by_keyword(@rest);
}


sub image_count {
    return shift->images_store->image_count();
}


# Takes the gallery's theme name and cleans it up so it's suitable for a path. I'm sure
# there's a better way to do this, but since it should just be gallery owners setting
# themes this is probably safe/flexible enough.

sub themepath {
    my $self = shift;
    my $theme = $self->theme;
    return undef if !hascontent($theme);
    
    $theme =~ tr/A-Za-z0-9_-//cd;
    
    return $theme;
}

no Moose;

=head1 NAME

GalleryCat::Gallery - Moose class for handling Galleries

=head1 DESCRIPTION


=head1 AUTHOR

Todd Holbrook

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
