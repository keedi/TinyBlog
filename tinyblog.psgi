use strict;
use warnings;

use TinyBlog;

my $app = TinyBlog->apply_default_middlewares(TinyBlog->psgi_app);
$app;

