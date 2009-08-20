package GalleryCat::Model::GalleryCat;

use strict;
use warnings;
use parent 'Catalyst::Model';

use Carp;
use GalleryCat::Gallery;

use Config::General;

=head1 NAME

GalleryCat::Model::GalleryCat - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

Todd Holbrook

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

sub new {
    my $self = shift->next::method(@_);

    use Data::Dumper;
    warn(Dumper($self));

    $self->init();
    return $self;
}



sub init {
    my $self = shift;
    
    croak "->config->{gallery_conf} must be defined for this model"
        unless $self->{gallery_conf};
        
    my %config = Config::General->new($self->{gallery_conf})->getall;
    $self->{'.GalleryCat'}->{config} = \%config;

    ##
    ## TODO: Make this less dumb.. there's probably a better way to set up the config files
    ##       for easy use within Catalyst and externally.
    ##
    
    my %merge_config = %config;
    my $galleries = delete $merge_config{galleries};

    # Check that the base_path is rooted, otherwise it should be relative from $home?
    
    if ( $merge_config{base_path} !~ m{^/} ) {
        $merge_config{base_path} = $self->{home} . '/' . $merge_config{base_path};
    }

    $self->{gallery_list} = [];
    $self->{gallery_map}  = {};
    
    # Create gallery objects 

    while ( my ($id, $conf) = each %{$galleries->{gallery}} ) {
        my %final_conf = ( %merge_config, %$conf, id => $id );
        use Data::Dumper;
        warn(Dumper(\%final_conf));
        my $gallery = GalleryCat::Gallery->new( \%final_conf );
        push @{$self->{gallery_list}}, $gallery;
        $self->{gallery_map}->{$id} = $gallery;
    }
    
    return $self;
}

sub cat_config {
    return shift->{'.GalleryCat'}->{config};
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

sub galleries_conf {
    my $self = shift;

    return $self->config->{galleries}->{gallery};
}

sub gallery_list {
    my ( $self, $sort ) = @_;
    
    return $self->{gallery_list};
}

1;
