-- Custom filter (not part of the BioHackrXiv resources): extracts the
-- "References" heading and the citeproc-generated bibliography Div
-- (id "refs") out of the document body and stores them in metadata as
-- `wpreferences`, so pandoc.template can place them after the
-- DOI/author-affiliation block instead of wherever the "# References"
-- heading happens to sit in art.md. Run this after insert-cito-in-ref.lua
-- so the CiTO annotations are already present on the entries it moves.
function Pandoc(doc)
  local kept = pandoc.List({})
  local refs = pandoc.List({})
  local blocks = doc.blocks
  local i = 1
  while i <= #blocks do
    local b = blocks[i]
    if b.t == "Header" and b.identifier == "references" then
      refs:insert(b)
      i = i + 1
      local nxt = blocks[i]
      if nxt and nxt.t == "Div" and nxt.identifier == "refs" then
        refs:insert(nxt)
        i = i + 1
      end
    else
      kept:insert(b)
      i = i + 1
    end
  end
  doc.blocks = kept
  if #refs > 0 then
    doc.meta.wpreferences = pandoc.MetaBlocks(refs)
  end
  return doc
end
