-- Sets the `haswpcitations` metadata field to true when the document
-- contains at least one citation, so resources/pandoc.template can emit
-- \printbibliography only for articles that actually cite something (a
-- reference section is optional - an article with no citations should have
-- none, on both the LaTeX and the Markdown/pandoc authoring route).
local found = false

return {
  {
    Cite = function(c)
      found = true
      return c
    end,
  },
  {
    Pandoc = function(doc)
      if found then
        doc.meta.haswpcitations = true
      end
      return doc
    end,
  },
}
