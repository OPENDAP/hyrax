[![NSF-1740627](https://img.shields.io/badge/NSF-1740627-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1740627)

This is README describes how to use the very simple scripts here to
clone and build Hyrax. The scripts can also be used to set up a kind
of poor-man's nightly, or CI, build.

The scripts in this repo are not the only way to build Hyrax, however.
You can easily clone the three main repos and build them using the
normal autotools (for libdap and BES) and ant (for the OLFS) process.
Because Hyrax is a bit more complicated than a simple webapp, the
process has a few more steps, but it's certainly possible to build the
server in under 10 minutes on a typical laptop. For instructions see:

      http://docs.opendap.org/index.php/Hyrax_GitHub_Source_Build

Here's how to build using the scripts contained in this project. First,
the short version, which will work if you have a machine that meets the 
prerequisites:

    source spath.sh 

    ./hyrax_clone.sh

    ./hyrax_build.sh

The longer version:

0. You need a Linux/OSX/Unix computer that can compile C, C++ and
Java. Most of the requirements are fairly plain, with the exception
that you'll need a recent copy of bison and flex and newer versions of
the autotools software. Since CentOS/RedHat comes with 'yum' and the
yum command syntax is fairly concise, I'll use it as shorthand for the
packages you need (with the advantage that some users can cut and
paste in a plain machine and get the packages installed very quickly):

yum install java-1.7.0-openjdk java-1.7.0-openjdk-devel ant git \
 gcc-c++ flex bison openssl-devel libuuid-devel readline-devel \
 zlib-devel libjpeg-devel libxml2-devel curl-devel ant-junit

Then download and build the latest versions of autoconf, automake and
libtool. Those can be found at:

    http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz
    http://ftp.gnu.org/gnu/automake/automake-1.14.1.tar.gz
    http://ftp.gnu.org/gnu/libtool/libtool-2.4.2.tar.gz

and are very easy to build.

1. Set up the 'prefix' and 'PATH' environment variables in the shell
you're using. Use 'source spath.sh' to do this. This will set the
'prefix' environment variable to `pwd`/build and add
`pwd`/build/bin to the front of PATH so that libdap, BES and the
various modules/handlers for the BES can find the dependencies once
they are built.

    source spath.sh
 
2. Now clone all of the source repos for Hyrax using the
'hyrax_clone.sh' script. This will take a while, but it's not too bad.
The script takes some options: verbose (-v), dry run (-n) and No
Dependencies (-D). The default will clone all of the repos including
the hyrax-dependencies. If you're building on CentOS and want to use
EPEL for the deps, use -D. Using -D will suppress cloning the
hyrax-dependencies repo. This script assumes you want to clone the BES
and load all of the modules/handlers that normally are released with
Hyrax. If thats not what you want to do, go to the web page described
earlier and build the code by hand, which will give you complete
control over what software is cloned from git, how it is built and so
on.

    ./hyrax_clone.sh -v

3. Build the code using the 'hyrax_build.sh' script. It takes various
options: verbose (-v), dry run (-n) and some others; -h provides some
help. This script will build all of the code, including the
hyrax-dependencies if they are present (so this script works
'intelligently' in conjunction with the hyrax_clone.sh script). The -c
and -d options run the 'clean' and 'distcheck' targets of the Makefiles
and are useful for automated builds.

    ./hyrax_build.sh -v

4. Test the server. The hyrax_build.sh script will install the server
in $prefix/build. If it completes successfully, the server should be
built and installed.

To start the server, first start the BES and then the OLFS. Note that
the besctl utility is on your PATH since you sourced 'spath.sh' and
therefore have $prefix/bin on your PATH

    besctl start

    ./build/apache-tomcat-7.0.57/bin/startup.sh

Now goto http://localhost:8080/opendap and you should see the server
and the test data that is distributed with it. If not here are some things
to check:

* Is the BES running? There should be several processes associated
with the BES and you can see them using 'besctl pids'. If not, look at
the BES log file ($prefix/build/var/bes.log) for error messages. 

* Is tomcat running? Use 'ps -ef | grep tomcat' to see if it is. If
not, look in $prefix/bui.d apache-tomcat-*/logs/catalins.out for clues
as to why.

* Are you working on a machine that has ports like 8080 blocked? Hyrax
needs an open port for Tomcat, nominally 8080, plus an open port for
the BES. By default the BES uses port 10022.

For more detailed information on Hyrax and its configuration, see:

    http://docs.opendap.org/index.php/Documentation

-----------------------------------------------------------------------

Notes:

To clean the repo, returning it to it's initial state, use:

    rm -rf bes build hyrax-dependencies/ libdap logs olfs \
     bes.log libdap.log olfs.log

If one of the distcheck targets failed, then the build dir that 
it left behind will not be writable by anyone, so chmod 755 or sudo
to remove it.
