package GalleryCat::Image;

use Path::Class;
use Image::Info qw(image_info);
use Image::ExifTool qw(ImageInfo);
use GalleryCat::Gallery;

use Moose;
use Moose::Util::TypeConstraints;

class_type 'GalleryCat::Gallery';
class_type 'Path::Class';

has id => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has gallery => (
    is       => 'ro',
    isa      => 'GalleryCat::Gallery',
    required => 1,
    weak_ref => 1,
);

has title => (
    is => 'ro',
    isa => 'Str',
    builder => 'read_info',
);

has description => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    default => '',
);

has keywords => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    default => '',
);

has _path => (
    is  => 'rw',
    isa => 'Path::Class::Dir',
);

has thumbnail => (
    is  => 'ro',
    isa => 'Path::Class::Dir',
);


has uri => (
    is => 'rw',
    isa => 'Str',
    builder => '_build_uri',
    lazy => 1,
);

has thumbnail_uri => (
    is => 'rw',
    isa => 'Str',
    builder => '_build_thumbnail_uri',
    lazy => 1,
);


# Image attributes like sizes, things from EXIF data, etc.

has width => (
    is  => 'rw',
    isa => 'Int',
    lazy => 1,
    builder => 'read_info',
);

has height => (
    is  => 'rw',
    isa => 'Int',
    lazy => 1,
    builder => 'read_info',
);

has lazy => (
    is => 'ro',
    isa => 'Bool',
    default => 0,
);

# Flag to say we've scanned this image for info so
# we can skip it

has _info_read => (
    is => 'rw',
    isa => 'Bool',
    default => 0
);

sub BUILD {
    my $self = shift;

    if ( !$self->lazy ) {
        $self->read_info();
    }

    return $self;
}

sub read_info {
    my ( $self ) = @_;

    return if $self->_info_read();
    
    my ( $info, $exif );
    
    # Try to read the image info from a file or image contents

    if ( my $image_file = $self->gallery->store->image_file($self) ) {
        $info = image_info( $image_file->stringify );
        if ( $self->gallery->store->read_exif ) {
            $exif = ImageInfo( $image_file->stringify );
        }
    }
    elsif ( my $image_data = $self->gallery->store->image_data($self) ) {
        $info = image_info( $image_data );
        if ( $self->gallery->store->read_exif ) {
            $exif = ImageInfo( \$image_data );
        }
    }
    else {
        carp("Unable to read image data: " . $self->id);
        return;
    }
    
    # Set up the image info
    
    $self->width( $info->{width} );
    $self->height( $info->{height} );
    $self->_info_read(1);
    
    if ( $exif ) {
        # use Data::Dumper;
        # warn(Dumper($exif));
    }
    
    # 
}

sub _build_uri {
    my $self = shift;
    return $self->gallery->image_uri( $self );
}

sub _build_thumbnail_uri {
    my $self = shift;
    return $self->gallery->thumbnail_uri( $self );
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


sub image_uri {
    my ( $self ) = @_;
    return $self->gallery->image_uri( $self );
}


sub thumbnail_uri_path {
    my $self = shift;
    $self->gallery->thumbnail_uri_path( $self->file );
}

sub create_thumbnail {
    my $self = shift;
    
    warn('RESIZE');
    return;
    
    my $resizer = $self->gallery->resizer;
    my $image = $resizer->resize(
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
