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

    is($e, 'this is an error at t/exception-simple.t line 11', 'stringifaction works' );
    is( $e->error, 'this is an error', 'error method works' );

    throws_ok{
        $e->rethrow;
    } 'Exception::Simple';
    is($@, 'this is an error at t/exception-simple.t line 11', 'rethrow: stringifaction works');
    is( $@->error, 'this is an error', 'rethrow: error method works' );
}

{
    throws_ok{
        Exception::Simple->throw('this is an error');
    } 'Exception::Simple';

    my $e = $@;

    is( $e, 'this is an error at t/exception-simple.t line 28', 'stringifaction works' );
    is( $e->error, 'this is an error', 'error method works' );

    throws_ok{
        $e->rethrow;
    } 'Exception::Simple';
    is($@, 'this is an error at t/exception-simple.t line 28', 'rethrow: stringifaction works');
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

{
    {
        package Derived;
        use parent 'Exception::Simple';

        sub error { 'Error=' . shift->{error} }
        sub noclobber { 'original' }
    }

    throws_ok{
        Derived->throw(
            'error' => 'this is an error',
            'noclobber' => 'clobbered'
        );
    } 'Derived';

    my $e = $@;
    is( $e->noclobber, 'original', 'derived override class accessors are preserved' );
    is( $e, 'Error=this is an error at t/exception-simple.t line 79', 'stringify works for derived overridden classes' );

}

{
    {
        package Exception::Simple::Test;
        sub new{
            bless({}, shift);
        }
        sub something{
            Exception::Simple->throw('something');
        }
        1;
    }

    my $test = Exception::Simple::Test->new;

    throws_ok{
        $test->something
    } 'Exception::Simple';
    my $e = $@;
    is( $e, 'something at t/exception-simple.t line 98', 'filename and line set correctly' );
    is( $e->package, 'Exception::Simple::Test', 'package set correctly' );
}

done_testing();
