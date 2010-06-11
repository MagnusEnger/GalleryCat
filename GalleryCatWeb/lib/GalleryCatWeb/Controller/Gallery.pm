package GalleryCatWeb::Controller::Gallery;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use String::Util qw(hascontent);

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

    my $gallery = $c->stash->{gallery} = $c->stash->{gm}->gallery($gallery_id);
    
    # If the gallery has a theme set, add it to the path
    
    my $themepath = $gallery->themepath;
    if ( hascontent($themepath) ) {
        push @{ $c->stash->{additional_template_paths} }, ($c->config->{root} . '/themes/' . $themepath);
        push @{ $c->stash->{static_theme_paths} }, $themepath;
    }
}

=head2 ajaxgallery

Loads a gallery and its images.  These are passed to the template for rendering,
probably by a theme that does no JS, or a partial one rather than a full AJAX
gallery.

=cut


sub gallery : Chained('load_gallery') PathPart('') Args(0) {
    my ( $self, $c ) = @_;

    my $gallery     = $c->stash->{gallery};
    my $galleries   = $c->stash->{gm}->galleries( $gallery->galleries );    # TODO: Page this?

    my $keyword     = $c->req->params->{keyword};
    my $start       = $c->req->params->{start};
    my $end         = $c->req->params->{end};

    my $images = $self->_get_images( $c, $keyword, $start, $end );

    my @images = map { $self->_image_to_hash( $c, $_ ) } @$images;

    $c->stash->{keyword}     = $c->req->params->{keyword};  # TODO: untaint this
    $c->stash->{start}       = int($c->req->params->{start});
    $c->stash->{end}         = int($c->req->params->{end});

    $c->stash->{images}      = \@images;
    $c->stash->{images_json} = JSON::XS->new->utf8->encode( \@images );

    $c->stash->{galleries}   = $galleries;
    $c->stash->{template}    =    $gallery->format eq 'galleries' ? 'galleries.tt'
                                : $gallery->format eq 'images'    ? 'images.tt'
                                : 'images.tt';
}


=head2 ajaxgallery

Loads the framework of a gallery.  This is meant for AJAX themes that are going to
request the images separately and don't need to load them yet.

=cut

sub ajaxgallery : Chained('load_gallery') PathPart('ajax') Args(0) {
    my ( $self, $c ) = @_;

    my $gallery = $c->stash->{gallery};
    
    $c->stash->{template}    =    $gallery->format eq 'galleries' ? 'ajaxgalleries.tt'
                                : $gallery->format eq 'images'    ? 'ajaximages.tt'
                                : 'ajaximages.tt';
}

sub gallery_json : Chained('load_gallery') PathPart('gallery_json') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{json}->{gallery} = $self->_gallery_to_hash( $c, $self->stash->{gallery} );
    $c->stash->{current_view} = 'JSON';
}

sub images_json : Chained('load_gallery') PathPart('images_json') Args(0) {
    my ( $self, $c ) = @_;

    my $keyword     = $c->req->params->{keyword};
    my $start       = $c->req->params->{start};
    my $end         = $c->req->params->{end};

    my $images = $self->_get_images( $c, $keyword, $start, $end );
    my @images = map { $self->_image_to_hash( $c, $_ ) } @$images;

    $c->stash->{json}->{images} = \@images;
    $c->stash->{current_view} = 'JSON';
}

sub galleries_json : Chained('load_gallery') PathPart('galleries_json') Args(0) {
    my ( $self, $c ) = @_;
    
    my $galleries   = $c->stash->{gm}->galleries( $c->stash->{gallery}->galleries );    # TODO: Page this?
    my @galleries   = map { $self->_gallery_to_hash( $c, $_ ) } @$galleries;

    $c->stash->{json}->{galleries} = \@galleries;
    $c->stash->{current_view} = 'JSON';
}

sub gallery_keywords_json : Chained('load_gallery') PathPart('keywords_json') Args(0) {
    my ( $self, $c ) = @_;

    my $keyword = $c->req->params->{term};
    $c->stash->{json} = $c->{stash}->{gallery}->useful_keywords($keyword);
    $c->stash->{current_view} = 'JSON';
}

=head2 imagedata

Sends an image binary.  This is useful for stores that cannot otherwise return a URL which
may be useful for storing images in a database, for instance.

=cut

sub imagedata : Chained('load_gallery') PathPart('image/data') Args(1) {
    my ( $self, $c, $image_id ) = @_;

    # TODO: Return image data directly if a URI is not available.
}

sub _get_images {
    my ( $self, $c, $keyword, $start, $end ) = @_;

    my $gallery = $c->stash->{gallery};
    
    my $images =   hascontent($keyword)   ? $gallery->images_by_keyword($keyword, $start, $end)
                 : hascontent($start)     ? $gallery->images_by_index($start, $end)
                 : $gallery->images;

    return $images;
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

sub _gallery_to_hash {
    my ( $self, $c, $gallery ) = @_;
    return {
        id          => $gallery->id,
        title       => $gallery->title,
        description => $gallery->description,
        image_count => $gallery->image_count,
        # keywords    => $gallery->keywords,
        # width       => $gallery->width,
        # height      => $gallery->height,
    };
}


=head1 AUTHOR

Todd Holbrook

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
