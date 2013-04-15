package Exception::Simple;
use strict;
use warnings;

our $VERSION = '0.006';
$VERSION = eval $VERSION;

use Carp qw/croak/;
use overload(
    'fallback' => 1,
    '""'       => sub { shift->error },
);

# __public__ #

sub throw{
    croak shift->_new( @_ );
}

sub throwc{
    my ( $invocant, $exception_class, @args ) = @_;

    {
        no strict "refs";

        my $isa = "$exception_class\::ISA";
        if ( !grep( /^$invocant$/, $isa ) ){
            push( @{ $isa }, $invocant );
        }
    }

    croak $exception_class->_new( @args );
}

sub rethrow{
    croak shift;
}

#error is special coz its the stringify method
#it needs to be defined, and overridable by subclasses
sub error{
    return shift->{'error'} || undef;
}

# __internal__ #

sub _new{
    my ( $invocant, @args ) = @_;

    my %params;
    if ( ( @args == 1 ) && !ref( $args[0] ) ) {
	    %params = ( 'error' => $args[0] );
    } else {
        %params = ( @args );
    }

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
        warn $_; #"oh noes!" 
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
   
    ### throwc ###
    try{
        Exception::Simple->throwc( "Some::Fake::Exception::Class", 'oh noes!' );
    } catch {
        warn $_; #"oh noes!"
        warn ref( $_ ); #"Some::Fake::Exception::Class"
        warn $_->error; #"oh noes!"
    };

    my $data = { 
        'foo' => 'bar',
        'fibble' => [qw/wibble bibble/],
    };
    try{
        Exception::Simple->throwc( 
            'Some::Fake::Exception::Class',
            'error' => 'oh noes!',
            'data' => $data,
        );  
    } catch {
        warn $_; #"oh noes!"
        warn ref( $_ ); #"Some::Fake::Exception::Class"
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

=head2 throwc

Same as throw, except the first argument is a classname
which will become the classname of the exception object.

Useful for throwing specific execptions without having to 
create lots of packages.

    try{
        Exception::Simple->throwc( "Some::Fake::Exception::Class", 'oh noes!' );
    } catch {
        warn ref( $_ ); #Some::Fake::Exception::Class
    };
    
B<WARNING>: using throwc with a real classname is unsupported
i.e. 
    throwc( "Data::Dumper", "derp" ) #you just made god kill a kitten

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

accessor for error, if its been set

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

Copyright (C) 2012 by n0body L<http://thisaintnews.com/>

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
