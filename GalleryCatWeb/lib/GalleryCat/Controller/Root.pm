package GalleryCat::Controller::Root;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use JSON::XS qw();

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

GalleryCat::Controller::Root - Root Controller for GalleryCat

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{galleries} = $c->model('GalleryCat')->gallery_list;

    $c->stash->{template} = 'list.tt';
}

sub gallery :Path('gallery') :Args(1) {
    my ( $self, $c, $gallery_id ) = @_;
    
    $c->stash->{gallery_cat} = $c->model('GalleryCat');
    my $gallery = $c->stash->{gallery} = $c->stash->{gallery_cat}->gallery($gallery_id);
    
    # Make sure thumbnails are available
    $c->stash->{gallery}->build_thumbnails;
    
    my $images = $c->stash->{gallery}->images;
    
    my @images = map { 
        [ 
            '' . $c->uri_for_static($_->uri_path),
            '' . $c->uri_for_static($_->thumbnail_uri_path),
            $_->width,
            $_->height,
        ] } @{$images};
    
    $c->stash->{images} = \@images;
    $c->stash->{images_json} = JSON::XS->new->utf8->encode(\@images);
    $c->stash->{template} = 'gallery.tt';
}

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Todd Holbrook

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
