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
    $c->stash->{gm} = $c->model('GalleryCatManager');
}

=head2 index

=cut

sub index : Chained('base') PathPart('') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{gallery}   = $c->stash->{gm}->gallery( $c->stash->{gm}->main_gallery );

    # TODO: Page this for large main galleries?
    $c->stash->{galleries} = $c->stash->{gm}->galleries( $c->stash->{gallery}->galleries );

    $c->stash->{template} = 'list.tt';
}

sub gallery : Chained('base') PathPart('') Args(1)  {
    my ( $self, $c, $gallery_id ) = @_;

    my $gallery = $c->stash->{gallery} = $c->stash->{gm}->gallery($gallery_id);

    # Make sure thumbnails are available
    $c->stash->{gallery}->build_thumbnails;

    my $images = $c->stash->{gallery}->images;

    my @images = map {
        {
            url       => '' . $c->uri_for_static( $_->uri_path ),
            thumbnail => '' . $c->uri_for_static( $_->thumbnail_uri_path ),
            title     => $_->title,
            width     => $_->width,
            height    => $_->height,
        }
    } @{$images};

    $c->stash->{images}      = \@images;
    $c->stash->{images_json} = JSON::XS->new->utf8->encode( \@images );
    $c->stash->{template}    = 'gallery.tt';
}

=head1 AUTHOR

Todd Holbrook

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
