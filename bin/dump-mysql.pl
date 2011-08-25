#!/usr/bin/env perl
# ABSTRACT: dump schema and data to mysql
# PODNAME: dump-mysql.pl

use 5.010;
use utf8;
use strict;
use warnings;
use autodie;
use Const::Fast;
use Getopt::Long::Descriptive;

my $project = 'tinyblog';

const my $DB_USERNAME => lc $project;
const my $DB_PASSWORD => lc $project;
const my $DB_DATABASE => lc $project;

#binmode STDIN,  ':utf8';
#binmode STDOUT, ':utf8';

my ( $opt, $usage ) = describe_options(
    "%c %o ...",
    [
        'dump=i',
        'Dump level: '.
        '1 means dump schema. '.
        '2 means dump data. '.
        '3 means dump schema and data both. '.
        '(default: 3)',
        { default => 3 }
    ],
    [],
    [
        'schema=s',
        'Schema SQL path (default: sql/01-schema.sql)',
        { default => 'sql/01-schema.sql' }
    ],
    [
        'data=s',
        'Data SQL path (default: sql/02-data.sql)',
        { default => 'sql/02-data.sql' }
    ],
    [],
    [
        'host=s',
        'Database host (default: 127.0.0.1)',
        { default => '127.0.0.1' }
    ],
    [
        'username|u=s',
        "Database username (default: $DB_USERNAME)",
        { default => $DB_USERNAME }
    ],
    [
        'password|p=s',
        "Database password (default: $DB_PASSWORD)",
        { default => $DB_PASSWORD }
    ],
    [
        'database=s',
        "Database name (default: $DB_DATABASE)",
        { default => $DB_DATABASE }
    ],
    [],
    [ 'verbose|v', 'print extra stuff', { default => 0 } ],
    [ 'help|h',    'print usage message and exit'        ],
);

print($usage->text), exit if $opt->help;

const my $MYSQL_CMD => sprintf(
    q{mysql --host %s --user=%s --password=%s --default-character-set=utf8 %s},
    $opt->host,
    $opt->username,
    $opt->password,
    $opt->database,
);

given ($opt->dump) {
    when (1) {
        dump_sql($MYSQL_CMD, $opt->schema);
    }
    when (2) {
        dump_sql($MYSQL_CMD, $opt->data);
    }
    when (3) {
        dump_sql($MYSQL_CMD, $opt->schema);
        dump_sql($MYSQL_CMD, $opt->data);
    }
    default {
        say "invalid dump value";
        print($usage->text);
        exit;
    }
}

sub dump_sql {
    my $cmd = shift;
    my $sql = shift;

    system sprintf(q{cat \%s | %s}, $sql, $cmd);
}
