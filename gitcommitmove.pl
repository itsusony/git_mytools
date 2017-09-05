#! /usr/bin/env perl

sub usage {
    print "usage: gitcommitmove.pl TARGET_COMMIT_ID PLACE_COMMIT_ID\n";
    exit 1;
}

my $target_commit = $ARGV[0] or usage;
my $place_commit = $ARGV[1] or usage;

my @ids = grep { defined $_; } map { /^commit (.+)/; $1; } split "\n", `git log`;
my ($idx_target_commit, $idx_place_commit) = (-1, -1);
my $idx = 0;
for (@ids) {
    $idx_target_commit = $idx if $_ eq $target_commit;
    $idx_place_commit = $idx if $_ eq $place_commit;
    $idx++;
}

if (($idx_target_commit > $idx_place_commit) || $idx_target_commit == -1 || $idx_place_commit == 1) {
    die "order error";
}

my @commits;
$idx=0;
for (@ids) {
    if ($idx != $idx_target_commit && $idx < $idx_place_commit) {
        push @commits, $_;
    }
    $idx++;
}

`git reset --hard HEAD~$idx_place_commit`;
`git cherry-pick $target_commit`;

for (0 .. @commits-1) {
    my $commit = $commits[$#commits-$_];
    `git cherry-pick $commit`;
}
