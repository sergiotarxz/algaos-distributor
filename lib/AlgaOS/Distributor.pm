package AlgaOS::Distributor;

use v5.40.0;
use strict;
use warnings;

use Mojo::Base 'Mojolicious', -signatures;

open *STDOUT, '|-', qw/tee -a stdout.log/;
open *STDERR, '|-', qw/tee -a stderr.log/;

sub startup ($self) {
    my $config = $self->plugin('NotYAMLConfig');

    $self->secrets( $config->{secrets} );

    my $r = $self->routes;

    $r->add_type( machine_id => qr/[0-9a-f]{32}/ );
    $r->add_condition(
        relative_path => sub ( $route, $c, $captures, @extra ) {
            my $path = $c->param('path_binpkg') // '';

            return $path !~ m{(?:^|/)\.\.(?:/|$)};
        }
    );

    # Router
    $r->get('/')->to('Root#welcome');
    $r->get('/:machine_id<machine_id>/webrsync.tar.bz2')->to('Root#webrsync');
    $r->get('/:machine_id<machine_id>/binpkg/*path_binpkg')
      ->requires( relative_path => 1 )
      ->to('Root#binpkg');
}
1;
