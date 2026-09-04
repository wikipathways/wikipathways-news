# Builds every issue (vol<N>/issue<M>/) in this repository. Shared
# resources used by every issue - WPnews.sty, WPicon.png, resources/ - live
# here at the root and are referenced by each issue's own Makefiles via
# relative paths (see TECHNOLOGY.md). template/ is not built by this
# Makefile: it is not a real issue, only a starting point to copy into a
# new vol<N>/issue<M>/ folder (see README.md).
ISSUES := $(wildcard vol*/issue*)

all:
	@for d in $(ISSUES); do \
	  echo "==> $$d"; \
	  $(MAKE) -C $$d || exit 1; \
	done

clean:
	@for d in $(ISSUES); do \
	  $(MAKE) -C $$d clean; \
	done

distclean:
	@for d in $(ISSUES); do \
	  $(MAKE) -C $$d distclean; \
	done

.PHONY: all clean distclean
