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

get '/ref' => sub {
    my $self = shift;

    my %hash = $self->get_country_list();
    $self->render( text => ref(\%hash) );
};

get '/val' => sub {
    my $self = shift;

    my %hash = $self->get_country_list();
    $self->render( text => $hash{'DE'} );
};

get '/val_lang' => sub {
    my $self = shift;

    my %hash = $self->get_country_list('fr');
    $self->render( text => $hash{'DE'} );
};

get '/conf_lang' => sub {
	my $self = shift;

	$self->countrysf_conf({ lang => 'de' });
	my %hash = $self->get_country_list();
	$self->render( text => $hash{'DE'} );
};

my $t = Test::Mojo->new;

$t->get_ok('/ref')->status_is(200)->content_is('HASH');

$t->get_ok('/val')->status_is(200)->content_is('Germany');

$t->get_ok('/val_lang')->status_is(200)->content_is('Allemagne');

$t->get_ok('/val')->status_is(200)->content_is('Germany');

$t->get_ok('/conf_lang')->status_is(200)->content_is('Deutschland');
