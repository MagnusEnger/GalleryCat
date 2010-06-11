package GalleryCatWeb;

use strict;
use warnings;

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use parent qw/Catalyst/;
use Catalyst qw/-Debug
                ConfigLoader
                Static::Simple/;
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
