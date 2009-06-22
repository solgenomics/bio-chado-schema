package Chado::Schema::Stock::StockpropPub;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("stockprop_pub");
__PACKAGE__->add_columns(
  "stockprop_pub_id",
  {
    data_type => "integer",
    default_value => "nextval('stockprop_pub_stockprop_pub_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "stockprop_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "pub_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
);
__PACKAGE__->set_primary_key("stockprop_pub_id");
__PACKAGE__->add_unique_constraint("stockprop_pub_pkey", ["stockprop_pub_id"]);
__PACKAGE__->add_unique_constraint("stockprop_pub_c1", ["stockprop_id", "pub_id"]);
__PACKAGE__->belongs_to(
  "stockprop_id",
  "Chado::Schema::Stock::Stockprop",
  { stockprop_id => "stockprop_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-06-20 19:31:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:X29m3soCFPbTGxtiiYxysQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;