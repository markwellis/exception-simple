use strict;
use warnings;

use Test::More;
use Test::Exception;

use Exception::Simple;

{
    throws_ok{
        Exception::Simple->throw(error => 'this is an error');
    } 'Exception::Simple';

    my $e = $@;

    ok( scalar($e) eq 'this is an error', 'stringifaction works' );
    is( $e->error, 'this is an error', 'error method works' );

    throws_ok{
        $e->rethrow;
    } 'Exception::Simple';
    is($@, 'this is an error', 'rethrow: stringifaction works');
    is( $@->error, 'this is an error', 'rethrow: error method works' );
}

{
    throws_ok{
        Exception::Simple->throw('this is an error');
    } 'Exception::Simple';

    my $e = $@;

    is( $e, 'this is an error', 'stringifaction works' );
    is( $e->error, 'this is an error', 'error method works' );

    throws_ok{
        $e->rethrow;
    } 'Exception::Simple';
    is($@, 'this is an error', 'rethrow: stringifaction works');
    is( $@->error, 'this is an error', 'rethrow: error method works' );
}

{
    throws_ok{
        Exception::Simple->throw(error => 'this is an error', 'other' => 'foobar' );
    } 'Exception::Simple';

    my $e = $@;
    isa_ok( $e, 'Exception::Simple' );
    is( $e->other, 'foobar', 'other accessor has been created' );
}

{
    throws_ok{
        Exception::Simple->throw(
            'error' => 'this is an error',
            'other' => 'foobar',
            'rethrow' => 'i has no accessor',
        );
    } 'Exception::Simple';

    my $e = $@;
    isa_ok( $e, 'Exception::Simple' );
    throws_ok{
        $e->rethrow;
    } 'Exception::Simple';
}

done_testing();
