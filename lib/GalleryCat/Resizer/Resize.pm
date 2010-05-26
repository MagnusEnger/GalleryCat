package GalleryCat::Resizer::Resize;

use Moose;

has width => (
    is      => 'rw',
    isa     => 'Int',
    default => 150,
);

has height => (
    is      => 'rw',
    isa     => 'Int',
    default => 150,
);

# Resize GalleryCat images using Image::Resize

use Image::Resize;

sub resize_file {
    my ( $self, $source, $dest, $width, $height ) = @_;

    $width  ||= $self->width;
    $height ||= $self->height;

    if ( -e $source ) {
        my $rs = Image::Resize->new($source->stringify);
        my $gd = $rs->resize( $width, $height );

        # TODO: Do we need to deal with non-JPEG files?
        if ( open(FH, ">$dest") ) {
            print FH $gd->jpeg();
            close(FH);
        }
        else {
            warn('Unable to open file to write thumbnail to: ' . $dest);
            return 0;
        }
    }


    return 1;
}

sub resize_data {
    my $self = shift;
    warn("Resizing image by image data is not supported by Resizer::Resize");
    return 0;
}

no Moose;

1;

=head1 NAME

GalleryCat::Resizer::Resize

=head1 DESCRIPTION

Resize images for thumbnails, etc.

=head1 AUTHOR

Todd Holbrook

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
