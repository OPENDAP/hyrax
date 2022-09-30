
# Build the Hyrax Server C++ sources. The intent is to provide an easy
# way to support CLion indexing the C++ sources to streamline use of
# that IDE. jhrg 9/30/22

# sbl   9/30/22

# $@ is the name of the rule's target, 'all' in this case
.PHONY: all
all: configured
	$(MAKE) $(MFLAGS) -C libdap4 $@
	$(MAKE) $(MFLAGS) -C bes $@

# Note that 'make check' for the bes can fail in some ways and for
# this particular 'build' the rest of the tests should be run. That's
# because this is intended to be used for CLion so that it can
# discover all the C++ code in the Hyrax server and having the tests
# indexed is a big plus. jhrg 9/30/22
.PHONY: check
check: configured
	$(MAKE) $(MFLAGS) -C libdap4 $@
	$(MAKE) $(MFLAGS) -C bes -k $@

.PHONY: hyrax-dependencies
hyrax-dependencies: prefix-set
	$(MAKE) $(MFLAGS) -C $@

# If $prefix is not set in the calling shell, exit.
# If the PATH is not set correctly, exit.
.PHONY: prefix-set
prefix-set:
	@test -n "$$prefix" \
	 || (echo "The env variable 'prefix' must be set. See README"; exit 1)
	@printenv PATH | grep -q $$prefix/bin \
	 || (echo "Did not find $$prefix/bin in PATH"; exit 1)
	@printenv PATH | grep -q $$prefix/deps/bin \
	 || (echo "Did not find $$prefix/deps/bin in PATH"; exit 1)

.PHONY: configured
configured: prefix-set
	@test -f libdap4/Makefile \
	 || (echo "Run ./configure --prefix=... in libdap4 (Makefile missing)"; exit 1)
	@test -f bes/Makefile \
	 || (echo "Run ./configure --prefix=... in bes (Makefile missing)"; exit 1)

#	current_dir="$(shell pwd)"
#	current_dir+="/build"
#	$(info    current_dir is ${current_dir})
#	(cd hyrax-dependencies && ${MAKE} prefix=${current_dir})
# 	(cd libdap4 && ${MAKE})
# 	(cd bes && ${MAKE})


#	(cd libdap4 && ${MAKE} check)
#	(cd bes && ${MAKE} check)

