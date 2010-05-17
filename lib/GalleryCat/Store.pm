package GalleryCat::Store;

use Moose;
use Carp;

has 'logger' => (
    is          => 'ro',
    isa         => 'Object',
    default     => sub {
        use GalleryCat::Logger::Default;
        return new GalleryCat::Logger::Default();
    },
);


no Moose;

=head1 NAME

GalleryCat::Store - Base class for stores

=head1 DESCRIPTION


=head1 AUTHOR

Todd Holbrook

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
