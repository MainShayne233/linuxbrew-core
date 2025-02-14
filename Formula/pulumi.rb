class Pulumi < Formula
  desc "Cloud native development platform"
  homepage "https://pulumi.io/"
  url "https://github.com/pulumi/pulumi.git",
      :tag      => "v1.7.1",
      :revision => "03e0005fe0ce4b6bbe04c460a9bbc62869558214"

  bottle do
    cellar :any_skip_relocation
    sha256 "bc3c243d69e83b2177b6a81e1804b2ee4ecca5e944e72a1686f12b107471a403" => :catalina
    sha256 "be1c8125a7c4276a68a5e06c50b3c987c4172b4a675dd097013a33b3e1af94fc" => :mojave
    sha256 "1b5fa9e26ca6dcd3c3130b237e789b0e3c240c524468e6a99b707509ed121bde" => :high_sierra
    sha256 "43f80c8416e21c6a2c98557158cbbe9dec43ea6547f8edb4d2df09b9de63b6b0" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    ENV["GO111MODULE"] = "on"

    dir = buildpath/"src/github.com/pulumi/pulumi"
    dir.install buildpath.children

    cd dir do
      system "go", "mod", "vendor"
      system "make", "dist"
      bin.install Dir["#{buildpath}/bin/*"]
      prefix.install_metafiles

      # Install bash completion
      output = Utils.popen_read("#{bin}/pulumi gen-completion bash")
      (bash_completion/"pulumi").write output

      # Install zsh completion
      output = Utils.popen_read("#{bin}/pulumi gen-completion zsh")
      (zsh_completion/"_pulumi").write output
    end
  end

  test do
    ENV["PULUMI_ACCESS_TOKEN"] = "local://"
    ENV["PULUMI_TEMPLATE_PATH"] = testpath/"templates"
    system "#{bin}/pulumi", "new", "aws-typescript", "--generate-only",
                                                     "--force", "-y"
    assert_predicate testpath/"Pulumi.yaml", :exist?, "Project was not created"
  end
end
