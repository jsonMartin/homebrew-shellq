class Shellq < Formula
  desc "AI help for zsh at your prompt: commands, fixes and answers"
  homepage "https://github.com/jsonMartin/shellq"
  url "https://github.com/jsonMartin/shellq/archive/refs/tags/v1.0.0-beta.4.tar.gz"
  sha256 "b98c0d74ba3dc6acc1ca0d5ce36d5d3325c40d4e64ac357b8f77c2f5ca4ca9e4"
  license "MIT"

  depends_on "bun"
  depends_on "jq"
  uses_from_macos "zsh"

  # OpenTUI's prebuilt dylib has no header room for a rewritten install name.
  preserve_rpath

  def install
    system "bun", "install", "--frozen-lockfile", "--production"
    # tsconfig.json carries the @/ import alias and JSX settings Bun needs at runtime.
    pkgshare.install "shellq.plugin.zsh", "src", "package.json", "bun.lock", "tsconfig.json", "node_modules"
  end

  def caveats
    <<~EOS
      To load ShellQ, add this line to the end of ~/.zshrc:
        source #{opt_pkgshare}/shellq.plugin.zsh

      Then open a new shell and press Ctrl+O. ShellQ uses your signed-in
      Codex CLI or a local OpenAI-compatible server on 127.0.0.1.
    EOS
  end

  test do
    plugin = pkgshare/"shellq.plugin.zsh"
    loaded = shell_output("zsh -fc 'source #{plugin} && print -r -- ${+functions[_shellq_workbench]}'")
    assert_equal "1", loaded.strip
    ui = pkgshare/"src/workbench-ui.tsx"
    system formula_opt_bin("bun")/"bun", "-e", "await import(#{ui.to_s.inspect})"
  end
end
