require "digest"

class CpuRequirement < Requirement
  fatal true

  satisfy() { Hardware::CPU.arm? }

  def message
    "Only apple m1/m2 supported!"
  end
end

class Archivemount < Formula
  desc "Archivemount is a piece of glue code between libarchive and FUSE . It can be used to mount a (possibly compressed) archive (as in .tar.gz or .tar.bz2) and use it like an ordinary filesystem."
  homepage "https://github.com/cybernoid/archivemount"
  version "0.9.1"
  revision 1

  on_macos do
      depends_on CpuRequirement
  end

  url "https://github.com/nexbeam/homebrew-archivemount/releases/download/v0.9.1/archivemount-aarch64-darwin.tar.gz"
  sha256 "c45332c0ecc522ab511effc97b32b089fb61eedd86695627be9715d7090598bf"

  def install
    (prefix).install Dir["./*"]
    bin.install_symlink Dir["bin/*"]
  end
end