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
    is( $e->noclobber, 'original', 'derived class accessors are preserved' );
    is( $e, 'Error=this is an error', 'stringify works for derived classes' );
    
    throws_ok{
        Derived->throwc(
            'Exception::Simple::Derived::Specific',
            'error' => 'this is an error',
            'noclobber' => 'clobbered'
        );
    } 'Exception::Simple::Derived::Specific';

    my $e = $@;
    is( $e->noclobber, 'original', 'derived override class accessors are preserved' );
    is( $e, 'Error=this is an error', 'stringify works for derived overridden classes' );

}

{
    throws_ok{
        Exception::Simple->throwc('Exception::Simple::Class', 'this is an error');
    } 'Exception::Simple::Class';

    my $e = $@;
    isa_ok( $e, "Exception::Simple::Class" );

    ok( scalar($e) eq 'this is an error', 'stringifaction works' );
    is( $e->error, 'this is an error', 'error method works' );

    throws_ok{
        $e->rethrow;
    } 'Exception::Simple::Class';
    is($@, 'this is an error', 'rethrow: stringifaction works');
    is( $@->error, 'this is an error', 'rethrow: error method works' );
}

done_testing();
