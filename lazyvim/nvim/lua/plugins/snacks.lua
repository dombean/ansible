return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      -- Directory the projects picker scans for repos.
      -- Override with the NVIM_DEV_DIR environment variable; otherwise fall
      -- back to a per-OS default. Using ~ (expanded per user) keeps any
      -- absolute path / username out of this file so it is safe to commit.
      local dev = vim.env.NVIM_DEV_DIR
      if not dev or dev == "" then
        if vim.fn.has("win32") == 1 then
          dev = vim.fn.expand("~/Downloads/Repos")
        else
          dev = vim.fn.expand("~/Documents/dev/repos")
        end
      end

      opts.picker = opts.picker or {}
      opts.picker.sources = opts.picker.sources or {}
      opts.picker.sources.projects = {
        dev = { dev },
        patterns = { ".git" },
        max_depth = 2,
        recent = true,
      }
    end,
  },
}
