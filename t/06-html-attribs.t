#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { $ENV{MOJO_NO_IPV6} = $ENV{MOJO_POLL} = 1 }

use Test::More tests => 20;

# testing code starts here
use Mojolicious::Lite;
use Test::Mojo;

plugin 'CountryDropDown';

app->log->level( 'debug' );

get '/stash1' => sub {
    my $self = shift;

    $self->show_country_list();
    $self->render( text => $self->stash->{country_drop_down} );
};

get '/helper1' => 'helper1';

get '/stash2' => sub {
    my $self = shift;

    $self->show_country_list({ attr => { id => "myid", name => "myname" } });
    $self->render( text => $self->stash->{country_drop_down} );
};

get '/helper2' => 'helper2';

get '/stash3' => sub {
    my $self = shift;

    $self->show_country_list({ lang => 'de', attr => { id => "myid", name => "myname", class => "somecssclass", "data-wtf" => "xxx" } });
    $self->render( text => $self->stash->{country_drop_down} );
};

get '/helper3' => 'helper3';

my $t = Test::Mojo->new;

$t->get_ok('/stash1')->status_is(200)->content_like(qr/<select id="country" name="country">/);

$t->get_ok('/helper1')->status_is(200)->content_like(qr/<select id="country" name="country">/);

$t->get_ok('/stash2')->status_is(200)->content_like(qr/<select id="myid" name="myname">/);

$t->get_ok('/helper2')->status_is(200)->content_like(qr/<select id="myid" name="myname">/);

$t->get_ok('/stash3')->status_is(200)->content_like(qr/<select class="somecssclass" data-wtf="xxx" id="myid" name="myname">/)->content_like(qr/>Deutschland</);

$t->get_ok('/helper3')->status_is(200)->content_like(qr/<select class="somecssclass" data-wtf="xxx" id="myid" name="myname">/)->content_like(qr/>Deutschland</);

__DATA__

@@ helper1.html.ep
<html>
  <head></head>
  <body>
    <form>
      <%= country_drop_down() %>
	</form>
  </body>
</html>

@@ helper2.html.ep
<html>
  <head></head>
  <body>
    <form>
      <%= country_drop_down({ attr => { id => "myid", name => "myname" } }) %>
	</form>
  </body>
</html>

@@ helper3.html.ep
<html>
  <head></head>
  <body>
    <form>
      <%= country_drop_down({ lang => 'de', attr => { id => "myid", name => "myname", class => "somecssclass", "data-wtf" => "xxx" } }) %>
	</form>
  </body>
</html>

