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
    $c->forward( 'gallery', [ $c->stash->{gm}->main_gallery ] );
}

sub gallery : Chained('base') PathPart('') Args(1) {
    my ( $self, $c, $gallery_id ) = @_;

    my $gallery = $c->stash->{gallery} = $c->stash->{gm}->gallery($gallery_id);

    my $galleries   = $c->stash->{gm}->galleries( $gallery->galleries );    # TODO: Page this?
    # my $images      = $gallery->images;     # TODO: Page this?

    # Make sure thumbnails are available
    # $c->stash->{gallery}->build_thumbnails;


    # my @images = map {
    #     {
    #         url       => '' . $c->uri_for_static( $_->uri_path ),
    #         thumbnail => '' . $c->uri_for_static( $_->thumbnail_uri_path ),
    #         title     => $_->title,
    #         width     => $_->width,
    #         height    => $_->height,
    #     }
    # } @{$images};
    # 
    # $c->stash->{images}      = \@images;
    # $c->stash->{images_json} = JSON::XS->new->utf8->encode( \@images );

    $c->stash->{galleries}   = $galleries;
    $c->stash->{template}    =    $gallery->format eq 'galleries' ? 'galleries.tt'
                                : $gallery->format eq 'images'    ? 'images.tt'
                                : 'images.tt';
}

=head1 AUTHOR

Todd Holbrook

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
