#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install;

name 'GalleryCat';
all_from 'lib/GalleryCat.pm';

requires 'Catalyst::Runtime' => '5.80007';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'parent';
requires 'Config::General'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats

requires 'Image::Info';
requires 'Image::ExifTool';
requires 'IO::Dir';
requires 'JSON::XS';
requires 'Path::Class';
requires 'File::Slurp';

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
