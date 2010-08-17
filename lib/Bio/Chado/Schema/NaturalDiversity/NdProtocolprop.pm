package Bio::Chado::Schema::NaturalDiversity::NdProtocolprop;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Bio::Chado::Schema::NaturalDiversity::NdProtocolprop - Property/value associations for protocol.

=cut

__PACKAGE__->table("nd_protocolprop");

=head1 ACCESSORS

=head2 nd_protocolprop_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'nd_protocolprop_nd_protocolprop_id_seq'

=head2 nd_protocol_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

The protocol to which the property applies.

=head2 cvterm_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

The name of the property as a reference to a controlled vocabulary term.

=head2 value

  data_type: 'varchar'
  is_nullable: 1
  size: 255

The value of the property.

=head2 rank

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

The rank of the property value, if the property has an array of values.

=cut

__PACKAGE__->add_columns(
  "nd_protocolprop_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "nd_protocolprop_nd_protocolprop_id_seq",
  },
  "nd_protocol_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "cvterm_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "value",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "rank",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("nd_protocolprop_id");
__PACKAGE__->add_unique_constraint("nd_protocolprop_c1", ["nd_protocol_id", "cvterm_id", "rank"]);

=head1 RELATIONS

=head2 cvterm

Type: belongs_to

Related object: L<Bio::Chado::Schema::Cv::Cvterm>

=cut

__PACKAGE__->belongs_to(
  "cvterm",
  "Bio::Chado::Schema::Cv::Cvterm",
  { cvterm_id => "cvterm_id" },
  {
    cascade_copy   => 0,
    cascade_delete => 0,
    is_deferrable  => 1,
    on_delete      => "CASCADE",
    on_update      => "CASCADE",
  },
);

=head2 nd_protocol

Type: belongs_to

Related object: L<Bio::Chado::Schema::NaturalDiversity::NdProtocol>

=cut

__PACKAGE__->belongs_to(
  "nd_protocol",
  "Bio::Chado::Schema::NaturalDiversity::NdProtocol",
  { nd_protocol_id => "nd_protocol_id" },
  {
    cascade_copy   => 0,
    cascade_delete => 0,
    is_deferrable  => 1,
    on_delete      => "CASCADE",
    on_update      => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07001 @ 2010-08-16 23:01:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FJz4ri/HICSXuGBuhe915w


# You can replace this text with custom content, and it will be preserved on regeneration
1;
