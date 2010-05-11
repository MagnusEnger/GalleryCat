package GalleryCatWeb::Model::GalleryCat;

use strict;
use warnings;
use parent 'Catalyst::Model';

use Carp;
use GalleryCat::Gallery;

use Config::General;

=head1 NAME

GalleryCatWeb::Model::GalleryCat - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

Todd Holbrook

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

sub new {
    my ( $class, $c, $config ) = @_;
    my $self = $class->next::method($c, $config);

    $self->init($c);
    return $self;
}



sub init {
    my ( $self, $c ) = @_;

    my $config = $self->{gallery_config} || {};

    # First get the path to the general gallery configuration, if it exists.
    # It can be skipped and just defined in the Catalyst Model config, but
    # then none of the external scripts would work without loading the web app.

    my $conf_path = $c->path_to($self->{gallery_config_file});
    if ( $conf_path && -e $conf_path ) {
        $c->log->debug( "Loading gallery config: $conf_path" );
        my %config_from_file = Config::General->new($conf_path->stringify)->getall;
        $config = Catalyst::Utils::merge_hashes( \%config_from_file, $config )
    }

    # Go through each individual gallery and merge its config with the global
    # gallery config.
    
    my %merge_config = %$config;
    my $galleries = delete $merge_config{galleries};

    $self->{gallery_list} = [];
    $self->{gallery_map}  = {};
    
    # Create gallery objects 

    while ( my ($id, $conf) = each %{$galleries->{gallery}} ) {
        $conf->{id} = $id;
        my $final_conf = Catalyst::Utils::merge_hashes( \%merge_config, $conf );
        my $gallery = GalleryCat::Gallery->new( $final_conf );

        # If we're using the local File store, check that the base_path is rooted, 
        # otherwise it's relative from Catalyst home.

        if ( $gallery->store_module eq 'File' ) {
            my $base_path = $gallery->store->base_path;
            if ( $base_path !~ m{^/} ) {
                $gallery->store->base_path( $c->path_to( $base_path )->stringify );
            }
        }


        push @{$self->{gallery_list}}, $gallery;
        $self->{gallery_map}->{$id} = $gallery;
    }
    
    return $self;
}

sub gallery {
    my $self = shift;
    my $id = shift;
    
    return $self->{gallery_map}->{$id};
}

sub gallery_map {
    my $self = shift;
    
    return $self->{gallery_map};
}

sub gallery_list {
    my ( $self, $sort ) = @_;
    
    return $self->{gallery_list};
}

1;
