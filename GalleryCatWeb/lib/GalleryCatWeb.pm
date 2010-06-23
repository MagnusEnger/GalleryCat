package GalleryCatWeb;

use Moose;
use namespace::autoclean;

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/-Debug
                ConfigLoader
                Static::Simple/;
use CatalystX::RoleApplicator;

extends 'Catalyst';

our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in gallerycatweb.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config( name => 'GalleryCatWeb' );

after 'setup_finalize' => sub {
    my $app = shift;
    my $themes = $app->config->{load_themes};
    warn($themes);
    $themes = ref($themes) eq 'ARRAY' ? $themes : [ $themes ];
    foreach my $theme ( @$themes ) {
        Catalyst::Utils::ensure_class_loaded( 'GalleryCatWeb::Themes::' . $theme );
    }
};

__PACKAGE__->apply_request_class_roles(qw/
    Catalyst::TraitFor::Request::BrowserDetect
/);

# Start the application
__PACKAGE__->setup();


sub uri_for_static {
    my ( $c, $path, $params ) = @_;
    $path =~ s{^/}{};
    return defined($params) ? $c->uri_for( '/static/' . $path, $params ) : $c->uri_for( '/static/' . $path );
}

sub uris_for_themed_static {
    my ( $c, $path, $params ) = @_;
    $path =~ s{^/}{};
    
    my @paths;
    foreach my $themepath ( @{ $c->stash->{static_theme_paths} || [] } ) {
        my $checkpath = $c->path_to( 'root', 'static', 'themes', $themepath, $path );
        next if !-e $checkpath;
        unshift( @paths, $c->uri_for_static( "themes/$themepath/$path", $params ) );
    }
    push( @paths, $c->uri_for_static( $path, $params ) );
    
    return \@paths;
}

sub redirect {
    my ( $c, $uri ) = @_;

    $c->res->redirect( $uri );
    $c->detach();
}

sub uri_for_image {
    my ( $c, $image ) = @_;

    if ( $image->uri ) {
        return $image->uri;
    }
    elsif ( my $filepath = $image->file ) {
        my $apppath  = $c->path_to('root/static');
        my $unique   = $filepath->relative($apppath);
        return $c->uri_for_static( $unique );
    }
    elsif ( $image->data ) {
        return $c->uri_for( $c->controller('Gallery')->action_for('image'), [ $image->gallery_id, $image->id ] );
    }
    else {
        return 'ERROR';
    }
}

sub theme_call {
    my ( $c, $method, @rest ) = @_;
    
    if ( my $theme = $c->stash->{gallery}->theme ) {
        my $module = 'GalleryCatWeb::Themes::' . $theme;
        if ( $module->can($method) ) {
            $module->$method( $c, @rest );
        }
    }
    
}

=head1 NAME

GalleryCatWeb - Catalyst based application

=head1 SYNOPSIS

    script/gallerycatweb_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<GalleryCatWeb::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Todd Holbrook

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
