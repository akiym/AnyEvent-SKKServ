requires 'AnyEvent', '7.04';
requires 'perl', '5.008005';

on build => sub {
    requires 'Test::More', '0.98';
};

on test => sub {
    requires 'Test::TCP', '2.00';
};
