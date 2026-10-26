# Smoke test for mdx.nvim: renders mdx.nvim/tests/fixture.md headlessly, with and without render-markdown
.PHONY: test-md
test-md:
	@for mode in integrated standalone; do \
		MDX_MODE=$$mode nvim --headless -n -i NONE -u NONE -c "luafile mdx.nvim/tests/smoke.lua" || exit 1; \
	done
