class Icu4c < Formula
  desc "C/C++ and Java libraries for Unicode and globalization"
  homepage "https://ssl.icu-project.org/"
  url "https://ssl.icu-project.org/files/icu4c/63.1/icu4c-63_1-src.tgz"
  mirror "https://github.com/unicode-org/icu/releases/download/release-63-1/icu4c-63_1-src.tgz"
  version "63.1"
  sha256 "05c490b69454fce5860b7e8e2821231674af0a11d7ef2febea9a32512998cb9d"

  bottle do
    cellar :any
    sha256 "e707bf5e3d0189ede7d941d95a417b5dacad3eac99b9a677042464140f12fa1d" => :mojave
    sha256 "0ac5ee60393d26ec26a915ed957a38a0b2355fe7991f607044edaedd3ff14cc1" => :high_sierra
    sha256 "dd64c70639ba91fe0c07304c0563681ba97b221e9f9919497b383884b8bb0b65" => :sierra
    sha256 "92301d355c0c487f345998ffb2c8fff3ce1b63d5ab3b635864c73c98f9555159" => :x86_64_linux
  end

  keg_only :provided_by_macos, "macOS provides libicucore.dylib (but nothing else)"

  def install
    # Reduce memory usage below 4 GB for Circle CI.
    ENV["MAKEFLAGS"] = "-j24" if ENV["CIRCLECI"]

    args = %W[--prefix=#{prefix} --disable-samples --disable-tests --enable-static]
    args << "--with-library-bits=64" if MacOS.prefer_64_bit?

    cd "source" do
      system "./configure", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    if File.readable? "/usr/share/dict/words"
      system "#{bin}/gendict", "--uchars", "/usr/share/dict/words", "dict"
    else
      (testpath/"hello").write "hello\nworld\n"
      system "#{bin}/gendict", "--uchars", "hello", "dict"
    end
  end
end
