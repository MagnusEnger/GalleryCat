package GalleryCat::Store::Images::File;

use Moose;
use Carp;

use IO::Dir;
use Path::Class;
use File::Slurp qw();
use List::Flatten qw(flat);

use Image::Size;
use Image::ExifTool qw(ImageInfo);

extends 'GalleryCat::Store::Images';

has 'path' => (
    is      => 'rw',
    isa     => 'Path::Class::Dir',
    coerce  => 1,
);

has 'thumbnail_dir' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    default  => 'thumbnails',
);

has 'uri_base' => (
    is => 'rw',
    isa => 'Str'
);

has 'uri_part' => (
    is  => 'rw',
    isa => 'Str',
);

has 'read_exif' => (
    is => 'ro',
    required => 1,
    default => 1,
);

sub BUILD {
    my $self = shift;
    
    # TODO: Make path buildable from a base + id?

    $self->logger->trace( 'Checking for path: ', $self->path->stringify );
    if ( !-e $self->path ) {
        croak( 'Path to gallery does not exist: ' . $self->path->stringify );
    }
    
    # Find all images for this file store by reading
    # all the files in the path.
    my $dir = $self->path->open();
    if ( !defined($dir) ) {
        croak( 'Unable to open directory for reading: ' . $self->path->stringify );
    }

    $self->logger->trace('Reading path: ', $self->path);
    my @images;
    while ( my $filename = $dir->read ) {
        next unless $filename =~ / \. (jpe?g|png|gif) $/xsm;
        $self->logger->trace('Found image file: ', $filename);
        my $file = Path::Class::File->new( $self->path, $filename );
        # Read file information. Might want to move this into a Role so it could 
        # be applied to other stores.

        my $size = $self->get_image_size($file);
        my $info = $self->get_image_info($file);

        push @images, GalleryCat::Image->new({
            id          => $filename,
            file        => $file,
            width       => $size->[0],
            height      => $size->[1],
            title       => $info->{title},
            description => $info->{description},
            keywords    => $info->{keywords},
        });
    }

    # TODO: Check for thumbnails and build if necessary

    return $self;
}

# Turn this into a Role for Stores that have local access to the file.
sub get_image_size {
    my ( $self, $file ) = @_;
    my ( $width, $height ) = imgsize($file->stringify);
    
    $self->logger->trace("Read image size: $width x $height");
    return [ $width, $height ];
}

# Turn this into a Role for Stores that have local access to the file.
sub get_image_info {
    my ( $self, $file ) = @_;
    
    my $exif = ImageInfo( $file->stringify );
    if ( $exif ) {
        my $info = {
            title       => $exif->{Title},
            description => $exif->{Description},
            keywords    => $exif->{Keywords},
        };
    }

    return {};
}

sub images_by_id {
    my ( $self, @rest ) = @_;
}

sub images_by_index {
    my ( $self, $start, $end ) = @_;
    $end ||= $start;
}

sub images {
    my ($self) = @_;

    my $path = $self->path;


    # return \@images;
}

sub list_thumbnails {
    my ($self) = @_;

    my $thumbnail_path = $self->thumbnail_path;

    # Find existing thumbnails
    my @thumbnails;
    my $dir = $thumbnail_path->open();
    while ( my $file = $dir->read ) {
        next unless $file =~ / \. (jpe?g|png|gif) $/xsm;
        push @thumbnails, $file;
    }

    return \@thumbnails;
}

sub save_thumbnail {
    my ($self) = @_;

    my $images         = $self->images;
    my $path           = $self->path;
    my $thumbnail_path = $self->thumbnail_path;

    # Create thumbnail path if it doesn't exist
    if ( !-e $thumbnail_path ) {
        mkdir($thumbnail_path);
    }

    my %thumbnail_map = map { $_ => 1 } @{ $self->list_thumbnails };

    # Create any thumbnails that don't exist
    my $build_count = 0;
    my $max_x       = $self->thumbnail_max_width;
    my $max_y       = $self->thumbnail_max_height;
    chdir( $self->path );
    foreach my $image (@$images) {
        my $file = $image->file;
        warn("Checking image: $file\n");
        if ( !exists $thumbnail_map{$file} ) {
            warn("Creating thumbnail for: $file\n");

# warn( "Mogrify: gm mogrify -output-directory thumbnails -quality 95 -resize ${max_x}x${max_y} $file\n" );
# `gm mogrify -output-directory thumbnails -quality 95 -resize ${max_x}x${max_y} $file`;
            if ( $image->create_thumbnail() ) {
                $build_count++;
            }
        }
    }

    return $build_count;
}

sub image_file {
    my ( $self, $image ) = @_;
    return $self->path( $image->id );
}

sub image_data {
    my ( $self, $image ) = @_;
    my $file = $self->image_file( $image )->stringify;
    my $data = File::Slurp::read_file($file);
    return \$data;
}

# sub path {
#     my ( $self, @rest ) = @_;
#     return Path::Class::dir( $self->base_path, $self->gallery_path || $self->gallery->id, @rest );
# }
# 
# sub thumbnail_path {
#     my $self = shift;
#     return $self->path( $self->thumbnail_dir, @_ );
# }
# 
# sub thumbnail_uri_path {
#     my $self = shift;
#     return $self->uri_path( $self->thumbnail_dir, @_ );
# }
# 
# sub image_uri {
#     my ( $self, $image ) = @_;
#     return $self->_uri( $image->id );
# }
# 
# sub thumbnail_uri {
#     my ( $self, $image ) = @_;
#     return $self->_uri( $self->thumbnail_dir, $image->id );
# }
# 
# sub _uri {
#     my ( $self, @rest ) = @_;
# 
#     my @path_parts;
# 
#     push @path_parts, $self->uri_base
#       if defined( $self->uri_base );
# 
#     push @path_parts,
#       $self->gallery_uri_part || $self->gallery_path || $self->gallery->id;
# 
#     push @path_parts, @rest;
# 
#     return join '/', @path_parts;
# }

no Moose;

=head1 NAME

GalleryCat::Store::Image::File - Moose class for handling Galleries

=head1 DESCRIPTION


=head1 AUTHOR

Todd Holbrook

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
