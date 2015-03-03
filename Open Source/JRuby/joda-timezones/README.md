joda-timezones: precompiled timezone data for joda-time
=======================================================

This project provides a simple mechanism for downloading and building a jar
containing timezone data compile for and usable by the joda-time library.

If a project wants to ship a specific version of timezone data, update the
pom.xml file to the timezone data version and package or install the resulting
jar.

The JRuby team has begun publishing these jars for general use as groupId
"org.jruby" and artifactId "joda-timezones".
