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
  url "https://github.com/nexbeam/homebrew-archivemount/releases/download/v0.9.1/archivemount_v0.9.1.tar.gz"
  sha256 "c46dead17fc949c78bf206ada336a041e75373e12386beca074348d794b22cd0"

  depends_on "automake" => :build
  depends_on "autoconf" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "truncate" => :build
  depends_on "libarchive"

  on_macos do
    depends_on OsxfuseRequirement => :build
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