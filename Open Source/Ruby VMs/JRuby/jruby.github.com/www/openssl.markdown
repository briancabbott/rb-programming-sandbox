---
title: JRuby Builtin OpenSSL Support
layout: main
---
# JRuby Builtin OpenSSL Support

JRuby historically has not shipped with a fully functional openssl
module due to cryptographic export restrictions. However, in order to
support Rails 2.0 out of the box, we implemented a limited subset of
openssl that implements <tt>OpenSSL::HMAC</tt> and
<tt>OpenSSL::Digest</tt>.

However, this breaks programs that use <tt>require 'openssl'</tt> as a
test for whether openssl is available or not.
[Soap4r](http://dev.ctor.org/soap4r) is one such program. In order to
support this behavior, simply add

    require 'jruby/openssl/gem_only'

at the start of your program, and requiring openssl will revert to raising a load error.

See also [JRUBY-1808](http://jira.codehaus.org/browse/JRUBY-1808) for a discussion on this feature. 