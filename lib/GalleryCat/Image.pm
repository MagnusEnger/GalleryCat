package GalleryCat::Image;

# use Image::Info qw(image_info);

use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Types::URI qw(Uri);
use MooseX::Types::Path::Class qw(File);


has id => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

has uri => (
    is          => 'rw',
    isa         => Uri,
    required    => 0,
    coerce      => 1,
);

has path => (
    is          => 'rw',
    isa         => File,
    coerce      => 1,
    required    => 0,
);

has thumbnail => (
    is          => 'rw',
    isa         => 'GalleryCat::Image',
    required    => 0,
);

has image_data => (
    is          => 'rw',
    isa         => 'Maybe',
);

has title => (
    is          => 'rw',
    isa         => 'Maybe[Str]',
    required    => 0,
);

has description => (
    is          => 'rw',
    isa         => 'Maybe[Str]',
    required    => 0,
);

has keywords => (
    is          => 'rw',
    isa         => 'Maybe[Str]',
    required    => 0,
);


# Image attributes like sizes, things from EXIF data, etc.

has width => (
    is  => 'rw',
    isa => 'Int',
);

has height => (
    is  => 'rw',
    isa => 'Int',
);


# sub read_info {
#     my ( $self ) = @_;
# 
#     return;
#     return if $self->_info_read();
#     $self->_info_read(1);
#     
#     my ( $info, $exif );
#     
#     # Try to read the image info from a file or image contents
# 
#     if ( my $image_file = $self->gallery->store->image_file($self) ) {
#         $info = image_info( $image_file->stringify );
#         if ( $self->gallery->store->read_exif ) {
#             $exif = ImageInfo( $image_file->stringify );
#         }
#     }
#     elsif ( my $image_data = $self->gallery->store->image_data($self) ) {
#         $info = image_info( $image_data );
#         if ( $self->gallery->store->read_exif ) {
#             $exif = ImageInfo( \$image_data );
#         }
#     }
#     else {
#         carp("Unable to read image data: " . $self->id);
#         return;
#     }
#     
#     # Set up the image info
#     
#     $self->width( $info->{width} );
#     $self->height( $info->{height} );
#     
#     if ( $exif ) {
#        $self->title(        $exif->{Title}       || '' ) if !$self->title;
#        $self->description(  $exif->{Description} || '' ) if !$self->description;
#        $self->keywords(     $exif->{Keywords}    || '' ) if !$self->keywords;
#     }
#     
# }



# sub create_thumbnail {
#     my $self = shift;
#     
#     warn('RESIZE');
#     return;
#     
#     my $resizer = $self->gallery->resizer;
#     my $image = $resizer->resize(
#         $self->path->stringify,
#         $self->thumbnail_path->stringify,
#         $self->gallery->thumbnail_max_width,
#         $self->gallery->thumbnail_max_height,
#     );
# }


no Moose;

1;

=head1 NAME

GalleryCat::Model::GalleryCat::Image - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

Todd Holbrook

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
