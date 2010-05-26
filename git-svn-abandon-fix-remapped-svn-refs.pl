#!/usr/bin/perl

open (MAP, "<".$ENV{"COMMIT_MAP"});
my %revmap;
while (defined ($line = <MAP>)) {
    chomp $line;
    if ($line =~ /^([^ ]*) (.*)$/) {
        $revmap{"$1"} = "$2";
    }
}
close (MAP);
my $svn_ref_dir_path=$ENV{"SVN_REF_DIR"};
opendir( SVN_REF_DIR, $svn_ref_dir_path) || die "cannot open $svn_ref_dir_path";
while (my $file = readdir SVN_REF_DIR) {
    next unless (-f "$svn_ref_dir_path/$file");
    open (FILE, "<$svn_ref_dir_path/$file");
    my $orig_commit = <FILE>;
    chomp $orig_commit;
    my $new_commit = $revmap{"$orig_commit"};
    if ( ! defined($new_commit) ) {
        print "Failed to find remapping for svn rev $file with original commit id ".$orig_commit."\n";
    } else {
	print "$file -> $file ($orig_commit -> $new_commit)\n";
	close(FILE);
	open (FILE, ">$svn_ref_dir_path/$file");
        print FILE $new_commit."\n";
    }
    close(FILE);
}
closedir (SVN_REF_DIR);
