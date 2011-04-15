use inc::Module::Install;

all_from('lib/Exception/Simple.pm');

requires 'Carp';
requires 'overload';
test_requires 'Test::More';
test_requires 'Test::Exception';
test_requires 'parent';

auto_install;
WriteAll;
