#! /usr/bin/perl

use Data::Dumper;
use XML::Simple;
use URI::Escape;

my $followup = 0;
my $cproblem = '';
my %problems;
my %subpackages;

#system("osc api /build/openSUSE:Factory/standard/x86_64/_builddepinfo > /tmp/builddep");
my $xml = XMLin("/tmp/builddep", ForceArray => ['package', 'pkgdep', 'subpkg']);

for my $package (values %{$xml->{package}}) {
  for my $sp (@{$package->{subpkg}}) {
    $subpackages{$sp} = $package->{source};
  }
}

while ( <STDIN> ) {
  chomp;

  if ( m/^can't install (.*)\-[^-]*\-[^-]*\.(i586|x86_64|noarch):/) {
    $cproblem = $1;
    $cproblem =~ s/kmp-([^-]*)/kmp-default/;
    $cproblem = $subpackages{$cproblem} if (defined $subpackages{$cproblem});
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

my $api="/build/openSUSE:Factory/_result?repository=standard";
for my $problem (sort keys %problems) {
 $api = $api . "&package=" . uri_escape($problem);
}
open(RESULT, "osc api $api|");
@result = <RESULT>;
my $results = XMLin(join('', @result));
close(RESULT);
my %fails;

for my $result (@{$results->{result}}) {
for my $package (@{$result->{status}}) {
  if ($package->{code} eq 'failed' || $package->{code} eq 'unresolvable' ) {
     $fails{$package->{package}} = 1;
  }
}
}

for my $problem (sort keys %problems) {
  next if (defined $fails{$problem});
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

