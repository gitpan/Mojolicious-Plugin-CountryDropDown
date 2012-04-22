#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { $ENV{MOJO_NO_IPV6} = $ENV{MOJO_POLL} = 1 }

use Test::More tests => 15;

# testing code starts here
use Mojolicious::Lite;
use Test::Mojo;

plugin 'CountryDropDown';

app->log->level( 'debug' );

get '/de' => sub {
    my $self = shift;

    my $code = $self->country2code( 'Deutschland', 'de' );
    $self->render( text => $code );
};

get '/en' => sub {
    my $self = shift;

    my $code = $self->country2code( 'Germany' );
    $self->render( text => $code );
};

get '/fr' => sub {
    my $self = shift;

    my $code = $self->country2code( 'Allemagne', 'fr' );
    $self->render( text => $code );
};

get '/conf_de' => sub {
    my $self = shift;

    $self->countrysf_conf({ lang => 'de' });
    my $code = $self->country2code('Deutschland');
    $self->render( text => $code );
};

my $t = Test::Mojo->new;

$t->get_ok('/de')->status_is(200)->content_is('DE');

$t->get_ok('/en')->status_is(200)->content_is('DE');

$t->get_ok('/fr')->status_is(200)->content_is('DE');

$t->get_ok('/conf_de')->status_is(200)->content_is('DE');

$t->get_ok('/fr')->status_is(200)->content_is('DE');
