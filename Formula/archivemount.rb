require "digest"

class OsxfuseRequirement < Requirement
  fatal true

  satisfy(build_env: false) { self.class.binary_osxfuse_installed? }

  def self.binary_osxfuse_installed?
    File.exist?("/usr/local/include/fuse/fuse.h") &&
      !File.symlink?("/usr/local/include/fuse")
  end

  env do
    unless HOMEBREW_PREFIX.to_s == "/usr/local"
      ENV.append_path "HOMEBREW_LIBRARY_PATHS", "/usr/local/lib"
      ENV.append_path "HOMEBREW_INCLUDE_PATHS", "/usr/local/include/fuse"
    end
  end

  def message
    "macFUSE is required to build libguestfs. Please run `brew install --cask macfuse` first."
  end
end

class Archivemount < Formula
  desc "Archivemount is a piece of glue code between libarchive and FUSE . It can be used to mount a (possibly compressed) archive (as in .tar.gz or .tar.bz2) and use it like an ordinary filesystem."
  homepage "https://github.com/cybernoid/archivemount"
  url "https://github.com/nexbeam/homebrew-archivemount/releases/download/v0.9.1/archivemount-v0.9.1.zip"
  sha256 "64a6e4d3cfabb30601fe698ff58382e3bead5322e46a4dc12c5234e6c543db94"

  depends_on "automake" => :build
  depends_on "autoconf" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "truncate" => :build
  depends_on "libarchive"

  on_macos do
    depends_on OsxfuseRequirement => :build
  end

  # the linux support is a bit of a guess, since homebrew doesn't currently build bottles for libvirt
  # that means brew test-bot's --build-bottle will fail under ubuntu-latest runners
  on_linux do
    depends_on "libfuse"
  end

  def install
    ENV["CFLAGS"] = "-I#{Formula["libarchive"].opt_include}"
    ENV["LDFLAGS"] = "-L#{Formula["libarchive"].opt_lib}"

    system "./configure", "--prefix=#{prefix}"

    system "make"

    system "make", "install"

    bin.install_symlink Dir["bin/*"]
  end

  test do
    system "#{bin}/archivemount", "-h"
  end
end