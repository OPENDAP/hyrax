
# Build the Hyrax Server C++ sources. The intent is to provide an easy
# way to support CLion indexing the C++ sources to streamline use of
# that IDE. jhrg 9/30/22

# sbl   9/30/22

# Build and test. This will compile all the code and should thus set
# up CLion so that all files will be indexed. Continue building even
# if errors are found in the tests - that will index code that would
# otherwise be left out. jhrg 9/30/22
.PHONY: all
all: configured
	$(MAKE) $(MFLAGS) -C libdap4
	$(MAKE) $(MFLAGS) -C libdap4 -k check
	$(MAKE) $(MFLAGS) -C bes
	$(MAKE) $(MFLAGS) -C bes -k check

.PHONY: clean
clean: configured
	$(MAKE) $(MFLAGS) -C libdap4 -k $@
	$(MAKE) $(MFLAGS) -C bes -k $@

.PHONY: hyrax-dependencies
hyrax-dependencies: prefix-set
	$(MAKE) $(MFLAGS) -C $@

clion-setup:
	export prefix="$(shell pwd)/build"; echo $$prefix
	export PATH="$$prefix/bin:$$prefix/deps/bin:$$PATH"; echo $$PATH
	$(MAKE) $(MFLAGS) all
	$(MAKE) $(MFLAGS) check

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

