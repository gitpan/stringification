#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 54;

use Scalar::Util qw( refaddr );

my $arr = [];
my $arraddr = sprintf "0x%x", refaddr $arr;

sub test_one
{
   my ( $name, $code, $expect ) = @_;

   {
      use stringification;
      my $ret = eval "$code";
      ok( !$@, "$name in use stringification" );

      $expect =~ s/0x/$arraddr/g;
      $expect =~ s/0X/\U$arraddr/g;
      is( $ret, $expect, "$name result" );
   }

   {
      no stringification;
      eval "$code";
      ok( $@, "$name in no stringification" );
   }
}

while( <DATA> ) {
   chomp;
   test_one( map { s/^\s+//; s/\s+$//; $_ } split m{\|}, $_ );
}

__DATA__
ARRAY             | "$arr"              | ARRAY(0x)
ARRAY qq()        | "<$arr>"            | <ARRAY(0x)>
ARRAY post concat | "A" . $arr          | AARRAY(0x)
ARRAY pre concat  | $arr . "B"          | ARRAY(0x)B
ARRAY lc          | lc $arr             | array(0x)
ARRAY lcfirst     | lcfirst $arr        | aRRAY(0x)
ARRAY uc          | uc $arr             | ARRAY(0X)
ARRAY ucfirst     | ucfirst $arr        | ARRAY(0x)
ARRAY quotemeta   | quotemeta $arr      | ARRAY\(0x\)
ARRAY qq(\L)      | "\L$arr"            | array(0x)
ARRAY qq(\l)      | "\l$arr"            | aRRAY(0x)
ARRAY qq(\U)      | "\U$arr"            | ARRAY(0X)
ARRAY qq(\u)      | "\u$arr"            | ARRAY(0x)
ARRAY qq(\Q)      | "\Q$arr"            | ARRAY\(0x\)
ARRAY =~ m//      | $arr =~ m/A/        | 1
split //, ARRAY   | split /Z/, $arr     | 1
join ARRAY, ...   | join $arr, "<", ">" | <ARRAY(0x)>
join ",", ARRAY   | join ",", $arr, 1   | ARRAY(0x),1
