package GalleryCatWeb::Controller::Root;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use JSON::XS;

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

GalleryCatWeb::Controller::Root - Root Controller for GalleryCatWeb

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 index

=cut

sub base : Chained('/') PathPart('') CaptureArgs(0) {
    my ( $self, $c ) = @_;
    
    # Set a "mobile" flag if we detect a mobile device
    
    my $browser = $c->request->browser;
    if ( $browser->iphone || $browser->ipod ) {
        $c->stash->{mobile} = 1;
    }
}


sub index : Path : Args(0) {
    my ( $self, $c ) = @_;
    $c->redirect( $c->uri_for( $c->controller('Gallery')->action_for('index') ) );
}

sub default : Path {
    my ( $self, $c ) = @_;
    $c->response->body('Page not found');
    $c->response->status(404);
}



=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {
}

=head1 AUTHOR

Todd Holbrook

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
