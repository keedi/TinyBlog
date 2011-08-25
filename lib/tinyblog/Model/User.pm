package tinyblog::Model::User;
use Fey::ORM::Table;
use tinyblog::Schema;

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

    my $schema    = tinyblog::Schema->Schema;
    my $dbh       = tinyblog::Schema->DBIManager->default_source->dbh;
    my $user      = $schema->table('user');
    my $role      = $schema->table('role');
    my $user_role = $schema->table('user_role');

    my $select = tinyblog::Schema->SQLFactoryClass->new_select
        ->select($role)
        ->from($role,      $user_role)
        ->from($user_role, $user)
        ->where($user->column('id'), '=', Fey::Placeholder->new)
        ;

    return Fey::Object::Iterator::FromSelect->new(
        classes     => 'tinyblog::Model::Role',
        dbh         => $dbh,
        select      => $select,
        bind_params => [ $self->id ],
    );
}

sub load {
    my $class = shift;

    return unless $class;
    return if     $class->Table;

    my $schema = tinyblog::Schema->Schema;
    my $table  = $schema->table('user');

    has_table( $table );

    #
    # Add another relationships like has_one, has_many or etc.
    #
    #has_many items => ( table => $schema->table('item') );
}

1;
