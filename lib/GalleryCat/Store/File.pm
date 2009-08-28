package GalleryCat::Store::File;

use Moose;
use Carp;

use IO::Dir;
use Path::Class;

use GalleryCat::Image;

has 'thumbnail_dir' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    default  => 'thumbnails',
);


sub BUILD {
    my $self = shift;

    if ( !-e $self->path ) {
        die( 'Path to gallery does not exist: ' . $self->path );
    }

    return $self;
}

sub images {
    my ($self) = @_;

    my $path = $self->path;

    my $dir = $path->open();
    if ( !defined($dir) ) {
        croak( 'Unable to open directory for reading: ' . $path );
    }

    my @images;
    while ( my $file = $dir->read ) {
        next unless $file =~ / \. (jpe?g|png|gif) $/xsm;
        push @images, GalleryCat::Image->new( file => $file, gallery => $self );
    }

    return \@images;
}

sub find_thumbnails {
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

sub build_thumbnails {
    my ($self) = @_;

    my $images         = $self->images;
    my $path           = $self->path;
    my $thumbnail_path = $self->thumbnail_path;

    # Create thumbnail path if it doesn't exist
    if ( !-e $thumbnail_path ) {
        mkdir($thumbnail_path);
    }

    my %thumbnail_map = map { $_-> => 1 } @{ $self->list_thumbnails };

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

sub path {
    my ( $self, @rest ) = @_;
    return Path::Class::dir( $self->base_path, $self->gallery_path || $self->id,
        @rest );
}

sub thumbnail_path {
    my $self = shift;
    return $self->path( $self->thumbnail_dir, @_ );
}

sub thumbnail_uri_path {
    my $self = shift;
    return $self->uri_path( $self->thumbnail_dir, @_ );
}

sub uri_path {
    my ( $self, @rest ) = @_;

    my $uri_base = $self->uri_base;
    my @path_parts;

    push @path_parts, $self->uri_base
      if defined( $self->uri_base );

    push @path_parts,
      $self->gallery_uri_path || $self->gallery_path || $self->id;

    push @path_parts, @rest;

    return join '/', @path_parts;
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
