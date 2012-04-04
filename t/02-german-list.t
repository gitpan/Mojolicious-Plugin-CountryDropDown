#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { $ENV{MOJO_NO_IPV6} = $ENV{MOJO_POLL} = 1 }

use Test::More tests => 12;

# testing code starts here
use Mojolicious::Lite;
use Test::Mojo;

plugin 'CountryDropDown', { lang => 'de' };

app->log->level( 'debug' );

get '/de_stash' => sub {
    my $self = shift;

    $self->show_country_list;
    $self->render( text => $self->stash->{country_drop_down} );
};

get '/en_stash' => sub {
    my $self = shift;

    $self->show_country_list({ lang => 'en' });
    $self->render( text => $self->stash->{country_drop_down} );
};

get '/de_helper' => 'de_helper';

get '/en_helper' => 'en_helper';

my $t = Test::Mojo->new;

$t->get_ok('/de_stash')->status_is(200)->content_like(qr/"DE"\s*>Deutschland<\/option>/);

$t->get_ok('/en_stash')->status_is(200)->content_like(qr/"DE"\s*>Germany<\/option>/);

$t->get_ok('/de_helper')->status_is(200)->content_like(qr/"DE"\s*>Deutschland<\/option>/);

$t->get_ok('/en_helper')->status_is(200)->content_like(qr/"DE"\s*>Germany<\/option>/);

#warn $t->get_ok('/en_helper')->_get_content($t->tx);

__DATA__

@@ de_helper.html.ep
<html>
  <head></head>
  <body>
    <form>
      <%= country_drop_down() %>
	</form>
  </body>
</html>

@@ en_helper.html.ep
<html>
  <head></head>
  <body>
    <form>
      <%= country_drop_down({ lang => 'en' }) %>
	</form>
  </body>
</html>

