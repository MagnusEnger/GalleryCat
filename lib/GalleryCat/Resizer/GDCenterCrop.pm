package GalleryCat::Resizer::GDCenterCrop;

use Moose;

has width => (
    is      => 'rw',
    isa     => 'Int',
    default => 100,
);

has height => (
    is      => 'rw',
    isa     => 'Int',
    default => 100,
);

# Resize GalleryCat images using GD.  Crops to a square thumbnail.

use GD::Image;

sub resize_file {
    my ( $self, $src, $dest, $width, $height ) = @_;

    $width  ||= $self->width;
    $height ||= $self->height;

    if ( -e $src ) {
        my $src_image  = GD::Image->new( $src->stringify );
        my $dest_image = GD::Image->new( $width, $height, 1 );
        
        my $src_width  = $src_image->width;
        my $src_height = $src_image->height;
        my $shortest = $src_width < $src_height ? $src_width : $src_height;

        $dest_image->copyResampled( $src_image, 
            0,0,                                                    # dest x,y
            ($src_width-$shortest)/2, ($src_height-$shortest)/2,    # src  x,y
            $width, $height,                                        # dest w,h
            $shortest, $shortest                                    # src  w,h
        );

        # TODO: Do we need to deal with non-JPEG files?
        if ( open(FH, ">$dest") ) {
            print FH $dest_image->jpeg();
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

Resize images for thumbnails using GD.  Can also crop to the center of an image if you want square thumbnails.

=head1 AUTHOR

Todd Holbrook

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
