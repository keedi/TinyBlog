#!/usr/bin/env perl
# ABSTRACT: generate initial module based on Fey::ORM
# PODNAME: update-module.pl

use 5.010;
use utf8;
use strict;
use warnings;
use autodie;
use Getopt::Long::Descriptive;
use Const::Fast;
use File::Slurp;
use App::mkfeyorm;

my $project = 'TinyBlog';

const my $NAMESPACE       => $project;
const my $SCHEMA          => 'Schema';
const my $TABLE_NAMESPACE => 'Model';
const my $USER_TABLE      => 'User';
const my @TABLES => (qw/
    Role
    User
    UserRole
/);

my ( $opt, $usage ) = describe_options(
    "%c %o ...",
    [ 'update|u',    'generate modules'  ],
    [],
    [ 'verbose|v',   'print extra stuff', { default => 0 } ],
    [ 'help|h',      'print usage message and exit'        ],
);

print($usage->text), exit if $opt->help;

if ($opt->update) {
    my $app = App::mkfeyorm->new(
        namespace       => $NAMESPACE,
        schema          => $SCHEMA,
        table_namespace => $TABLE_NAMESPACE,
        tables          => [ @TABLES ],
        cache           => 1,
    );

    print 'generating modules...' if $opt->verbose;
    $app->process;
    say " [DONE]" if $opt->verbose;

    print 'overwriting user table...' if $opt->verbose;
    $app->set_template_params({
        USER        => $app->tables->{'User'},
        ROLE        => $app->tables->{'Role'},
        USER_ROLE   => $app->tables->{'UserRole'},
        ROLE_MODULE => ($app->table_modules('Role'))[0],
    });
    my $template = read_file(\*DATA);
    $app->set_table_template( $template );
    $app->process_tables('User');
    say " [DONE]" if $opt->verbose;
}

__DATA__
package [% TABLE %];
use Fey::ORM::Table;
use [% SCHEMA %];

use Moose;
use MooseX::SemiAffordanceAccessor;
use MooseX::StrictConstructor;
use namespace::autoclean;

has roles => (
    is         => 'ro',
    isa        => 'Fey::Object::Iterator::FromSelect',
    lazy_build => 1,
);

sub _build_roles {
    my $self = shift;

    my $schema    = [% SCHEMA %]->Schema;
    my $dbh       = [% SCHEMA %]->DBIManager->default_source->dbh;
    my $user      = $schema->table('[% PARAMS.USER %]');
    my $role      = $schema->table('[% PARAMS.ROLE %]');
    my $user_role = $schema->table('[% PARAMS.USER_ROLE %]');

    my $select = [% SCHEMA %]->SQLFactoryClass->new_select
        ->select($role)
        ->from($role,      $user_role)
        ->from($user_role, $user)
        ->where($user->column('id'), '=', Fey::Placeholder->new)
        ;

    return Fey::Object::Iterator::FromSelect->new(
        classes     => '[% PARAMS.ROLE_MODULE %]',
        dbh         => $dbh,
        select      => $select,
        bind_params => [ $self->id ],
    );
}

sub load {
    my $class = shift;

    return unless $class;
    return if     $class->Table;

    my $schema = [% SCHEMA %]->Schema;
    my $table  = $schema->table('[% DB_TABLE %]');

    has_table( $table );

    #
    # Add another relationships like has_one, has_many or etc.
    #
    #has_many items => ( table => $schema->table('item') );
}

1;
