#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { $ENV{MOJO_NO_IPV6} = $ENV{MOJO_POLL} = 1 }

use Test::More tests => 10;

# testing code starts here
use Mojolicious::Lite;
use Test::Mojo;

plugin 'CountryDropDown';

app->log->level('debug');

get '/helper1' => 'helper1';

get '/helper2' => 'helper2';

get '/helper3' => 'helper3';

my $t = Test::Mojo->new;

$t->get_ok('/helper1')->status_is(200)->content_like(qr/<select id="country" name="country">/);

$t->get_ok('/helper2')->status_is(200)->content_like(qr/<select id="myid" name="myname">/);

$t->get_ok('/helper3')->status_is(200)
	->content_like(qr/<select class="somecssclass" data-wtf="xxx" id="myid" name="myname">/)
	->content_like(qr/>Deutschland</);

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
      <%= country_select_field({ attr => { id => "myid", name => "myname" } }) %>
    </form>
  </body>
</html>

@@ helper3.html.ep
<html>
  <head></head>
  <body>
    <form>
      <%= country_select_field({ lang => 'de', attr => { id => "myid", name => "myname", class => "somecssclass", "data-wtf" => "xxx" } }) %>
    </form>
  </body>
</html>

