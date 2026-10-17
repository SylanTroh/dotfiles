-- LaTeX snippets
local ls = require('luasnip')
local s, t, i, f = ls.snippet, ls.text_node, ls.insert_node, ls.function_node
local fmta = require('luasnip.extras.fmt').fmta
local line_begin = require('luasnip.extras.conditions.expand').line_begin

-- Environments
local function env(trig, name, dscr, with_opt)
  local head = with_opt and '\\begin{' .. name .. '}[<>]' or '\\begin{' .. name .. '}'
  local nodes = with_opt and { i(1), i(0) } or { i(0) }
  return s({ trig = trig, dscr = dscr }, fmta(head .. '\n<>\n\\end{' .. name .. '}', nodes),
    { condition = line_begin })
end

-- Text with fields between
local function wrap(trig, dscr, ...)
  local parts, nodes = { ... }, {}
  for n, part in ipairs(parts) do
    table.insert(nodes, t(part))
    if n < #parts then table.insert(nodes, i(n)) end
  end
  table.insert(nodes, i(0))
  return s({ trig = trig, dscr = dscr }, nodes)
end

local snippets = {
  env('prop', 'proposition', 'Begin Proposition Environment'),
  env('def', 'definition*', 'Begin Definition Environment', true),

  s({ trig = 'today', dscr = 'Date' }, f(function() return os.date('%F') end)),

  wrap('\\{', 'Set', '\\{', '\\}'),
  wrap('\\left(', 'Left-Right(', '{\\left( ', ' \\right)}'),
  wrap('\\left{', 'Left-Right{', '{\\left\\{ ', ' \\right\\}}'),
  wrap('\\left[', 'Left-Right[', '{\\left[ ', ' \\right]}'),
  wrap('\\left<', 'Left-Right<', '{\\left< ', ' \\right>}'),
  wrap('\\inp', 'Inner Product', '\\inp{', '}{', '}'),
  wrap('\\abs', 'Absolute Value', '{\\abs{', '}}'),
  wrap('\\norm', 'Norm', '{\\norm{', '}}'),
  wrap('\\lim', 'Limits', '{\\lim\\limits_{', '} ', '}'),
  wrap('\\sum', 'Summation', '{\\sum\\limits_{', '}^{', '} ', '}'),
  wrap('\\int', 'Integral', '{\\int\\limits_{', '}^{', '} ', ' \\d ', '}'),
  wrap('\\frac', 'Fraction', '\\frac{', '}{', '}'),
  wrap('\\conj', 'Complex Conjugate', '\\conj{', '}'),
  wrap('\\bigcupdot', 'Disjoint Union', '\\hspace{5pt}\\cdot\\hspace{-10pt}\\bigcup_{', '}^{', '}'),
}

local autosnippets = {
  env('prob', 'problem', 'Begin Problem Environment'),
  env('theo', 'theorem', 'Begin Theorem Environment', true),
  env('lemma', 'lemma', 'Begin Lemma Environment'),
  env('coro', 'corollary', 'Begin Corollary Environment'),
  env('proof', 'proof', 'Begin Proof Environment'),

  -- Inline Math
  s({ trig = 'mk', dscr = 'Math' }, {
    t('$'), i(1), t('$'),
    f(function(args)
      local c = (args[1][1] or ''):sub(1, 1)
      return (c == '' or c:match('[,%.%?%- ]')) and '' or ' '
    end, { 2 }),
    i(2),
  }),
  s({ trig = 'dm', dscr = 'Display Math' }, fmta('\\[\n<>\n\\] <>', { i(1), i(0) })),
}

return snippets, autosnippets
