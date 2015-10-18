use File::Temp qw/tempdir/;
use File::Basename;

my $script_dir;

BEGIN {
    ($script_dir) = $0 =~ m-(.*)/-;
    $script_dir ||= '.';
    unshift @INC, $script_dir;
    unshift @INC, "osc-plugin-factory/";
}

require CreatePackageDescr;

my $project = $ARGV[0];
my $repo = $ARGV[1];
my $arch = $ARGV[2];
my $api = $ARGV[3] // "api.opensuse.org";

$repodir = "/var/cache/repo-checker/repo-$project-$repo-$arch";
mkdir($repodir);
my $tdir = tempdir();
my $pfile = "$tdir/packages";    # the filename is important ;(

unless ($ENV{'NO_BSMIRROR'}) {
    die "bs_mirror of $project/$repo/$arch failed" if system(
	"osc-plugin-factory/bs_mirrorfull --nodebug https://$api/public/build/$project/$repo/$arch/ $repodir"
    );
}

my @rpms = glob("$repodir/*.rpm");

open( PACKAGES, ">", $pfile ) || die "can not open $pfile";
print PACKAGES "=Ver: 2.0\n";

foreach my $package (@rpms) {
    my $out = CreatePackageDescr::package_snippet($package);
    print PACKAGES CreatePackageDescr::package_snippet($package);
}
close(PACKAGES);

system("susetags2solv < $pfile > trees/$project-$repo-$arch.solv");
unlink($pfile);
rmdir(dirname($pfile));
