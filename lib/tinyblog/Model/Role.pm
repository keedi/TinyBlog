package tinyblog::Model::Role;
use Fey::ORM::Table;
use tinyblog::Schema;

use Moose;
use MooseX::SemiAffordanceAccessor;
use MooseX::StrictConstructor;
use namespace::autoclean;

sub load {
    my $class = shift;

    return unless $class;
    return if     $class->Table;

    my $schema = tinyblog::Schema->Schema;
    my $table  = $schema->table('role');

    has_table( $table );

    #
    # Add another relationships like has_one, has_many or etc.
    #
    #has_many items => ( table => $schema->table('item') );
}

1;
