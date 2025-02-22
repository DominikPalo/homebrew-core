class Curaengine < Formula
  desc "C++ 3D printing GCode generator"
  homepage "https://github.com/Ultimaker/CuraEngine"
  url "https://github.com/Ultimaker/CuraEngine/archive/4.7.0.tar.gz"
  sha256 "97edb730f7fc625bccca0ca460c751fb388135c83e0e31e86f0ba21be1b1a713"
  license "AGPL-3.0-or-later"
  version_scheme 1
  head "https://github.com/Ultimaker/CuraEngine.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "9228dc8d4d2882c9c9446b254f2662730a966bfdae889d21160ba6d8f22f0828" => :catalina
    sha256 "f09a5563330546fcd4eea14e824df26f7bbca435e87330e11198742305d8a240" => :mojave
    sha256 "610e9ee7b9e8a914dbf07139daad3d5360f810531e45bd02860ec1dd92929ee0" => :high_sierra
  end

  depends_on "cmake" => :build

  # The version tag in these resources (e.g., `/1.2.3/`) should be changed as
  # part of updating this formula to a new version.
  resource "fdmextruder_defaults" do
    url "https://raw.githubusercontent.com/Ultimaker/Cura/4.7.0/resources/definitions/fdmextruder.def.json"
    sha256 "c56bdf9cc3e2edd85a158f14b891c8d719a1b6056c817145913495f7e907b1d2"
  end

  resource "fdmprinter_defaults" do
    url "https://raw.githubusercontent.com/Ultimaker/Cura/4.7.0/resources/definitions/fdmprinter.def.json"
    sha256 "854ed5ca6adb423d4d5d7c564a9cbcd282c35c6aa2c5414785583fdd3a7c3923"
  end

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args,
                            "-DCMAKE_INSTALL_PREFIX=#{libexec}",
                            "-DENABLE_ARCUS=OFF"
      system "make", "install"
    end
    bin.install "build/CuraEngine"
  end

  test do
    testpath.install resource("fdmextruder_defaults")
    testpath.install resource("fdmprinter_defaults")
    (testpath/"t.stl").write <<~EOS
      solid t
        facet normal 0 -1 0
         outer loop
          vertex 0.83404 0 0.694596
          vertex 0.36904 0 1.5
          vertex 1.78814e-006 0 0.75
         endloop
        endfacet
      endsolid Star
    EOS

    system "#{bin}/CuraEngine", "slice", "-j", "fdmprinter.def.json", "-l", "#{testpath}/t.stl"
  end
end
