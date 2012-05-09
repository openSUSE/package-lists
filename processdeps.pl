#! /usr/bin/perl

use Data::Dumper;

my $followup = 0;
my $cproblem = '';
my %problems;

while ( <STDIN> ) {
  chomp;

  if ( m/^can't install (.*)\-[^-]*\-[^-]*\.(i586|x86_64|noarch):/) {
    $cproblem = $1;
    $cproblem =~ s/kmp-([^-]*)/kmp-%flavor/;
    $followup = 0;
    next;
  }

  $followup = 1 if ($_ =~ m/none of the providers can be installed/);
  
  # not interesting for me
  next if ( m/  \(we have /);
  next if ($followup);

  # very thin ice here
  s,\(\)\(64bit\),,;

  s,(needed by [^ ]*)\-[^-]*\-[^-]*\.(i586|x86_64|noarch)$,$1,;

  $problems{$cproblem}->{$_} = 1;


}

for my $problem (sort keys %problems) {
  print "can't install $problem:\n";
  my @lines = keys %{$problems{$problem}};
  my $count = 0;
  for my $line (sort @lines) {
    print "$line\n";
    $count = $count + 1;
    if ($count > 3 && @lines > 6) {
      print "... " . (int(@lines) - $count) . " more problems\n";
      last;
    }
  }
}

