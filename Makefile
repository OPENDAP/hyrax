
# Build the Hyrax Server C++ sources. The intent is to provide an easy
# way to support CLion indexing the C++ sources to streamline use of
# that IDE. jhrg 9/30/22

# sbl   9/30/22

# $@ is the name of the rule's target, 'all' in this case
.PHONY: all
all: prefix-set
	$(MAKE) $(MFLAGS) -C libdap4 $@
	$(MAKE) $(MFLAGS) -C bes $@

# Note that 'make check' for the bes can fail in some ways and for
# this particular 'build' the rest of the tests should be run. That's
# because this is intended to be used for CLion so that it can
# discover all the C++ code in the Hyrax server and having the tests
# indexed is a big plus. jhrg 9/30/22
.PHONY: check
check: prefix-set
	$(MAKE) $(MFLAGS) -C libdap4 $@
	$(MAKE) $(MFLAGS) -C bes -k $@

.PHONY: hyrax-dependencies
hyrax-dependencies: prefix-set
	$(MAKE) $(MFLAGS) -C $@

# If $prefix is not set in the calling shell, exit. 
.PHONY: prefix-set
prefix-set:
	@if test -z "$$prefix"; then \
	echo "The env variable 'prefix' must be set. See README"; exit 1; fi


#	current_dir="$(shell pwd)"
#	current_dir+="/build"
#	$(info    current_dir is ${current_dir})
#	(cd hyrax-dependencies && ${MAKE} prefix=${current_dir})
# 	(cd libdap4 && ${MAKE})
# 	(cd bes && ${MAKE})


#	(cd libdap4 && ${MAKE} check)
#	(cd bes && ${MAKE} check)

