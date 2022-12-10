#!/usr/bin/env raku

# See "GNU Scientific Library" manual Chapter 33 Series Acceleration, Paragraph 33.3

use lib 'lib';
use Math::Libgsl::Series;

constant \N = 20;
constant \zeta_2 = π * π / 6;

my Math::Libgsl::Series $s .= new: N;

my @array := Array[Num].new;
(^N).map: -> $n { my $np1 = $n + 1; @array[$n] = 1e0 / ($np1 * $np1) }

my ($sum, $err, $used) = $s.levin-accel: @array;

printf("term-by-term sum = %.16f using %d terms\n", @array.sum, N);
printf("term-by-term sum = %.16f using %u terms\n", $s.w.sum_plain, $s.w.terms_used);
printf("exact value      = %.16f \n", zeta_2);
printf("accelerated sum  = %.16f using %u terms\n", $sum, $s.w.terms_used);
printf("estimated error  = %.16f \n", $err);
printf("actual error     = %.16f \n", $sum - zeta_2);
