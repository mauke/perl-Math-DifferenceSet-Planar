# Copyright (c) 2019 Martin Becker, Blaubeuren.  All rights reserved.
# This package is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl 02_data.t'

#########################

use strict;
use warnings;
use File::Spec;
use FindBin;

use Test::More tests => 37;
BEGIN { use_ok('Math::DifferenceSet::Planar::Data') };

#########################

local $Math::DifferenceSet::Planar::Data::DATABASE_DIR =
    File::Spec->catfile($FindBin::Bin, 'db');

my $data = Math::DifferenceSet::Planar::Data->new;
isa_ok($data, 'Math::DifferenceSet::Planar::Data');
is($data->max_order, 113);
is($data->count, 40);

my @dbs = Math::DifferenceSet::Planar::Data->list_databases;
is("@dbs", 'pds_40.db pds.db extra.db');

my $extra_path = File::Spec->catfile($FindBin::Bin, 'db', 'extra.db');
$data = Math::DifferenceSet::Planar::Data->new($extra_path);
isa_ok($data, 'Math::DifferenceSet::Planar::Data');
is($data->max_order, 11);
is($data->count, 1);

$data = Math::DifferenceSet::Planar::Data->new('pds.db');
isa_ok($data, 'Math::DifferenceSet::Planar::Data');
is($data->max_order, 9);
is($data->count, 7);

my $rec = $data->get(9);
isa_ok($rec, 'Math::DifferenceSet::Planar::Schema::Result::DifferenceSet');
is($rec->order, 9);
is($rec->base, 3);
is($rec->exponent, 2);
is($rec->modulus, 91);
is($rec->n_planes, 12);
like($rec->deltas, qr/^[0-9]+(?: [0-9]+){7}\z/);

$rec = $data->get(9, qw(modulus n_planes));
isa_ok($rec, 'Math::DifferenceSet::Planar::Schema::Result::DifferenceSet');
ok(!defined $rec->order);
ok(!defined $rec->base);
ok(!defined $rec->exponent);
is($rec->modulus, 91);
is($rec->n_planes, 12);
ok(!defined $rec->deltas);

my $it = $data->iterate(6, 8);
my @ords = ();
my $has_deltas = 1;
while (my $r = $it->()) {
    push @ords, $r->order;
    $has_deltas &&= $r->deltas =~ /^[0-9]+(?: [0-9]+)+\z/;
    last if @ords >= 10;
}
is("@ords", '7 8');
ok($has_deltas);

$it = $data->iterate_properties;
@ords = ();
$has_deltas = 0;
while (my $r = $it->()) {
    push @ords, $r->order;
    $has_deltas ||= $r->deltas;
    last if @ords >= 10;
}
is("@ords", '2 3 4 5 7 8 9');
ok(!$has_deltas);

$it = $data->iterate_properties(4, 7);
@ords = ();
$has_deltas = 0;
while (my $r = $it->()) {
    push @ords, $r->order;
    $has_deltas ||= $r->deltas;
    last if @ords >= 10;
}
is("@ords", '4 5 7');
ok(!$has_deltas);

$it = $data->iterate_properties(6);
@ords = ();
$has_deltas = 0;
while (my $r = $it->()) {
    push @ords, $r->order;
    $has_deltas ||= $r->deltas;
    last if @ords >= 10;
}
is("@ords", '7 8 9');
ok(!$has_deltas);

$it = $data->iterate_properties(undef, 6);
@ords = ();
$has_deltas = 0;
while (my $r = $it->()) {
    push @ords, $r->order;
    $has_deltas ||= $r->deltas;
    last if @ords >= 10;
}
is("@ords", '2 3 4 5');
ok(!$has_deltas);

$it = $data->iterate_properties(8, 6);
@ords = ();
$has_deltas = 0;
while (my $r = $it->()) {
    push @ords, $r->order;
    $has_deltas ||= $r->deltas;
    last if @ords >= 10;
}
is("@ords", '8 7');
ok(!$has_deltas);

