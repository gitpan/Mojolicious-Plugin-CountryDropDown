#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { $ENV{MOJO_NO_IPV6} = $ENV{MOJO_POLL} = 1 }

use Test::More tests => 3;

# testing code starts here
use Mojolicious::Lite;
use Test::Mojo;

plugin 'CountryDropDown', { lang => 'DE' };

app->log->level( 'debug' );

get '/' => sub {
    my $self = shift;

    my $country = $self->code2country( 'DE' );
    $self->render( text => $country );
};

my $t = Test::Mojo->new;

$t->get_ok('/')->status_is(200)->content_is('Deutschland');

