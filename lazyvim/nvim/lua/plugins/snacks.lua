return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      -- Directories the projects picker scans for repos.
      -- Override with the NVIM_DEV_DIR environment variable (single dir);
      -- otherwise fall back to per-OS defaults. Using ~ (expanded per user)
      -- keeps any absolute path / username out of this file so it is safe to
      -- commit publicly. Missing dirs are simply ignored by the picker.
      local dev = vim.env.NVIM_DEV_DIR
      local dirs
      if dev and dev ~= "" then
        dirs = { dev }
      elseif vim.fn.has("win32") == 1 then
        -- Match the real directory casing exactly. Windows is case-insensitive
        -- for lookups, but the picker dedupes projects by path string, so a
        -- casing mismatch with the `recent` source shows the repo twice.
        dirs = { vim.fn.expand("~/Downloads/Repos") }
      else
        dirs = {
          vim.fn.expand("~/Documents/dev/repos"),
          vim.fn.expand("~/Documents/repos"),
        }
      end

      opts.picker = opts.picker or {}
      opts.picker.sources = opts.picker.sources or {}
      opts.picker.sources.projects = {
        dev = dirs,
        patterns = { ".git" },
        max_depth = 2,
        recent = true,
      }
    end,
  },
}
