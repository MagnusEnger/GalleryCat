package GalleryCat::Store::Galleries::Memory;

use Moose;

use Hash::Merge qw(merge);
use List::Flatten qw(flat);

use GalleryCat::Gallery;

extends 'GalleryCat::Store::Galleries';

has 'shared_config' => (
    is          => 'ro',
    isa         => 'HashRef',
    default     => sub {{}},
    required    => 0,
);

has 'galleries_config' => (
    is          => 'ro',
    isa         => 'HashRef',
    required    => 1,
    default     => sub {{}},
);

has 'main_gallery' => (
    is          => 'rw',
    isa         => 'Str|Int',
    required    => 0,
);

has '_galleries' => (
    is          => 'rw',
    isa         => 'HashRef',
    default     => sub {{}},
);


sub BUILD {
    my $self = shift;

    my $shared_config = $self->shared_config();
    my $galleries = $self->_galleries();

    # Create Gallery objects for all configured galleries
    while ( my ( $id, $config ) = each( %{ $self->galleries_config() } ) ) {

        $self->logger->trace('Memory store loading gallery: ', $id);

        my $merged_config = merge( $shared_config, $config );
        if ( !exists $merged_config->{id} ) {
            $merged_config->{id} = $id;
        }

        my $gallery = GalleryCat::Gallery->new($merged_config);
        if ( defined($gallery) ) {
            $galleries->{$id} = $gallery;
        }
    }

    # Set up parent/child relationships

    my @gallery_list = values(%$galleries);
    foreach my $gallery ( @gallery_list ) {
        my @kids = map { $_->id }
                    sort { $a->order <=> $b->order }
                    grep { defined($_->parent) && $_->parent eq $gallery->id }
                    @gallery_list;

        $gallery->galleries( \@kids ) if scalar(@kids);
    }

    $self->_galleries($galleries);

    return $self;
}

# Get a count of the total number of galleries

sub gallery_count {
    my $self = shift;
    my $galleries = $self->_galleries;
    return 0 if !defined($galleries) || ref($galleries) ne 'HASH';
    return scalar keys %$galleries;
}

# Retrieve one or more galleries by id.

sub galleries {
    my ( $self, @rest ) = @_;
    return undef if !scalar(@rest);

    # TODO: Should we do something special if passed an arrayref? For now just flatten.

    # Retrieve galleries by ID
    my @galleries = map { $self->_galleries->{$_} } grep { defined($_) } flat @rest;
    return \@galleries;
}

sub gallery {
    my ( $self, $gallery_id ) = @_;
    return $self->_galleries->{$gallery_id};
}

no Moose;

=head1 NAME

GalleryCat::Store::Image::File - Moose class for handling Galleries in memory.

=head1 DESCRIPTION

This is the most basic storage for galleries.  It uses the passed in configuration to
set them all up in memory.  It could be subclassed to read the configuration data from
somewhere else like an external file.  Larger installs should probably use a database store.

=head1 AUTHOR

Todd Holbrook

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
