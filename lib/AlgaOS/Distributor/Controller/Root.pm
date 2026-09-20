package AlgaOS::Distributor::Controller::Root;

use v5.40.0;
use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller', -signatures;
use Mojo::File qw/path/;

# This action will render a template
sub welcome ($self) {

    # Render template "example/welcome.html.ep" with message
    $self->render( text => 'hola' );
}

sub _get_preference($self) {
    my $preference = $self->param('preference');
    return if !defined $preference;
    if (!grep { $_ eq $preference } (qw/latest next stable/)) {
        die 'Unhandled Bad Argument';
    }
    return $preference;
}

sub webrsync ($self) {
    my $machine_id = $self->param('machine_id');
    my $tag        = $self->_get_preference // 'next';

    my $file = "/var/www/algaos/downloads/webrsync-$tag.tar.bz2";

    return $self->reply->not_found unless -f $file;

    $self->reply->file($file);
}

sub binpkg ($self) {
    my $machine_id = $self->param('machine_id');
    my $tag        = $self->_get_preference // 'next';

    my $root = path("/var/www/algaos/downloads/binpkg-algaos-$tag")->realpath;

    my $relative = $self->param('path_binpkg');
    say $relative;
    my $file     = $root->child($relative)->realpath;
    say $file;

    return $self->reply->not_found
      unless $file && -f $file;

    return $self->reply->not_found
      unless $file->to_string =~ m{\A\Q$root\E/};

    $self->reply->file($file);
}
1;
