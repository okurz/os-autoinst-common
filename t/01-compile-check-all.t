# Copyright SUSE LLC
# SPDX-License-Identifier: GPL-2.0-or-later

use Test::Most;
# We need :no_end_test here because otherwise it would output a no warnings
# test for each of the modules, but with the same test number
use Test::Warnings qw(:no_end_test :report_warnings);
use FindBin '$Bin';
use lib "$Bin/lib";
use OpenQA::Test::TimeLimit '400';
use File::Which;

chdir "$Bin/..";

use Test::Compile;

my $test = Test::Compile->new();
my @files;

if (-d '.git' and which('git')) {
    my $root = qx{git rev-parse --show-toplevel};
    chomp $root;
    $root .= '/';
    my @all_git_files = qx{git ls-files};
    chomp @all_git_files;
    @files = map { $root . $_ } @all_git_files;
}
else {
    @files = ($test->all_pm_files('.'), $test->all_pl_files('.'));
}

@files = grep { /\.(?:pm|pl|t)$/ } @files;

plan tests => scalar @files;

for my $file (@files) {
    my $ok = $file =~ /\.pm$/ ? $test->pm_file_compiles($file) : $test->pl_file_compiles($file);
    ok $ok, "Syntax check $file";
}
