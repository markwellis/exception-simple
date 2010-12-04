package Exception::Simple;
use strict;
use warnings;

our $VERSION = '0.001';
$VERSION = eval $VERSION;

use Carp qw/croak cluck/;
use overload(
    'fallback' => \&_as_string,
    '""' => \&_as_string,
);

#add some POD

sub _as_string{
    return shift->error;
}

#error is special coz its the stringify method
#it needs to be defined, and overridable by subclasses
sub error{
    return shift->{'error'} || undef;
}

sub new{
    my ( $incovant, @args ) = @_;

    my %params;
    if ( @args == 1 && !ref $args[0] ) {
	    %params = ('error' => $args[0]);
    } else {
        %params = ( @args );
    }

    my $class = ref( $incovant ) || $incovant;
    my $self = bless( \%params, $class );

#serious business
    foreach my $key ( keys( %params ) ){
        $self->_mk_accessor( $key );
    }
 
    return $self;
}

sub _mk_accessor{
    my ( $self, $key ) = @_;

    if ( !__PACKAGE__->can($key) ){
    #create accessor if function doesn't exist
        my $accessor = __PACKAGE__ . "::$key";
        {
            no strict 'refs';
            *$accessor = sub {
                return $self->{ $key } || undef;
            };
        }
    }
}

sub throw{
    croak shift->new( @_ );
}

sub rethrow{
    croak shift;
}

1;
