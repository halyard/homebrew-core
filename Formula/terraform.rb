class Terraform < Formula
  desc "Tool to build, change, and version infrastructure"
  homepage "https://www.terraform.io/"
  # NOTE: Do not bump to v1.6.0+ as license changed to BUSL-1.1
  # https://github.com/hashicorp/terraform/pull/33661
  # https://github.com/hashicorp/terraform/pull/33697
  url "https://github.com/hashicorp/terraform/archive/refs/tags/v1.5.7.tar.gz"
  sha256 "6742fc87cba5e064455393cda12f0e0241c85a7cb2a3558d13289380bb5f26f5"
  license "MPL-2.0"
  head "https://github.com/hashicorp/terraform.git", branch: "main"


  # https://www.hashicorp.com/blog/hashicorp-adopts-business-source-license
  deprecate! date: "2024-04-04", because: "changed its license to BUSL on the next release"

  depends_on "go" => :build

  conflicts_with "tenv", because: "both install terraform binary"
  conflicts_with "tfenv", because: "tfenv symlinks terraform binaries"

  # Needs libraries at runtime:
  # /usr/lib/x86_64-linux-gnu/libstdc++.so.6: version `GLIBCXX_3.4.29' not found (required by node)
  fails_with gcc: "5"

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  def caveats
    <<~EOS
      We will not accept any new Terraform releases in homebrew/core (with the BUSL license).
      The next release changed to a non-open-source license:
      https://www.hashicorp.com/blog/hashicorp-adopts-business-source-license
      See our documentation for acceptable licences:
        https://docs.brew.sh/License-Guidelines
    EOS
  end

  test do
    minimal = testpath/"minimal.tf"
    minimal.write <<~EOS
      variable "aws_region" {
        default = "us-west-2"
      }

      variable "aws_amis" {
        default = {
          eu-west-1 = "ami-b1cf19c6"
          us-east-1 = "ami-de7ab6b6"
          us-west-1 = "ami-3f75767a"
          us-west-2 = "ami-21f78e11"
        }
      }

      # Specify the provider and access details
      provider "aws" {
        access_key = "this_is_a_fake_access"
        secret_key = "this_is_a_fake_secret"
        region     = var.aws_region
      }

      resource "aws_instance" "web" {
        instance_type = "m1.small"
        ami           = var.aws_amis[var.aws_region]
        count         = 4
      }
    EOS
    system bin/"terraform", "init"
    system bin/"terraform", "graph"
  end
end
