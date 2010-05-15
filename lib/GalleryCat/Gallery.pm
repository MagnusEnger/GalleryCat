package GalleryCat::Gallery;

use Moose;
use Carp;

use IO::Dir;
use Path::Class;
use GalleryCat::Image;
use Catalyst::Utils;

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


has 'thumbnails_per_page' => (
    is      => 'ro',
    isa     => 'Int',
    default => 5,
);

has 'gallery_height' => (
    is      => 'ro',
    isa     => 'Str',
    default => 500,
);

has 'thumbnail_max_width' => (
    is      => 'ro',
    isa     => 'Int',
    default => 150,
);

has 'thumbnail_max_height' => (
    is      => 'ro',
    isa     => 'Int',
    default => 150,
);


has 'store_module' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    default  => 'File',
);

has 'store_config' => (
    is       => 'ro',
    isa      => 'HashRef',
);

has 'store' => (
    is => 'rw',
    isa => 'Object',
);


has 'resizer_module' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    default  => 'Resize',
);

has 'resizer_config' => (
    is       => 'ro',
    isa      => 'HashRef',
);

has 'resizer' => (
    is  => 'rw',
    isa => 'Object',
    lazy => 1,
    default => sub {
        my $self = shift;
        my $resizer_module = 'GalleryCat::Resizer::' . $self->resizer_module;
        eval "require $resizer_module;";
        return $self->resizer( $resizer_module->new() );
    }
);


has 'cover_index' => (
    is      => 'ro',
    isa     => 'Int',
    default => 0,
);

sub BUILD {
    my $self = shift;

    # my $store_module = 'GalleryCat::Store::' . $self->store_module;
    # eval "require $store_module;";
    # my $store_config = $self->store_config || {};
    # $store_config->{gallery} = $self;
    # $self->store( $store_module->new( $store_config ) );

    return $self;
}


# Returns an image for the cover of a gallery.  Not sure what it should do if the gallery has no images for some reason.
# Perhaps return a default image?

sub cover {
    my ($self) = @_;
    return $self->images->[ $self->cover_index ];
}

sub images {
    my ($self) = @_;

    return $self->{cache}->{images} if exists $self->{cache}->{images};

    my $images = $self->store->images;

    $self->{cache}->{images} = $images;

    return $images;
}

sub build_thumbnails {
    my ($self) = @_;

    my %thumbnail_map = map { $_ => 1 } @{ $self->list_thumbnails };

    return $self->store->build_thumbnails;
}

sub list_thumbnails {
    my ( $self ) = @_;
    
    return $self->store->list_thumbnails;
}

sub path {
    return shift->store->path(@_);
}

sub thumbnail_path {
    return shift->store->thumbnail_path(@_);
}

sub thumbnail_uri_path {
    my $self = shift;
    return $self->uri_path( $self->thumbnail_dir, @_ );
}

sub image_uri {
    my ( $self, @rest ) = @_;
    return $self->store->image_uri( @rest );
}

sub thumbnail_uri {
    my ( $self, @rest ) = @_;
    return $self->store->thumbnail_uri( @rest );
}

sub uri_path {
    my ( $self, @rest ) = @_;

    my $uri_base = $self->uri_base;
    my @path_parts;

    push @path_parts, $self->uri_base
      if defined( $self->uri_base );

    push @path_parts,
      $self->gallery_uri_path || $self->id;

    push @path_parts, @rest;

    return join '/', @path_parts;
}

sub image_count {
    return shift->store->image_count();
}

sub images {
    return shift->store->images(@_);
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
