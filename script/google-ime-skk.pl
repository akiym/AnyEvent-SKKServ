use strict;
use warnings;
use utf8;
use AnyEvent;
use AnyEvent::HTTP;
use AnyEvent::SKKServ;
use Cache::Memory::Simple;
use Encode;
use JSON;
use URI;

our $GOOGLE_IME_URL = 'http://www.google.com/transliterate';

my $cache = Cache::Memory::Simple->new();
my $expire = 60 * 60 * 24;

my $json = JSON->new->utf8(1)->relaxed(1);

my $skkserv = AnyEvent::SKKServ->new(
    port => 55100,
    on_request => sub {
        my ($hdl, $req) = @_;
        $req = decode('euc-jp', $req);
        $req =~ s/([a-z])$/,$1/; # 書く => かk

        if (my $val = $cache->get($req)) {
            $hdl->push_write("1/$val\n");
        } else {
            my $uri = URI->new($GOOGLE_IME_URL);
            $uri->query_form(
                langpair => 'ja-Hira|ja',
                text     => encode_utf8($req),
            );
            http_get $uri, timeout => 1, sub {
                my $res = $json->decode($_[0]);
                my $val = join '/', @{$res->[0][1]};
                $val = encode('euc-jp', $val);

                $hdl->push_write("1/$val\n");

                $cache->set($req => $val, $expire);
            };
        }
    },
);
$skkserv->run;

AE::cv()->recv;
