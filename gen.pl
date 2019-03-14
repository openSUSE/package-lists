#! /usr/bin/perl

use File::Basename;
use File::Path qw(make_path);

my $file = $ARGV[0] || die 'need file';
my $arch = $ARGV[1] || die 'need arch';
my $proj = $ARGV[2] || 'Factory';
my $repo = $ARGV[3] || 'standard';

sub read_file_recursively($) {
  my $tfile = shift;
  my @lines;
  open(my $fh, '<', $tfile);

  while ( <$fh> ) {
    chomp;

    my $line = $_;

    if ($line =~ m/#.*!$arch\b.*$/) {
      next;
    }
    if ($line =~ m/^#INCLUDE\s*(\S+)/) {
      push(@lines, "\n# from $1\n");
      push(@lines, read_file_recursively(dirname($file) . "/" . $1));
      push(@lines, "# end $1\n\n");
      next;
    }
    if ($line =~ m/#.*!/) {
      # cut comments at the end of the line
      $line = (split/#.*!/, $line)[0];
    }

    push(@lines, $line);
  }

  close($fh);

  return @lines;
}

open(OUT, ">t.$proj-$repo-$arch");
print OUT "repo openSUSE:$proj-$repo-$arch 0 solv trees/openSUSE:$proj-$repo-$arch.solv\n";
for my $line (read_file_recursively($file)) {
  print OUT "$line\n";
}
print OUT "result transaction,problems,recommended <inline>\n";
close(OUT);

open(TS, "testsolv -r t.$proj-$repo-$arch|");
my %installs;
my %suggested;
my $ret = 0;
while ( <TS> ) {
#  next if /^recommended/;
  if (/^(suggested|recommended) (.*)-[^-]+-[^-]+\.(\S*)@/) {
    $suggested{$2} = 1;
    next;
  }
  if (/^(install) (.*)-[^-]+-[^-]+\.(\S*)@/) {
	$installs{$2} = 1;
  } else {
	print "$file: $_";
        $ret = 1;
  }
}
exit(1) if ($ret);

close(TS);
make_path(dirname("output/$file"));
open(OUT, ">", "output/$file.$arch.list");
for my $pkg (sort keys %installs) {
  print OUT "$pkg\n";
}
close(OUT);
open(OUT, ">", "output/$file.$arch.suggests");
for my $pkg (sort keys %suggested) {
  print OUT "job install name $pkg [weak]\n";
}
close(OUT);
