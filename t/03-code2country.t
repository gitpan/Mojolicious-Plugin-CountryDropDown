#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { $ENV{MOJO_NO_IPV6} = $ENV{MOJO_POLL} = 1 }

use Test::More tests => 9;

# testing code starts here
use Mojolicious::Lite;
use Test::Mojo;

plugin 'CountryDropDown';

app->log->level( 'debug' );

get '/en' => sub {
    my $self = shift;

    my $country = $self->code2country('DE');
    $self->render( text => $country );
};

get '/de' => sub {
    my $self = shift;

    my $country = $self->code2country( 'DE', 'de' );
    $self->render( text => $country );
};

get '/conf' => sub {
    my $self = shift;

    $self->countrysf_conf({ lang => 'fr' });
    my $country = $self->code2country('DE');
    $self->render( text => $country );
};

my $t = Test::Mojo->new;

$t->get_ok('/en')->status_is(200)->content_is('Germany');

$t->get_ok('/de')->status_is(200)->content_is('Deutschland');

$t->get_ok('/conf')->status_is(200)->content_is('Allemagne');

