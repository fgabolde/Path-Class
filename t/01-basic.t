BEGIN {
  $^O = 'Unix'; # Test in Unix mode
}

use Test;
use strict;
use Path::Class qw(file dir);
use File::Spec;
use Cwd;

plan tests => 39;
ok(1);

my $file1 = Path::Class::File->new('foo.txt');
ok $file1, 'foo.txt';
ok $file1->is_absolute, '';
ok $file1->dir, '.';

my $file2 = file('dir', 'bar.txt');
ok $file2, 'dir/bar.txt';
ok $file2->is_absolute, '';
ok $file2->dir, 'dir';

my $dir = dir('tmp');
ok $dir, 'tmp';
ok $dir->is_absolute, '';

my $dir2 = dir('/tmp');
ok $dir2, '/tmp';
ok $dir2->is_absolute, 1;

my $cat = file($dir, 'foo');
ok $cat, 'tmp/foo';
$cat = $dir->file('foo');
ok $cat, 'tmp/foo';
ok $cat->dir, 'tmp';

$cat = file($dir2, 'foo');
ok $cat, '/tmp/foo';
$cat = $dir2->file('foo');
ok $cat, '/tmp/foo';
ok $cat->isa('Path::Class::File');
ok $cat->dir, '/tmp';

$cat = $dir2->subdir('foo');
ok $cat, '/tmp/foo';
ok $cat->isa('Path::Class::Dir');

my $file = file('/foo//baz/./foo')->cleanup;
ok $file, '/foo/baz/foo';
ok $file->dir, '/foo/baz';

{
  my $dir = dir('/foo/bar/baz');
  ok $dir->parent, '/foo/bar';
  ok $dir->parent->parent, '/foo';
  ok $dir->parent->parent->parent, '/';
  ok $dir->parent->parent->parent->parent, '/';

  $dir = dir('foo/bar/baz');
  ok $dir->parent, 'foo/bar';
  ok $dir->parent->parent, 'foo';
  ok $dir->parent->parent->parent, '.';
  ok $dir->parent->parent->parent->parent, '..';
  ok $dir->parent->parent->parent->parent->parent, '../..';
}

{
  # Special cases
  ok dir(''), '/';
  ok dir(), '.';
  ok dir('', 'var', 'tmp'), '/var/tmp';
  ok dir()->absolute, File::Spec->canonpath(Cwd::cwd);
}

{
  my $file = file('/tmp/foo/bar.txt');
  ok $file->relative('/tmp'), 'foo/bar.txt';
  ok $file->relative('/tmp/foo'), 'bar.txt';
  ok $file->relative('/tmp/'), 'foo/bar.txt';
  ok $file->relative('/tmp/foo/'), 'bar.txt';
}
