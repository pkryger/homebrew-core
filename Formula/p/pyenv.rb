class Pyenv < Formula
  desc "Python version management"
  homepage "https://github.com/pyenv/pyenv"
  url "https://github.com/pyenv/pyenv/archive/refs/tags/v2.6.2.tar.gz"
  sha256 "d6bf7d98f5cd47d7b309bbf8c1d246137e31831e3cd0e468061d0a6cdaee1eaa"
  license "MIT"
  version_scheme 1
  head "https://github.com/pyenv/pyenv.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+(-\d+)?)$/i)
  end

  bottle do
    sha256 cellar: :any,                 arm64_sequoia: "6ab4b9017881cd41cab70ccaff3ffb08f9c46755e71aaca7e34b0aca197b9a20"
    sha256 cellar: :any,                 arm64_sonoma:  "83fee7855051714805ba0155df2cc8684a085321bb6ad1e3a1b3439031ff3bd3"
    sha256 cellar: :any,                 arm64_ventura: "076bdcb06584ddc5e059fb409bacebd5c8c795b0e254544ca0c9f643804b3e96"
    sha256 cellar: :any,                 sonoma:        "040b9218f2d74662086b10ec4ffa7efb9f3a58821cde7eebfd73ad45f8dde364"
    sha256 cellar: :any,                 ventura:       "971b056a7df585fd2fc83228debb31b4969145d8d3f3101a2fda7510a11d6bb3"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "81768d7e7ccf6989ee40a6f88c864941c5260f15c631bf4848a9a83e0094c833"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "84c74bc84ff084019e767641b0fbd54ce29bf750a646bc24d37087f6bf99fddf"
  end

  depends_on "autoconf"
  depends_on "openssl@3"
  depends_on "pkgconf"
  depends_on "readline"

  uses_from_macos "python" => :test
  uses_from_macos "bzip2"
  uses_from_macos "libffi"
  uses_from_macos "ncurses"
  uses_from_macos "xz"
  uses_from_macos "zlib"

  def install
    inreplace "libexec/pyenv", "/usr/local", HOMEBREW_PREFIX
    inreplace "libexec/pyenv-rehash", "$(command -v pyenv)", opt_bin/"pyenv"
    inreplace "pyenv.d/rehash/source.bash", "$(command -v pyenv)", opt_bin/"pyenv"

    system "src/configure"
    system "make", "-C", "src"

    prefix.install Dir["*"]
    %w[pyenv-install pyenv-uninstall python-build].each do |cmd|
      bin.install_symlink "#{prefix}/plugins/python-build/bin/#{cmd}"
    end

    share.install prefix/"man"

    # Do not manually install shell completions. See:
    #   - https://github.com/pyenv/pyenv/issues/1056#issuecomment-356818337
    #   - https://github.com/Homebrew/homebrew-core/pull/22727
  end

  test do
    # Create a fake python version and executable.
    pyenv_root = Pathname(shell_output("#{bin}/pyenv root").strip)
    python_bin = pyenv_root/"versions/1.2.3/bin"
    foo_script = python_bin/"foo"
    foo_script.write "echo hello"
    chmod "+x", foo_script

    # Test versions.
    versions = shell_output("eval \"$(#{bin}/pyenv init --path)\" " \
                            "&& eval \"$(#{bin}/pyenv init -)\" " \
                            "&& #{bin}/pyenv versions").split("\n")
    assert_equal 2, versions.length
    assert_match(/\* system/, versions[0])
    assert_equal("  1.2.3", versions[1])

    # Test rehash.
    system bin/"pyenv", "rehash"
    refute_match "Cellar", (pyenv_root/"shims/foo").read
    assert_equal "hello", shell_output("eval \"$(#{bin}/pyenv init --path)\" " \
                                       "&& eval \"$(#{bin}/pyenv init -)\" " \
                                       "&& PYENV_VERSION='1.2.3' foo").chomp
  end
end
