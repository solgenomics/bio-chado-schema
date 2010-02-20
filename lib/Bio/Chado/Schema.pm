package Bio::Chado::Schema;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;
use Carp;
use Module::Load ();

use base 'DBIx::Class::Schema';

__PACKAGE__->load_classes;


# Created by DBIx::Class::Schema::Loader v0.04999_12 @ 2010-01-01 13:09:35
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:GfcGc0XJeU/0mXXXgJb7FQ

our $VERSION = '0.05502';
$VERSION = eval $VERSION;

=head1 NAME

Bio::Chado::Schema - standard DBIx::Class layer for the Chado database schema

=head1 SYNOPSIS

  use Bio::Chado::Schema;

  my $chado = Bio::Chado::Schema->connect( $dsn, $user, $password );

  print "number of rows in feature table: ",
        $chado->resultset('Sequence::Feature')->count,
        "\n";


=head1 DESCRIPTION

This is a standard object-relational mapping layer for use with the
GMOD Chado database schema.  This layer is implemented with
L<DBIx::Class>, generated with the help of the very fine
L<DBIx::Class::Schema::Loader> module.

Chado is an open-source modular database schema for biological data.
It is divided into several notional "modules", which are reflected in the namespace organization of this package.  Note that modules in the Chado context refers to sets of tables, they are not modules in the Perl sense.

To learn how to use this DBIx::Class ORM layer, a good starting
point is the L<DBIx::Class::Manual>.

=head1 CHADO MODULES COVERED BY THIS PACKAGE

L<Bio::Chado::Schema::CellLine>

L<Bio::Chado::Schema::Companalysis>

L<Bio::Chado::Schema::Composite>

L<Bio::Chado::Schema::Contact>

L<Bio::Chado::Schema::Cv>

L<Bio::Chado::Schema::Expression>

L<Bio::Chado::Schema::General>

L<Bio::Chado::Schema::Genetic>

L<Bio::Chado::Schema::Library>

L<Bio::Chado::Schema::Mage>

L<Bio::Chado::Schema::Map>

L<Bio::Chado::Schema::Organism>

L<Bio::Chado::Schema::Phenotype>

L<Bio::Chado::Schema::Phylogeny>

L<Bio::Chado::Schema::Pub>

L<Bio::Chado::Schema::Sequence>

L<Bio::Chado::Schema::Stock>

=head1 ADDITIONAL METHODS

=head2 merge_schemas

  Usage   : my $s = Bio::Chado::Schema
                      ->merge_with( 'Bio::Chado::Schema',
                                      [ 'Foo', 'Bar', 'Baz' ],
                                       search_path => ...
                                     )
  Returns : a L<DBIx::Class::Schema>-based object,
            containing all the ResultSource objects from the
            listed schema classes
  Args : list of schema class names

  Creates a new DBIC schema namespace and schema class, and
     registers all resultsources in each of multiple DBIC Schema namespaces into a single schema.

=cut

my $merge_increment = 0;
sub merge_schemas {
    my ( $class, @schema_classes ) = @_;

    @schema_classes >= 2
        or croak 'must pass at least 2 schema classes';

    #### make a new schema class on the fly

    # make a unique package name for the merged schema
    my $merged_package = $class.'::auto_merged::'.++$merge_increment;

    # create the merged schema package, with the proper base class
    {
      require DBIx::Class::Schema;
      no strict 'refs';
      @{$merged_package.'::ISA'} = qw( DBIx::Class::Schema );
    }

    # load the sources for each of the given schemas into the new
    # package, checking for collisions in monikers or table names
    my %used_monikers;
    my %used_table_names;
    for my $schema_class (@schema_classes) {
        Module::Load::load( $schema_class )
              unless $schema_class->can('resultset');

        for my $source_moniker ( $schema_class->sources ) {
            my $source_obj = $schema_class->source( $source_moniker );

            # croak for any collisions in source monikers
            $used_monikers{$source_moniker}
                and croak "both $schema_class and $used_monikers{$source_moniker} "
                        . "have moniker $source_moniker, cannot merge";
            $used_monikers{$source_moniker} = $schema_class;

            # warn about any collisions in table names
            if( $source_obj->isa('DBIx::Class::ResultSource::Table') ) {
                my $table_name = $source_obj->from;

                my $result_class = $source_obj->result_class;
                $used_table_names{$table_name}
                    and carp "WARNING: both $result_class and "
                           . "$used_table_names{$table_name} use table/view "
                           . "$table_name";
                $used_table_names{$table_name} = $result_class;
            }

            # finally, register the resultsource with the target schema
            $merged_package->register_source( $source_moniker, $source_obj );
        }
    }

    return $merged_package;
}


=head1 CONTRIBUTORS

Aureliano Bombarely, <ab782@cornell.edu>

Naama Menda, <nm249@cornell.edu>

=head1 AUTHOR

Robert Buels, <rmb32@cornell.edu>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Boyce Thompson Institute for Plant Research

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


#########################################################################################
##                                                                                     ##
## NOTE: The documentation for this package can be found in Bio/Chado/Schema/Util.pod  ##
##                                                                                     ##
## The reason to put this package in the same file than Schema.pm is because if you    ##
## put non DBIx::Class packages under Schema folder, when Module::Find get all the     ##
## dbix classes to load in the schema, the non dbix classes will return an error       ##
##                                                                                     ##
#########################################################################################

package Bio::Chado::Schema::Util;
use strict;
use Carp::Clan qr/^Bio::Chado::Schema/;


sub create_properties {
    my ($class,  %args) = @_;

    #check for required args
    $args{prop_relation_name} or confess "must provide $_ arg"
      for qw/ row prop_relation_name properties options/;

    my $self  = delete $args{row};
    my $props = delete $args{properties};
    my $opts  = delete $args{options};
    my $prop_relation_name = delete $args{prop_relation_name};

    %args and confess "invalid option(s): ".join(', ', sort keys %args);

    # normalize the props to hashrefs
    foreach (values %$props) {
        $_ = { value => $_ } unless ref eq 'HASH';
    }

    # process opts
    $opts ||= {};
    defined $opts->{cv_name} or confess 'must provide a cv_name in options';
    $opts->{db_name} = 'null'
        unless defined $opts->{db_name};
    $opts->{dbxref_accession_prefix} = 'autocreated:'
        unless defined $opts->{dbxref_accession_prefix};

    my $schema = $self->result_source->schema;

    my $prop_cv = do {
        my $cvrs = $schema->resultset('Cv::Cv');
        my $find_or_create = $opts->{autocreate} ? 'find_or_create' : 'find';
        $cvrs->$find_or_create({ name => $opts->{cv_name}},
                               { key => 'cv_c1' })
            or croak "cv '$opts->{cv_name}' not found and autocreate option not passed, cannot continue";
    };

    my $prop_db; #< set as needed below

    # find/create cvterms and dbxrefs for each of our featureprops,
    # and remember them in %propterms
    my %propterms;
    foreach my $propname (keys %$props) {
        my $existing_cvterm = $propterms{$propname} =
            $prop_cv->find_related('cvterms',
                                   { name => $propname,
                                     is_obsolete => 0,
                                   },
                                   { key => 'cvterm_c1' },
                                  );

        # if there is no existing cvterm for this in the prop table,
        # and we have the autocreate flag set true, then create a
        # cvterm, dbxref, and db for it if necessary
        unless( $existing_cvterm ) {
            $opts->{autocreate}
               or croak "cvterm not found for property '$propname', and autocreate option not passed, cannot continue";

            # look up the db object if we don't already have it, now
            # that we know we need it
            $prop_db ||=
                $self->result_source->schema
                     ->resultset('General::Db')
                     ->find_or_create( { name => $opts->{db_name} },
                                       { key => 'db_c1' }
                                     );

            # find or create the dbxref for this cvterm we are about
            # to create
            my $dbx_acc = $opts->{dbxref_accession_prefix}.$propname;
            my $dbxref =
                $prop_db->search_related( 'dbxrefs',
                                          { accession => $dbx_acc },
                                          { order_by => { -desc => ['version'] } }
                                        )
                                ->first
             || $prop_db->create_related( 'dbxrefs', { accession => $dbx_acc,
                                                               version => 1,
                                                             });

            # look up any definition we might have been given for this
            # propname, so we can insert it if given
            my $def = $opts->{definitions}->{$propname};

            $propterms{$propname} =
                $prop_cv->create_related('cvterms',
                                         { name => $propname,
                                           is_obsolete => 0,
                                           dbxref_id => $dbxref->dbxref_id,
                                           $def ? (definition => $def) : (),
                                         }
                                        );
        }
    }

    my %props;
    while( my ($propname,$propval) = each %$props ) {

        my $data = ref $propval
            ? {%$propval}
            : { value => $propval };

        $data->{type_id} = $propterms{$propname}->cvterm_id;


	# decide whether to skip creating this prop
	my $skip_creation = $opts->{allow_duplicate_values}
            ? 0
            : $self->search_related( $prop_relation_name,
                                     { type_id => $data->{type_id},
                                       value   => $data->{value},
                                     })
                   ->count;


        unless( $skip_creation ) {
            # find highest rank for props of this type
            my $max_rank= $self->search_related( $prop_relation_name,
                                                 { type_id =>$data->{type_id} }
                                               )->get_column('rank')->max;
            $data->{rank} = defined $max_rank ? $max_rank + 1 : 0;

	    $props{$propname} = $self->create_related( $prop_relation_name,
						       $data
                                                     );
	}
    }
    return \%props;
}

###
1;#
###
