package Mojolicious::Plugin::CountryDropDown;

# ABSTRACT: Provide a dropdown where users can select a country

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Plugin';
use Locale::Country::Multilingual { use_io_layer => 1 };
use Unicode::Collate;

our $VERSION = 0.04;

sub register {
	my $self = shift;
	my $app  = shift;
	my $conf = shift || {};

	$conf->{lang} = uc( $conf->{lang} || 'EN' );

	my $collate = Unicode::Collate->new();
	my $lcm     = Locale::Country::Multilingual->new();

	my $loaded = $lcm->assert_lang( $conf->{lang} );
	unless ( defined $loaded and uc($loaded) eq uc( $conf->{lang} ) ) {
		$app->log->error(
			"Unable to load language " . $conf->{lang} . "; falling back to English" );
		$lcm->set_lang('en');
	}
	else {
		$lcm->set_lang( $conf->{lang} );
	}

	$app->helper(
		get_country_list => sub {
			my $self = shift;

			my %opt  = %{ shift       || {} };
			my $lang = lc( $opt{lang} || $conf->{lang} );

			my %list = ();
			@list{ $lcm->all_country_codes } = $lcm->all_country_names($lang);

			return %list;
		}
	);

	$app->helper(
		show_country_list => sub {
			my $self = shift;

			my %opt = %{ shift || {} };
			my $code = $opt{selected} ? uc( $opt{selected} ) : '';
			my $lang = lc( $opt{lang} || $conf->{lang} );
			my $id_attr   = $opt{id}   || 'country';
			my $name_attr = $opt{name} || 'country';

			my @sorted = $collate->sort( $lcm->all_country_names($lang) );
			my %list   = ();
			foreach (@sorted) {
				$list{$_} = $lcm->country2code( $_, 'LOCALE_CODE_ALPHA_2', $lang );
			}

			my $options
				= join "\n", map {
				my $selected = uc( $list{$_} ) eq $code ? ' selected="selected"' : '';
				sprintf '<option value="%s"%s>%s</option>', $list{$_}, $selected, $_;
				} @sorted;

			my $elem = sprintf( '<select name="%s" id="%s">%s</select>', $name_attr, $id_attr,
				$options );

			$self->stash( country_drop_down => $elem );
		}
	);

	$app->helper(
		'code2country' => sub {
			my $self = shift;
			my $code = lc shift;
			my $lang = lc( shift || $conf->{lang} );

			return undef unless defined $code and $code;
			return $lcm->code2country( $code, $lang );
		}
	);

	$app->helper(
		'country2code' => sub {
			my $self    = shift;
			my $country = shift;
			my $lang    = lc( shift || $conf->{lang} );

			return undef unless defined $country and $country;
			return $lcm->country2code( $country, 'LOCALE_CODE_ALPHA_2', $lang );
		}
	);
} ## end sub register

1;


=pod

=head1 NAME

Mojolicious::Plugin::CountryDropDown - Provide a dropdown where users can select a country

=head1 VERSION

version 0.04

=head1 SYNOPSIS

    use Mojolicious::Plugin::CountryDropDown;

    sub startup {
        my $self = shift;

        $self->plugin('CountryDropDown');

        # or $self->plugin( 'CountryDropDown', { lang => 'de' } );
        # to specify the default language for the country names
    }

In your template (this time with TemplateToolkit syntax):

    [% country_drop_down %]

In your controller:

    get '/' => sub {
        my $self = shift;
        $self->show_country_list(); # this sets "country_drop_down" in the stash
    };

=head1 NAME

Mojolicious::Plugin::CountryDrowDown - use a dropdown to select countries in your form

=head1 WARNINGS

Version 0.04 is the first public release and for now considered a beta release!

=head1 CONFIGURATION

You may pass a hash ref on plugin registration. The only key currently 
processed is "lang" which can be used to set the default language for the
country names. 
Please refer to the L<Locale::Country::Multilingual|Locale::Country::Multilingual>
docs for a list of available languages. If you specify an unsupported language,
or no "lang" at all, "en" will be used as fallback.

=head1 METHODS/HELPERS

=head2 code2country

Returns the name for the given country code (ISO 3166 Alpha 2).

    my $code = 'DE';
    my $name = $self->code2country( $code ); # returns "Germany" unless
                                             # a different default language was
                                             # set when registering the plugin

    my $lang = 'fr';
    my $name = $self->code2country( $code, $lang ); # returns "Allemange"

=head2 country2code

Returns the Alpha 2 code for the given country name:

    my $name = 'Allemange';
    my $code = $self->country2code( $name ); # returns "DE"

=head2 show_country_list

Sets the stash variable with the dropdown ("select" element).
The default value used for the "id" and "name" attributes is "country".

The method optionally takes a hash ref as param which may contain one
or more of the following keys:

=over 4

=item selected

A ISO 3166 Alpha 2 country code denoting a preselected country.

=item lang

Determines the language of the country names.
The default is the value specified when registering the plugin (see above).

=item id

The value for the "id" attribute of the "select" element.
Defaults to "country".

=item name

The value for the "name" attribute of the "select" element.
Defaults to "country".

=back

    my $selected = 'DE'; # select Germany
    my $language = 'fr';
    $self->show_country_list( { select => $selected, lang => $language } );

=head2 get_country_list

Returns a hash indexed by the Alpha 2 country codes with the country names
as values.

You may pass a hash ref as param; the only key in there currently recognized
is "lang" which may be used to override the default language for the country
names.

=head1 AUTHORS

=over 4

=item *

Renee Baecker <module@renee-baecker.de>

=item *

Heiko Jansen <jansen@hbz-nrw.de>

=back

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by Hochschulbibliothekszentrum NRW (hbz).

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut


__END__

