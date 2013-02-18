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

use constant {
    SERVER_ERROR     => '0',
    SERVER_FOUND     => '1',
    SERVER_NOT_FOUND => '4',
    SERVER_FULL      => '9',
};

my $cache = Cache::Memory::Simple->new();
my $expire = 60 * 60 * 24;

my $json = JSON->new->utf8(1)->relaxed(1);

my $_uri = URI->new('http://www.google.com/transliterate');
sub _uri {
    my $text = shift;
    my $uri = $_uri->clone;
    $uri->query_form(
        langpair => 'ja-Hira|ja',
        text     => encode_utf8($text . ','), # prevent separating the clause
    );
    return $uri;
}

my $skkserv = AnyEvent::SKKServ->new(
    port => 55100,
    on_request => sub {
        my ($hdl, $req) = @_;
        $req = decode('euc-jp', $req);

        my $server_found = sub {
            my $val = shift;
            $hdl->push_write(SERVER_FOUND . "/$val/\n");
        };
        my $server_not_found = sub {
            $hdl->push_write(SERVER_NOT_FOUND . "\n");
        };
        my $server_error = sub {
            $hdl->push_write(SERVER_ERROR . "\n");
        };

        # ignore okuri-ari entry
        if ($req =~ /([a-z])$/) {
            $server_not_found->();
            return;
        }

        if (my $val = $cache->get($req)) {
            $server_found->($val);
        } else {
            http_get _uri($req), timeout => 1, sub {
                if ($_[1]->{Status} == 200) {
                    my $res = $json->decode($_[0]);
                    my $val = join '/', @{$res->[0][1]};
                    $val = encode('euc-jp', $val);
                    $server_found->($val);

                    $cache->set($req => $val, $expire);
                } else {
                    $server_error->();
                }
            };
        }
    },
);
$skkserv->run;

AE::cv()->recv;
