-- Loads every font known to luaotfload once so that luaotfload writes its
-- per-font cache (texmf-var/luatex-cache/generic/fonts/otl/<font>.luc) into
-- the image. Without this, the first lualatex run in each fresh container
-- creates those files, and latexmk takes the new files as a reason to rerun
-- (https://github.com/dante-ev/docker-texlive/issues/51).
--
-- Fonts are only defined, never typeset, so fonts with unusual glyph sets
-- (e.g. NotoEmoji) do not abort the run. WORKER/WORKERS partition the index
-- so several lualatex processes can share the work; each process keeps all
-- fonts it loaded in memory, so more workers also means less memory per run.
local maps = luaotfload.aux.read_font_index().mappings
local worker = tonumber(os.getenv("WORKER") or "0")
local workers = tonumber(os.getenv("WORKERS") or "1")
local say = function (s) texio.write_nl("term and log", s) end

local loaded, failed = 0, 0
for i, m in ipairs(maps) do
  if i % workers == worker then
    local spec = "file:" .. m.basename
    -- The index counts subfonts of a TrueType collection from 1, the
    -- file: syntax from 0.
    if m.subfont then spec = spec .. "(" .. (m.subfont - 1) .. ")" end
    local ok, result = pcall(fonts.definers.read, spec, 655360)
    if ok and result then
      loaded = loaded + 1
    else
      failed = failed + 1
      say("WARMFAIL " .. spec .. ": " .. tostring(result))
    end
  end
end
say(string.format("WARMDONE worker %d/%d: loaded %d fonts, %d failed, %d fonts in index",
  worker, workers, loaded, failed, #maps))
