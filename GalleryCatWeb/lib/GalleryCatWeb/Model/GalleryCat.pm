package GalleryCatWeb::Model::GalleryCat;

use strict;
use warnings;

use Moose;

extends 'Catalyst::Model::Adaptor';

before 'prepare_arguments' => sub {
    my ($self, $app) = @_;

    # TODO: Merge or perhaps skip if args is already set?
    $self->{args} = $self->{gallery_config};

    $self->{args}->{uri_builder} = sub {
        $self->uri_for_static( shift );
    }
};


# before 'mangle_arguments' => sub {
#     my ( $self, $args ) = @_;
# };

__PACKAGE__->config(
    class => 'GalleryCat::GalleryManager',
    # args => ...
);

no Moose;

=head1 NAME

GalleryCatWeb::Model::GalleryCat - Catalyst Model



1;
