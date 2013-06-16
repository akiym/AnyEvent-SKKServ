# NAME

AnyEvent::SKKServ - Lightweight skkserv implementation for AnyEvent

# SYNOPSIS

    use AnyEvent;
    use AnyEvent::SKKServ;

    my $cv = AE::cv();

    my $skkserv = AnyEvent::SKKServ->new(
        on_request => sub {
            my ($handle, $request) = @_;

            ...
        },
    );
    $skkserv->run;

    $cv->recv;

# DESCRIPTION

AnyEvent::SKKServ is yet another skkserv implementation. And too simple, so it doesn't support jisyo (dictionary) file.

Let's make your own skkserv! (e.g. Google CGI API for Japanese Input, Social IME's API, ...)

__THIS IS A DEVELOPMENT RELEASE. API MAY CHANGE WITHOUT NOTICE__.

# METHODS

## new

- host : Str

    Takes an optional host address.

- port => 55100 : Num

    Takes an optional port number. (Defaults to 55100)

- on\_error => $cb->($handle) : CodeRef

    Takes a callback for when you receive an illegal data.

- on\_end => $cb->($handle) : CodeRef
- on\_request => $cb->($handle, $request) : CodeRef
- on\_version => $cb->($handle) : CodeRef
- on\_host => $cb->($handle) : CodeRef

    Takes callbacks corresponding to reply from the client (see ["PROTOCOL"](#PROTOCOL)).

## run

Run skkserv.

# PROTOCOL

## Client Request Form

- "0"

    end of connection

- "1eee "

    eee is keyword in EUC code with ' ' at the end

- "2"

    skkserv version number

- "3"

    hostname and its IP addresses

## Server Reply Form for "1eee"

- "0"

    Error

- "1eee"

    eee is the associated line separated by '/'

- "4"

    Not Found

## Server Reply Form for "2"

- "A.B "

    A for major version number, B for minor version number followed by a space

## Server Reply Form for "3"

- "string:addr1:...: "

    string for hostname, addr1 for an IP address followed by a space

# AUTHOR

Takumi Akiyama <akiym@cpan.org>

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
