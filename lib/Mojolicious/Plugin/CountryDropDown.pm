package Mojolicious::Plugin::CountryDropDown;

# ABSTRACT: Provide a dropdown where users can select a country

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Plugin';
use Mojo::ByteStream;
use Locale::Country::Multilingual { use_io_layer => 1 };
use Unicode::Collate;

our $VERSION = 0.05_01;
$VERSION = eval $VERSION;

sub register {
	my $self = shift;
	my $app  = shift;
	my $conf = shift || {};

	$conf->{lang}     = uc( $conf->{lang} || 'EN' );
	$conf->{selected} = '';

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

	my $_html = sub {
		my %opt = %{ shift || {} };
		my $code = $opt{selected} ? uc( $opt{selected} ) : $conf->{selected};
		my $lang = lc( $opt{lang} || $conf->{lang} );
		my %attr = %{ $opt{attr} || {} };
		
		$attr{id}   = 'country' unless defined( $attr{id}   ) and length( $attr{id}   ) > 0;
		$attr{name} = 'country' unless defined( $attr{name} ) and length( $attr{name} ) > 0;

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

		my $attribs = '';
		foreach my $k ( sort keys %attr ) {
			$attr{$k} =~ s/"/&quot;/go;
			$attribs .= sprintf( ' %s="%s"', $k, $attr{$k} );
		}
		substr( $attribs, 0, 1 ) = '';

		return sprintf( "<select %s>\n%s\n</select>", $attribs, $options );
	};

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
			$self->stash( country_drop_down => $_html->(@_) );
			return;
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

	$app->helper(
		'country_drop_down' => sub {
			my $self = shift;
			return Mojo::ByteStream->new( $_html->(@_) );
		}
	);

	return;
} ## end sub register

1;


=pod

=head1 NAME

Mojolicious::Plugin::CountryDropDown - Provide a dropdown where users can select a country

=head1 VERSION

version 0.0501

=head1 SYNOPSIS

    use Mojolicious::Plugin::CountryDropDown;

    sub startup {
        my $self = shift;

        $self->plugin('CountryDropDown');

        # or $self->plugin( 'CountryDropDown', { lang => 'de' } );
        # to specify the default language for the country names
    }

In your controller:

    get '/' => sub {
        my $self = shift;
        $self->show_country_list(); # this sets "country_drop_down" in the stash
    };

In your template (this time with TemplateToolkit syntax):

    [% country_drop_down %]

Alternatively - using 0.05_01 and up - you can omit the show_country_list() method call
inside the controller and use a helper method directly in the template, e.g.:

    [% h.country_drop_down({ lang => 'de' }) %]

=head1 NAME

Mojolicious::Plugin::CountryDrowDown - use a dropdown to select countries in your form

=head1 WARNINGS

Version 0.04 was the first public release and considered a beta release!
Version 0.05_01 includes some API changes and there may be some more coming
before version 0.06 is released - so please watch out when updating!

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

=item attr

The value is another hash ref whose keys are used as HTML attributes of the 
"select" element. No validity checking is performed regarding attribute names
and values.

Unless you specify any values for the attributes "id" and "name" they are 
both set to "country".

=back

    my $selected = 'DE'; # select Germany
    my $language = 'fr';
    $self->show_country_list( { select => $selected, lang => $language } );

    $self->show_country_list( {
            select => $selected, 
            lang => $language,
			attr => { id => "cid", name => "cname" }
    });

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

