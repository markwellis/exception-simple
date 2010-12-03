use strict;
use warnings;

use Test::More;
use Try::Tiny;

use Exception::Simple;

#test exception class
try{
    Exception::Simple->throw('this is an error');
} catch {
    my $e = $_;

    isa_ok( $e, 'Exception::Simple' );
    is( $e->error, 'this is an error', 'error has been set' );
    is ( $e, 'this is an error', 'stringifaction works' );
};

done_testing();
