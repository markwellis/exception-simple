package Exception::Simple;
use strict;
use warnings;

our $VERSION = '0.01';

use overload '""' => \&_as_string;

#add some POD

sub error{
    my ( $self, $error ) = @_;

    return $self->_get_set( 'error', $error );
}

sub _get_set{
    my ( $self, $key, $value ) = @_;

    if ( $value ){
        $self->{ $key } = $value;
    }
    return $self->{ $key } || undef;
}

sub _as_string {
    my ( $self ) = @_;
    return $self->error;
}

sub new{
    my ( $incovant, $error ) = @_;

    my $class = ref( $incovant ) || $incovant;
    my $self = bless({
        'error' => $error,
    }, $class);

    return $self;
}

sub throw {
    die shift->new( @_ );
}

1;
