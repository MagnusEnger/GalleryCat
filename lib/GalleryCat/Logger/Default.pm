package GalleryCat::Logger::Default;

use Moose;
use Carp;

sub warn {
    my $self = shift;
    print STDERR 'WARN: ' , @_ , "\n";
}

sub trace {
    my $self = shift;
    print STDERR 'TRACE: ' , @_ , "\n";
}

sub debug {
    my $self = shift;
    print STDERR 'DEBUG: ' , @_ , "\n";
}

sub info {
    my $self = shift;
    print STDERR 'INFO: ' , @_ , "\n";
}

sub error {
    my $self = shift;
    print STDERR 'ERROR: ' , @_ , "\n";
}

sub fatal {
    my $self = shift;
    print STDERR 'FATAL: ' , @_ , "\n";
}

no Moose;

=head1 NAME

GalleryCat::Logger::Default - Basic logger that just dumps messages through "warn".

=head1 DESCRIPTION

For production, a Log4Perl logger should be set up instead.

=head1 AUTHOR

Todd Holbrook

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
