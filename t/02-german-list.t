#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { $ENV{MOJO_NO_IPV6} = $ENV{MOJO_POLL} = 1 }

use Test::More tests => 6;

# testing code starts here
use Mojolicious::Lite;
use Test::Mojo;

plugin 'CountryDropDown', { lang => 'de' };

app->log->level( 'debug' );

get '/de' => sub {
    my $self = shift;

    $self->show_country_list;
    $self->render( text => $self->stash->{country_drop_down} );
};

get '/en' => sub {
    my $self = shift;

    $self->show_country_list({ lang => 'en' });
    $self->render( text => $self->stash->{country_drop_down} );
};

my $t = Test::Mojo->new;

$t->get_ok('/de')->status_is(200)->content_like(qr/"DE"\s*>Deutschland<\/option>/);

$t->get_ok('/en')->status_is(200)->content_like(qr/"DE"\s*>Germany<\/option>/);
