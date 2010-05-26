package GalleryCat::Store::Images::File;

use Moose;
use Carp;

use IO::Dir;
use Path::Class;
use File::Slurp qw();
use List::Flatten qw(flat);
use List::Util qw(max);
use String::Util qw(hascontent trim);

use Image::Size;
use Image::ExifTool qw(ImageInfo);

extends 'GalleryCat::Store::Images';

has 'path' => (
    is      => 'rw',
    isa     => 'Path::Class::Dir',
    coerce  => 1,
);

has '_image_cache' => (
    is      => 'rw',
    isa     => 'HashRef',
);

has '_image_order' => (
    is      => 'rw',
    isa     => 'ArrayRef',
);

has '_keywords' => (
    is      => 'rw',
    isa     => 'HashRef',
);

has 'thumbnail_dir' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    default  => 'thumbnails',
);

has 'read_exif' => (
    is => 'ro',
    required => 1,
    default => 1,
);

has 'resizer_module' => (
    is      => 'ro',
    isa     => 'Str',
    default => 'Resize',
);

sub BUILD {
    my $self = shift;

    # TODO: Make path buildable from a base + id?

    my $path = $self->path;

    $self->logger->trace( 'Checking for path: ', $path->stringify );
    if ( !-e $path ) {
        croak( 'Path to gallery does not exist: ' . $path->stringify );
    }

    $self->logger->trace('Reading path: ', $path);
    my ( %images, @ordered );

    # Set up thumbnail dir and local resizer. This could be a Role?

    my $thumbnails_dir = $path->subdir( $self->thumbnail_dir );
    $thumbnails_dir->mkpath();
    my $resizer_module = 'GalleryCat::Resizer::' . $self->resizer_module;
    eval "require $resizer_module;";
    if ( $@ ) {
        croak( "Unable to require resizer module: " . $@ );
    }
    my $resizer = $resizer_module->new( width => $self->thumbnail_width, height => $self->thumbnail_height );

    my %keywords;
    while ( my $file = $path->next ) {
        next if !-f $file;
        my $filename = $file->basename;
        next unless $filename =~ / \. (jpe?g|png|gif) $/xsm;
        $self->logger->trace('Found image file: ', $filename);

        # Read file information. Might want to move this into a Role so it could
        # be applied to other stores.

        my $size = $self->get_image_size($file);
        my $info = $self->get_image_info($file);

        my $new_file = {
            id          => $filename,
            file        => $file,
            width       => $size->[0],
            height      => $size->[1],
            title       => $info->{title} || $filename,
            description => $info->{description},
            keywords    => $info->{keywords},
        };

        $images{$filename} = GalleryCat::Image->new($new_file);
        push @ordered, $images{$filename};  # Just order by filename for Memory images

        # Update keyword index
        if ( hascontent($new_file->{keywords}) ) {
            foreach my $keyword ( split /\s*,\s*/, $new_file->{keywords} ) {
                $keyword = $self->clean_keyword($keyword);
                $keywords{$keyword} = [] if !exists $keywords{$keyword};
                push @{$keywords{$keyword}}, $images{$filename};
            }
        }

        # Build a thumbnail and add it to the image.
        my $thumbnail_file = $thumbnails_dir->file($filename);
        if ( !-e $thumbnail_file ) {
            $self->logger->trace( 'Thumbnail needed: ', $thumbnail_file );
            if ( $resizer->resize_file( $file, $thumbnail_file ) ) {
                # Success
            }
        }
        if ( -e $thumbnail_file ) {
            my $thumbnail_size = $self->get_image_size($thumbnail_file);
            my $thumbnail = GalleryCat::Image->new({
                id      => 'thumbnail-' . $filename,
                file    => $thumbnail_file,
                width   => $thumbnail_size->[0],
                height  => $thumbnail_size->[1],
            });
            $images{$filename}->thumbnail($thumbnail);
        }
    }

    # TODO: Check for thumbnails and build if necessary

    $self->_keywords(\%keywords);
    $self->_image_cache(\%images);
    $self->_image_order(\@ordered);

    return $self;
}

# Turn this into a Role for Stores that have local access to the file.
sub get_image_size {
    my ( $self, $file ) = @_;
    my ( $width, $height ) = imgsize($file->stringify);

    $self->logger->trace("Read image size: $width x $height");
    return [ $width, $height ];
}

# Turn this into a Role for Stores that have local access to the file.
sub get_image_info {
    my ( $self, $file ) = @_;

    my $exif = ImageInfo( $file->stringify );
    if ( $exif ) {
        return {
            title       => $exif->{Title},
            description => $exif->{Description},
            keywords    => $exif->{Keywords},
        };
    }

    return {};
}


sub images_by_id {
    my ( $self, @rest ) = @_;
    my @images = map { $self->_image_cache->{$_} } flat @rest;
    return \@images;
}

sub images_by_index {
    my ( $self, $start, $end ) = @_;

    $start = int($start);
    $end   = defined($end) ? int($end) : undef;

    return [ !defined($end) ? @{$self->_image_order}[ $start ] : @{$self->_image_order}[ $start .. $end ] ];
}

sub images_by_keyword {
    my ( $self, $keyword, $start, $end ) = @_;

    $keyword    = $self->clean_keyword($keyword);
    $start      = int($start) if defined($start);
    $end        = int($end)   if defined($end);

    my $images = $self->_keywords->{$keyword} || [];

    if ( defined($start) ) {
        if ( defined($end) ) {
            return @{$images}[ $start .. $end ];
        }
        return @{$images}[$start]
    }
    return $images;
}

sub clean_keyword {
    my ( $self, $keyword ) = @_;
    $keyword = trim(lc($keyword));
    return $keyword;
}

sub image_count {
    my ( $self ) = @_;
    return scalar keys %{ $self->_image_cache };
}

sub images {
    my ($self) = @_;
    return $self->_image_order;
}

sub max_image_width {
    return max map { $_->width } @{shift->_image_order};
}

sub max_image_height {
    return max map { $_->height } @{shift->_image_order};
}



no Moose;

=head1 NAME

GalleryCat::Store::Image::File - Moose class for handling Galleries

=head1 DESCRIPTION


=head1 AUTHOR

Todd Holbrook

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
