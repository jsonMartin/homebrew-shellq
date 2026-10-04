class Shellq < Formula
  desc "AI help for zsh at your prompt: commands, fixes and answers"
  homepage "https://github.com/jsonMartin/shellq"
  url "https://github.com/jsonMartin/shellq/archive/refs/tags/v1.0.0-beta.1.tar.gz"
  sha256 "760100dd7502f7c1727d479094c920f5ce74947d6b5778df6984a2248267fee3"
  license "MIT"

  depends_on "bun"
  depends_on "jq"
  uses_from_macos "zsh"

  # OpenTUI's prebuilt dylib has no header room for a rewritten install name.
  preserve_rpath

  def install
    system "bun", "install", "--frozen-lockfile", "--production"
    pkgshare.install "shellq.plugin.zsh", "src", "package.json", "bun.lock", "node_modules"
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
    assert_path_exists pkgshare/"node_modules/@opentui/core"
  end
end
