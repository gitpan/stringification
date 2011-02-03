#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 4;
use Test::Fatal;

my $str = "hello";
my $ret;

{
   use stringification;
   
   ok( !exception { $ret = "$str" }, 'string in use stringification' );
   is( $ret, "hello", 'string result' );
}

{
   no stringification;

   ok( !exception { $ret = "$str" }, 'string in no stringification' );
   is( $ret, "hello", 'string result' );
}
