class Ecell4 < Formula
  desc "Multi algorithm-timescale bio-simulation environment"
  homepage "https://github.com/ecell/ecell4"
  # tag "systems biology"
  # doi "10.1093/bioinformatics/15.1.72"
  url "https://github.com/ecell/ecell4/archive/4.0.0.tar.gz"
  sha256 "2cd3c82bc6e9666361f4d3bafa7272548ba2b52c179ad27a0fe35daf507bfd80"

  head "https://github.com/ecell/ecell4.git"
  option "with-python3", "Build python3 bindings"

  depends_on "cmake" => :build
  depends_on "gsl" => :build
  depends_on "homebrew/versions/boost155" => :build
  depends_on "homebrew/science/hdf5"
  depends_on "pkg-config" => :build
  depends_on "ffmpeg" => %w[with-libvpx with-libvorbis]
  depends_on :python3 => :optional

  resource "cython" do
    url "http://cython.org/release/Cython-0.23.4.zip"
    sha256 "44444591133c92a30d78a6ec52ea4afd902ee4548ca5e83d94388f6a99f6c9ae"
  end

  def install
    args = %W[
      .
      -DCMAKE_INSTALL_PREFIX=#{prefix}
    ]
    ENV["CPATH"] = "#{HOMEBREW_PREFIX}/include:#{buildpath}"

    system "cmake", *args
    system "cat", "ecell4/core/config.h"
    system "make", "BesselTables"
    if build.with? "python3"

      resource("cython").stage do
        system "python3", *Language::Python.setup_install_args(buildpath/"vendor")
      end
      ENV.prepend_path "PYTHONPATH", buildpath/"vendor/lib/python3.5/site-packages"
      # centos needs lib64 path
      ENV.prepend_path "PYTHONPATH", buildpath/"vendor/lib64/python3.5/site-packages"
      cd "python" do
        ENV.prepend_create_path "PYTHONPATH", prefix/"lib/python3.5/site-packages"
        system "python3", "setup.py", "build_ext"
        system "python3", *Language::Python.setup_install_args(prefix)
      end
    else

      resource("cython").stage do
        system "python", *Language::Python.setup_install_args(buildpath/"vendor")
      end
      ENV.prepend_path "PYTHONPATH", buildpath/"vendor/lib/python2.7/site-packages"
      # centos needs lib64 path
      ENV.prepend_path "PYTHONPATH", buildpath/"vendor/lib64/python2.7/site-packages"
      cd "python" do
        ENV.prepend_create_path "PYTHONPATH", prefix/"lib/python2.7/site-packages"
        system "python", "setup.py", "build_ext"
        system "python", *Language::Python.setup_install_args(prefix)
      end
    end
  end

  test do
    system "python", "-c", "from ecell4 import *"
  end
end
