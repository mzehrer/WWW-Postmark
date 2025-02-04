#!perl -T

use strict;
use warnings;
use Test::More tests => 9;
use WWW::Postmark;

# generate a new object. The Postmark service provides a special token
# for testing purposes ('POSTMARK_API_TEST').
my $api = WWW::Postmark->new('POSTMARK_API_TEST');

ok($api, 'Got a proper WWW::Postmark object');

# a message that should be successful
my $res;

eval { $res = $api->send(from => 'fake@email.com', to => 'nowhere@email.com', subject => 'A test message.', body => 'This is a test message.'); };

is($res, 1, 'simple sending okay');

# a message that should fail because of wrong token
$api->{token} = 'TEST_TOKEN_THAT_SHOULD_FAIL';

eval { $res = $api->send(from => 'fake@email.com', to => 'nowhere@email.com', subject => 'A test message.', body => 'This is a test message.'); };

like($@, qr/Missing or incorrect API Key header/, 'expected token failure okay');

# a message that should fail because of no body
$api->{token} = 'POSTMARK_API_TEST';

eval { $res = $api->send(from => 'fake@email.com', to => 'nowhere@email.com', subject => 'A test message.'); };

like($@, qr/You must provide a mail body/, 'expected token failure okay');

# a message with both HTML and plain text parts
eval { $res = $api->send(from => 'fake@email.com', to => 'somewhere@email.com', subject => 'A test message with HTML and text', html => '<h1>HTML</h1>', text => 'text'); };
is($res, 1, 'html and text okay');

# a message with multiple recipients that should succeed
eval { $res = $api->send(from => 'Fake Email <fake@email.com>', to => 'nowhere@email.com, Some Guy <dev@null.com>,nullify@domain.com', subject => 'A test message.', body => '<html>An HTML message</html>', cc => 'blackhole@nowhere.com, smackhole@nowhere.com'); };

is($res, 1, 'multiple recipients okay');

# an ssl message that should succeed
$api->{use_ssl} = 1;
eval { $res = $api->send(from => 'Fake Email <fake@email.com>', to => 'nowhere@email.com', subject => 'A test message.', body => '<html>An HTML message</html>'); };

is($res, 1, 'SSL sending okay');

# let's see what happens when we don't provide an API token
$api = WWW::Postmark->new;
ok($api, 'Got a proper WWW::Postmark though haven\'t provided token');
eval { $res = $api->send(from => 'fake@email.com', to => 'nowhere@email.com', subject => 'A test message.', body => 'This is a test message.'); };
like($@, qr/You have not provided a Postmark API token/, 'can\'t send mail since don\'t have API token');

done_testing();
