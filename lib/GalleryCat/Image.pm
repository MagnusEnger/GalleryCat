package GalleryCat::Image;

use Path::Class;
use Image::Info qw(image_info);
use GalleryCat::Gallery;

use Moose;
use Moose::Util::TypeConstraints;

class_type 'GalleryCat::Gallery';
class_type 'Path::Class';

has file => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has gallery => (
    is       => 'ro',
    isa      => 'GalleryCat::Gallery',
    required => 1,
);

has _path => (
    is  => 'rw',
    isa => 'Path::Class::Dir',
);

has thumbnail => (
    is  => 'ro',
    isa => 'Path::Class::Dir',
);

has width => (
    is  => 'rw',
    isa => 'Int'
);

has height => (
    is  => 'rw',
    isa => 'Int'
);

sub BUILD {
    my $self = shift;

    # Verify that the file exists and read its metadata

    if ( !-e $self->path ) {
        warn( 'Image does not exist: ' . $self->path );
        return undef;  # die?
    }

    # Read image metadata
    my $info = image_info( $self->path->stringify );

    $self->width( $info->{width} );
    $self->height( $info->{height} );

    return $self;
}

sub path {
    my $self = shift;
    if ( !defined( $self->_path ) ) {
        $self->_path( $self->gallery->path( $self->file ) );
    }
    return $self->_path;
}

sub thumbnail_path {
    my $self = shift;
    return $self->gallery->thumbnail_path( $self->file );
}

sub uri_path {
    my $self = shift;
    $self->gallery->uri_path( $self->file );
}

sub thumbnail_uri_path {
    my $self = shift;
    $self->gallery->thumbnail_uri_path( $self->file );
}

sub create_thumbnail {
    my $self = shift;
    
    my $resizer = $self->gallery->resizer;
    $resizer->resize(
        $self->path->stringify,
        $self->thumbnail_path->stringify,
        $self->gallery->thumbnail_max_width,
        $self->gallery->thumbnail_max_height,
    );
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
