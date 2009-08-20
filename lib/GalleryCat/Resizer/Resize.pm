package GalleryCat::Resizer::Resize;

use strict;

# Resize GalleryCat images using Image::Resize

use Image::Resize;

sub new {
    return bless {}, shift;
}

sub resize {
    my ( $self, $source, $dest, $width, $height ) = @_;
    
    my $rs = Image::Resize->new($source);
    my $gd = $rs->resize( $width, $height );
    open(FH, ">$dest");
    print FH $gd->jpeg();
    close(FH);
}

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
