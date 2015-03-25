---
layout: post
title: jruby-openssl 0.7 Released!
---
Here's announcing jruby-openssl 0.7. This release should be usable on
AppEngine, and contains many compatibility fixes, see below.

Thanks so much to NaHi (NAKAMURA Hiroshi) for his impressive work on
another jruby-openssl release!

To install the new release, simply run:

    jruby -S gem install jruby-openssl

### Compatibility issues

<pre>
JRUBY-4342      Follow ruby-openssl of CRuby 1.8.7.
JRUBY-4346      Sync tests with tests for ruby-openssl of CRuby 1.8.7.
JRUBY-4444      OpenSSL crash running RubyGems tests
JRUBY-4075      Net::SSH gives OpenSSL::Cipher::CipherError "No message available"
JRUBY-4076      Net::SSH padding error using 3des-cbc on Solaris
JRUBY-4541      jruby-openssl doesn't load on App Engine.
JRUBY-4077      Net::SSH "all authorization methods failed" Solaris -> Solaris
JRUBY-4535      Issues with the BouncyCastle provider
JRUBY-4510      JRuby-OpenSSL crashes when JCE fails a initialise bcprov
JRUBY-4343      Update BouncyCastle jar to upstream version; jdk14-139 -> jdk15-144
</pre>

### Cipher issues

<pre>
JRUBY-4012      Initialization vector length handled differently than in
  MRI (longer IV sequence are trimmed to fit the required)
JRUBY-4473      Implemented DSA key generation
JRUBY-4472      Cipher does not support RC4 and CAST
JRUBY-4577      InvalidParameterException 'Wrong keysize: must be equal to
  112 or 168' for DES3 + SunJCE
</pre>

### SSL and X.509(PKIX) issues

<pre>
JRUBY-4384      TCP socket connection causes busy loop of SSL server
JRUBY-4370      Implement SSLContext#ciphers
JRUBY-4688      SSLContext#ciphers does not accept 'DEFAULT'
JRUBY-4357      SSLContext#{setup,ssl_version=} are not implemented
JRUBY-4397      SSLContext#extra_chain_cert and SSLContext#client_ca
JRUBY-4684      SSLContext#verify_depth is ignored
JRUBY-4398      SSLContext#options does not affect to SSL sessions
JRUBY-4360      Implement SSLSocket#verify_result and dependents
JRUBY-3829      SSLSocket#read should clear given buffer before
  concatenating (ByteBuffer.java:328:in `allocate':
  java.lang.IllegalArgumentException when returning SOAP queries over a
  certain size)
JRUBY-4686      SSLSocket can drop last chunk of data just before inbound
  channel close
JRUBY-4369      X509Store#verify_callback is not called
JRUBY-4409      OpenSSL::X509::Store#add_file corrupts when it includes
  certificates which have the same subject (problem with
  ruby-openid-apps-discovery (github jruby-openssl issue #2))
JRUBY-4333      PKCS#8 formatted privkey read
JRUBY-4454      Loading Key file as a Certificate causes NPE
JRUBY-4455      calling X509::Certificate#sign for the Certificate
  initialized from PEM causes IllegalStateException
</pre>

### PKCS#7 issues

<pre>
JRUBY-4379      PKCS7#sign failed for DES3 cipher algorithm
JRUBY-4428      Allow to use DES-EDE3-CBC in PKCS#7 w/o the Policy Files
  (rake test doesn't finish on JDK5 w/o policy files update)
</pre>

### Misc

<pre>
JRUBY-4574      jruby-openssl deprecation warning cleanup
JRUBY-4591      jruby-1.4 support
</pre>
