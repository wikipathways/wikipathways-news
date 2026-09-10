# Builds every issue (vol<N>/issue<M>/) in this repository. Shared
# resources used by every issue - WPnews.sty, WPicon.png, resources/ - live
# here at the root and are referenced by each issue's own Makefiles via
# relative paths (see TECHNOLOGY.md). template/ is not built by this
# Makefile: it is not a real issue, only a starting point to copy into a
# new vol<N>/issue<M>/ folder (see README.md).
ISSUES := $(wildcard vol*/issue*)
TEXMFHOME := $(shell kpsewhich -var-value TEXMFHOME)

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

# One-time per machine, before the first build: installs the vendored
# Poppins font (resources/fonts/) into this user's TeX Live tree and
# reindexes lualatex's font database, so WPnews.sty's \wppoppins (used for
# the masthead and article/editorial titles) can find "Poppins" by name.
# Needed because loading it directly from resources/fonts/ by file path
# instead makes lualatex intermittently fail to embed it once a full
# issue's articles are all combined into one newsletter.pdf; Linux
# Libertine avoids the same problem by coming from the CTAN `libertine`
# package, which is already installed and indexed this same way.
install-fonts:
	mkdir -p $(TEXMFHOME)/fonts/truetype/public/poppins
	cp resources/fonts/Poppins-*.ttf resources/fonts/OFL_Poppins.txt \
	  $(TEXMFHOME)/fonts/truetype/public/poppins/
	mktexlsr $(TEXMFHOME)
	luaotfload-tool --update

.PHONY: all clean distclean install-fonts
