#!/usr/bin/env perl

use 5.012;
use utf8;
use strict;
use warnings;
use diagnostics;
use autodie;
use Getopt::Long::Descriptive;
use File::Slurp;

my ( $opt, $usage ) = describe_options(
    "%c %o ...",
    [ 'port|p=i', 'port number (default: 5000)', { default => 5000 } ],
    [],
    [ 'verbose|v', 'print extra stuff', { default => 0 } ],
    [ 'help|h',    'print usage message and exit' ],
);

print( $usage->text ), exit if $opt->help;

my $name = 'TinyBlog';
$name =~ s/(::|-)/_/g;
$name = lc $name;

my $psgi = "script/$name.psgi";
if ( !-e $psgi ) {
    system "script/${name}_create.pl PSGI";
    my $content = read_file($psgi);
    $content .= <<'END_CONTENT';
use Plack::Builder;

builder {
    enable_if {
        $_[0]->{REMOTE_ADDR} eq '127.0.0.1'
    } "Plack::Middleware::ReverseProxy";

    $app;
};
END_CONTENT
    write_file( $psgi, $content );
}
my $port = $opt->port;
exec(
    'plackup',
    '-I', 'lib',
    '-R', join(',', 'lib', <$name.*>),
    '-p', $opt->port,
    "script/$name.psgi",
);
