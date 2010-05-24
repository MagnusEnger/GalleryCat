package GalleryCat::GalleryManager;

use Moose;
use Carp;

use GalleryCat::Gallery;
use Catalyst::Utils;


has 'gallery_store_module' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    default  => 'Memory',
);

has 'gallery_store_config' => (
    is       => 'ro',
    isa      => 'HashRef',
    default  => sub {{}},
);

has 'gallery_store' => (
    is => 'rw',
    isa => 'Object',
    handles => [ 'main_gallery', 'gallery', 'galleries' ],
);


has 'shared_config' => (
    is          => 'rw',
    isa         => 'HashRef',
    required    => 0,
);

sub BUILD {
    my $self = shift;

    # TODO: Merge shared config options

    my $store_module = 'GalleryCat::Store::Galleries::' . $self->gallery_store_module;
    eval "require $store_module;";
    my $store_config = $self->gallery_store_config;
    $self->gallery_store( $store_module->new( $store_config ) );

    return $self;
}

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
