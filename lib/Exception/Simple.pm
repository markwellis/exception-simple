package Exception::Simple;
use strict;
use warnings;

our $VERSION = '0.007';
$VERSION = eval $VERSION;

use overload(
    'fallback' => 1,
    '""'       => sub { shift->_string },
);

# __public__ #
sub throw{
    my $self = shift;
    my %params;

    if ( @_ == 1 ){
	    %params = ( 'error' => $_[0] );
    } else {
         %params = ( @_ );
    }

    ( $params{'package'}, $params{'filename'}, $params{'line'} ) = caller;

    die $self->_new( %params );
}

sub rethrow{
    die shift;
}

# __internal__ #

sub _string{
    my $self = shift;
    return $self->error . ' at ' . $self->filename . ' line ' . $self->line;
}

sub _new{
    my $invocant = shift;
    my %params = ( @_ );

    my $class = ref( $invocant ) || $invocant;
    my $self = bless( \%params, $class );

#serious business
    foreach my $key ( keys( %params ) ){
        if ( !$self->can( $key ) ){
            $self->_mk_accessor( $key );
        }
    }

    return $self;
}

#creates an accessor for $name if it's not an existing method
sub _mk_accessor{
    my ( $self, $name ) = @_;

    my $class = ref( $self ) || $self;
    {
        no strict 'refs';
        *{$class . '::' . $name} = sub {
            return shift->{ $name } || undef;
        };
    }
}

1;

=head1 NAME

Exception::Simple - simple exception class

=head1 SYNOPSIS

    use Exception::Simple;
    use Try::Tiny; #or just use eval {}, it's all good

    ### throw ###
    try{
        Exception::Simple->throw( 'oh noes!' );
    } catch {
        warn $_; #"oh noes! at filename.pl line 3"
        warn $_->error; #"oh noes!"
    };

    my $data = { 
        'foo' => 'bar',
        'fibble' => [qw/wibble bibble/],
    };
    try{
        Exception::Simple->throw( 
            'error' => 'oh noes!',
            'data' => $data,
        );  
    } catch {
        warn $_; #"oh noes!"
        warn $_->error; #"oh noes!"

        warn $_->data->{'foo'}; #"bar"
    };

=head1 DESCRIPTION

pretty simple exception class. auto creates argument accessors.
simple, lightweight and extensible are this modules goals.

=head1 METHODS

=head2 throw

with just one argument $@->error is set
    Exception::Simple->throw( 'error message' );
    # $@ stringifies to $@->error

or set multiple arguments (creates accessors)
    Exception::Simple->throw( 
        error => 'error message',
        data => 'cutom atrribute',
    );
    # warn $@->data or something

=head2 rethrow

say you catch an error, but then you want to uncatch it

    use Try::Tiny;

    try{
        Exception:Simple->throw( 'foobar' );
    } catch {
        if ( $_ eq 'foobar' ){
        #not our error, rethrow
            $_->rethrow; 
        }
    };

=head2 error

accessor for error message (set if only 1 arg is passed to throw)

=head2 package

package that threw the exception

=head2 filename

filename of the code that threw the exception

=head2 line

line number that threw the exception

=head1 SUPPORT

Bugs should always be submitted via the CPAN bug tracker

For other issues, contact the maintainer

=head1 AUTHOR

n0body E<lt>n0body@thisaintnews.comE<gt>

=head1 CONTRIBUTORS

Stephen Thirlwall

=head1 SEE ALSO

L<http://thisaintnews.com>, L<Try::Tiny>

=head1 LICENSE

Copyright (C) 2013 by n0body L<http://thisaintnews.com/>

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
