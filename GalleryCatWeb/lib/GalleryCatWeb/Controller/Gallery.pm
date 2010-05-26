package GalleryCatWeb::Controller::Gallery;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

GalleryCatWeb::Controller::Gallery - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub base : Chained('/') PathPart('gallery') CaptureArgs(0) {
    my ( $self, $c ) = @_;
    $c->stash->{gm} = $c->model('GalleryCat');
}

=head2 index

=cut

sub index : Chained('base') PathPart('') Args(0) {
    my ( $self, $c ) = @_;
    warn( $c->stash->{gm}->main_gallery );
    $c->go( 'gallery', [ $c->stash->{gm}->main_gallery ], [] );
}

sub load_gallery : Chained('base') PathPart('') CaptureArgs(1) {
    my ( $self, $c, $gallery_id ) = @_;

    $c->stash->{gallery} = $c->stash->{gm}->gallery($gallery_id);
}

sub gallery : Chained('load_gallery') PathPart('') Args(0) {
    my ( $self, $c ) = @_;

    my $gallery     = $c->stash->{gallery};
    my $galleries   = $c->stash->{gm}->galleries( $gallery->galleries );    # TODO: Page this?
    my $images      = $gallery->images;     # TODO: Page this?


    my @images = map { $self->_image_to_hash( $c, $_ ) } @$images;
    
    $c->stash->{images}      = \@images;
    $c->stash->{images_json} = JSON::XS->new->utf8->encode( \@images );

    $c->stash->{galleries}   = $galleries;
    $c->stash->{template}    =    $gallery->format eq 'galleries' ? 'galleries.tt'
                                : $gallery->format eq 'images'    ? 'images.tt'
                                : 'images.tt';
}

sub images_json : Chained('load_gallery') PathPart('images_json') Args(2) {
    my ( $self, $c, $start, $end ) = @_;
    
    my $gallery = $c->stash->{gallery};
    
    my @images = map { $self->_image_to_hash( $c, $_ ) } @{ $gallery->images_by_index( $start, $end ) };
    
    $c->stash->{json}->{images} = \@images;
    $c->stash->{current_view} = 'JSON';
}

sub image {
    my ( $self, $c, $gallery_id, $image_id ) = @_;
    
    # TODO: Return image data directly if a URI is not available.
}

sub _image_to_hash {
    my ( $self, $c, $image ) = @_;
    return {
        id          => $image->id,
        url         => '' . $c->uri_for_image( $image ),
        thumbnail   => '' . $c->uri_for_image( $image->thumbnail ),
        title       => $image->title,
        description => $image->description,
        keywords    => $image->keywords,
        width       => $image->width,
        height      => $image->height,
    };
}

=head1 AUTHOR

Todd Holbrook

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
