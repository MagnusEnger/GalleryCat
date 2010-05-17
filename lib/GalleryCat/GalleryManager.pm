package GalleryCat::GalleryManager;

use Moose;
use Carp;

use GalleryCat::Gallery;
use Catalyst::Utils;

has 'main_gallery' => (
    is => 'rw',
    isa => 'Str',
);


has 'gallery_store_module' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    default  => 'Memory',
);

has 'gallery_store_config' => (
    is       => 'ro',
    isa      => 'HashRef',
);

has 'gallery_store' => (
    is => 'rw',
    isa => 'Object',
);


has 'image_store_module' => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
    default     => 'File',
);

has 'image_store_config' => (
    is          => 'ro',
    isa         => 'HashRef',
);

has 'image_store' => (
    is          => 'rw',
    isa         => 'Object',
);

has 'shared_config' => (
    is          => 'rw',
    isa         => 'HashRef',
    required    => 0,
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
# 
# sub cover {
#     my ($self) = @_;
#     return $self->images->[ $self->cover_index ];
# }
# 
# sub images {
#     my ($self) = @_;
# 
#     return $self->{cache}->{images} if exists $self->{cache}->{images};
# 
#     my $images = $self->store->images;
# 
#     $self->{cache}->{images} = $images;
# 
#     return $images;
# }
# 
# sub build_thumbnails {
#     my ($self) = @_;
# 
#     my %thumbnail_map = map { $_ => 1 } @{ $self->list_thumbnails };
# 
#     return $self->store->build_thumbnails;
# }
# 
# sub list_thumbnails {
#     my ( $self ) = @_;
#     
#     return $self->store->list_thumbnails;
# }
# 
# sub path {
#     return shift->store->path(@_);
# }
# 
# sub thumbnail_path {
#     return shift->store->thumbnail_path(@_);
# }
# 
# sub thumbnail_uri_path {
#     my $self = shift;
#     return $self->uri_path( $self->thumbnail_dir, @_ );
# }
# 
# sub image_uri {
#     my ( $self, @rest ) = @_;
#     return $self->store->image_uri( @rest );
# }
# 
# sub thumbnail_uri {
#     my ( $self, @rest ) = @_;
#     return $self->store->thumbnail_uri( @rest );
# }
# 
# sub uri_path {
#     my ( $self, @rest ) = @_;
# 
#     my $uri_base = $self->uri_base;
#     my @path_parts;
# 
#     push @path_parts, $self->uri_base
#       if defined( $self->uri_base );
# 
#     push @path_parts,
#       $self->gallery_uri_path || $self->id;
# 
#     push @path_parts, @rest;
# 
#     return join '/', @path_parts;
# }

no Moose;

=head1 NAME

GalleryCat::GalleryManager - Moose class for managing Galleries

=head1 DESCRIPTION


=head1 AUTHOR

Todd Holbrook

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
