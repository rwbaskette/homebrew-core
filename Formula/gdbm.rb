class Gdbm < Formula
  desc "GNU database manager"
  homepage "https://www.gnu.org/software/gdbm/"
  url "https://ftp.gnu.org/gnu/gdbm/gdbm-1.18.1.tar.gz"
  mirror "https://ftpmirror.gnu.org/gdbm/gdbm-1.18.1.tar.gz"
  sha256 "86e613527e5dba544e73208f42b78b7c022d4fa5a6d5498bf18c8d6f745b91dc"

  bottle do
    cellar :any
    sha256 "4c2f6db42c5972e7061ace3c1fb0a41f2c0db92a7a3d29cc806f097794dbd898" => :mojave
    sha256 "7fdad0257e967b63f63b82d6ef48c718d26ead7b38376ed56609bacefa4a252b" => :high_sierra
    sha256 "9d0b8affbced6c6fb759a077cf5fac4fca0d4b69dd2f4a82ca2f38b20e0f0ece" => :sierra
    sha256 "6497d8784138f7791a138fdd768073ba1bd629686c8e9322fa83a4f75f8d98df" => :x86_64_linux
  end

  if OS.mac?
    option "with-libgdbm-compat", "Build libgdbm_compat, a compatibility layer which provides UNIX-like dbm and ndbm interfaces."
  else
    option "without-libgdbm-compat", "Do not build libgdbm_compat, a compatibility layer which provides UNIX-like dbm and ndbm interfaces."
  end

  # Use --without-readline because readline detection is broken in 1.13
  # https://github.com/Homebrew/homebrew-core/pull/10903
  def install
    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --without-readline
      --prefix=#{prefix}
    ]

    args << "--enable-libgdbm-compat" if build.with? "libgdbm-compat"

    # GDBM uses some non-standard GNU extensions,
    # enabled with -D_GNU_SOURCE.  See:
    #   https://patchwork.ozlabs.org/patch/771300/
    #   https://stackoverflow.com/questions/5582211
    #   https://www.gnu.org/software/automake/manual/html_node/Flag-Variables-Ordering.html
    #
    # Fix error: unknown type name 'blksize_t'
    args << "CPPFLAGS=-D_GNU_SOURCE" unless OS.mac? || build.bottle?

    system "./configure", *args
    system "make", "install"
  end

  test do
    pipe_output("#{bin}/gdbmtool --norc --newdb test", "store 1 2\nquit\n")
    assert_predicate testpath/"test", :exist?
    assert_match /2/, pipe_output("#{bin}/gdbmtool --norc test", "fetch 1\nquit\n")
  end
end
