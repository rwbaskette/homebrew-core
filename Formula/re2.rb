class Re2 < Formula
  desc "Alternative to backtracking PCRE-style regular expression engines"
  homepage "https://github.com/google/re2"
  url "https://github.com/google/re2/archive/2018-12-01.tar.gz"
  version "20181201"
  sha256 "715e01685719a4ed68a353ae48249612ef4a7464755c3ecccaceae91ebd34868"
  head "https://github.com/google/re2.git"

  bottle do
    cellar :any
    sha256 "ce2bda9edbe124644d977cc25dfa7672b9039b05e500ed4b0583de4621138c54" => :mojave
    sha256 "7962193156fa1acf325c9f8d0be12bfef9c6a4d7a408cd35a4eb17baed349a12" => :high_sierra
    sha256 "88640ac51671f67ae2898cd677d32581c2af799b02fd99ef3436cf958644ece9" => :sierra
    sha256 "311b9c63bf83d4da2726f25c789877a7ea6904425a86be46c81168ba7c3b3ee9" => :x86_64_linux
  end

  needs :cxx11

  def install
    # Reduce memory usage below 4 GB for Circle CI.
    ENV["MAKEFLAGS"] = "-j8" if ENV["CIRCLECI"]

    ENV.cxx11

    system "make", "install", "prefix=#{prefix}"
    MachO::Tools.change_dylib_id("#{lib}/libre2.0.0.0.dylib", "#{lib}/libre2.0.dylib") if OS.mac?
    ext = OS.mac? ? "dylib" : "so"
    lib.install_symlink "libre2.0.0.0.#{ext}" => "libre2.0.#{ext}"
    lib.install_symlink "libre2.0.0.0.#{ext}" => "libre2.#{ext}"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <re2/re2.h>
      #include <assert.h>
      int main() {
        assert(!RE2::FullMatch("hello", "e"));
        assert(RE2::PartialMatch("hello", "e"));
        return 0;
      }
    EOS
    system ENV.cxx, "-std=c++11",
           "test.cpp", "-I#{include}", "-L#{lib}", "-pthread", "-lre2", "-o", "test"
    system "./test"
  end
end
