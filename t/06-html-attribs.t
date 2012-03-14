#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { $ENV{MOJO_NO_IPV6} = $ENV{MOJO_POLL} = 1 }

use Test::More tests => 3;

# testing code starts here
use Mojolicious::Lite;
use Test::Mojo;

plugin 'CountryDropDown';

app->log->level( 'debug' );

get '/' => sub {
    my $self = shift;

    $self->show_country_list({ id => "myid", name => "myname" });
    $self->render( text => $self->stash->{country_drop_down} );
};

my $t = Test::Mojo->new;

$t->get_ok('/')->status_is(200)->content_like(qr/<select name="myname" id="myid">/);

