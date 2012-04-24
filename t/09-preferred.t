#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { $ENV{MOJO_NO_IPV6} = $ENV{MOJO_POLL} = 1 }

use Test::More tests => 6;

# testing code starts here
use Mojolicious::Lite;
use Test::Mojo;

plugin 'CountryDropDown', { prefer => [ 'DE', 'AT', 'CH', ] };

app->log->level('debug');

get '/helper1' => 'helper1';

get '/helper2' => 'helper2';

my $t = Test::Mojo->new;

$t->get_ok('/helper1')->status_is(200)
	->content_like(qr/"><option value="DE">Germany<\/option>.+<option value="DE">Germany</);

$t->get_ok('/helper2')->status_is(200)
	->content_like(
	qr/"><option selected="selected" value="DE">Germany<\/option><option value="AT">Austria<\/option><option value="CH">Switzerland<\/option><option value="">----<\/option>.+<option value="DE">Germany</
	);

#warn $t->get_ok('/helper2')->_get_content($t->tx);

__DATA__

@@ helper1.html.ep
<html>
  <head></head>
  <body>
    <form>
      <%= country_select_field() %>
	</form>
  </body>
</html>

@@ helper2.html.ep
<html>
  <head></head>
  <body>
    <form>
      <%= country_select_field({ selected => 'DE' }) %>
	</form>
  </body>
</html>

