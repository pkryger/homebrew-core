class Ydiff < Formula
  desc "View colored diff with side by side and auto pager support"
  homepage "https://github.com/ymattw/ydiff"
  url "https://files.pythonhosted.org/packages/1e/ed/e25e1f4fffbdfd0446f1c45504759e54676da0cde5a844d201181583fce4/ydiff-1.2.tar.gz"
  sha256 "f5430577ecd30974d766ee9b8333e06dc76a947b4aae36d39612a0787865a121"
  license "BSD-3-Clause"
  revision 2

  bottle do
    rebuild 3
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "dff1fab705b70cc0a6a0428ed757b3f773f8f33319292f697b5e117bc350f669"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "08d28ce6db77fb6a291ba4664f3e7fbaa4cdd03557e002334cddc1c42a3d9ee2"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "3bfe8ba4dcbe840936cf3dfb64a0a7ba393b599ddda7c3c8361e411584800b09"
    sha256 cellar: :any_skip_relocation, sonoma:         "eb83590a9ccb770126c72ce2a96086f2f054c449ff4e64a98787fced77907a91"
    sha256 cellar: :any_skip_relocation, ventura:        "2874217a6d270271c808dfa2f74a7d970ed3dc0aa876c1a2e04d1899443c3d05"
    sha256 cellar: :any_skip_relocation, monterey:       "830743ac5ea771d7f39fbaf8533fffc9d0d04a76ec4342ad8799284ce61d583c"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "f534a6806cd6e15cabbba1f3361486e75f03960230e83a4976ddadac66fb12d5"
  end

  depends_on "python-setuptools" => :build
  depends_on "python@3.12"

  def python3
    "python3.12"
  end

  def install
    system python3, "-m", "pip", "install", *std_pip_args, "."
  end

  test do
    diff_fixture = test_fixtures("test.diff").read
    assert_equal diff_fixture,
      pipe_output("#{bin}/ydiff -cnever", diff_fixture)
  end
end
