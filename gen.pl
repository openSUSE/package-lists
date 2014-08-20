#! /usr/bin/perl

use File::Basename;

my $file = $ARGV[0] || die 'need file';
my $arch = $ARGV[1] || die 'need arch';
my $proj = $ARGV[2] || 'Factory';

sub read_file_recursively($) {
  my $tfile = shift;
  my @lines;
  open(my $fh, '<', $tfile);

  while ( <$fh> ) {
    chomp;

    my $line = $_;

    if ($line =~ m/#.*!$arch/) {
      next;
    }

    if ($line =~ m/^#INCLUDE\s*(\S+)/) {
      push(@lines, "\n# from $1\n");
      push(@lines, read_file_recursively(dirname($file) . "/" . $1));
      push(@lines, "# end $1\n\n");
      next;
    }

    push(@lines, $line);
  }

  close($fh);

  return @lines;
}

open(OUT, ">t");
print OUT "repo openSUSE:$proj-standard-$arch 0 solv trees/openSUSE:$proj-standard-$arch.solv\n";
for my $line (read_file_recursively($file)) {
  print OUT "$line\n";
}
print OUT "result transaction,problems,recommended <inline>\n";
close(OUT);

open(TS, "testsolv -r t|");
my @installs;
my @suggested;
my $ret = 0;
while ( <TS> ) {
  next if /^recommended/;
  if (/^suggested (.*)-[^-]+-[^-]+\.(\S*)@/) {
    push(@suggested, $1);
    next;
  }
  if (/^install (.*)-[^-]+-[^-]+\.(\S*)@/) {
	push(@installs, $1);
  } else {
	print "$file: $_";
        $ret = 1;
  }
}
exit(1) if ($ret);

close(TS);
open(OUT, ">", "output/$file.$arch.list");
for my $pkg (sort @installs) {
  print OUT "$pkg\n";
}
close(OUT);
open(OUT, ">", "output/$file.$arch.suggests");
for my $pkg (sort @suggested) {
  print OUT "job install name $pkg [weak]\n";
}
close(OUT);
