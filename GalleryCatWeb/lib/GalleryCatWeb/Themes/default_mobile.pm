package GalleryCatWeb::Themes::default_mobile;

use Moose;
use namespace::autoclean;

sub gallery_before_display {
    my ( $c ) = @_;
    
    warn('!! THEME CALLED !!');
}

return 1;