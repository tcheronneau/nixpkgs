{ lib
, stdenv
, fetchFromGitHub
, buildPackages
, pkg-config
, libusb-compat-0_1
, readline
, libewf
, perl
, zlib
, openssl
, libuv
, file
, libzip
, xxHash
, gtk2
, vte
, gtkdialog
, python3
, ruby
, lua
, useX11 ? false
, rubyBindings ? false
, pythonBindings ? false
, luaBindings ? false
}:

let
  inherit (lib) optional;

  #<generated>
  # DO NOT EDIT! Automatically generated by ./update.py
  gittap = "5.1.1";
  gittip = "a86f8077fc148abd6443384362a3717cd4310e64";
  rev = "5.1.1";
  version = "5.1.1";
  sha256 = "0hv9x31iabasj12g8f04incr1rbcdkxi3xnqn3ggp8gl4h6pf2f3";
  cs_ver = "4.0.2";
  cs_sha256 = "0y5g74yjyliciawpn16zhdwya7bd3d7b1cccpcccc2wg8vni1k2w";
  #</generated>
in
stdenv.mkDerivation {
  pname = "radare2";
  inherit version;

  src = fetchFromGitHub {
    owner = "radare";
    repo = "radare2";
    inherit rev sha256;
  };

  postPatch =
    let
      capstone = fetchFromGitHub {
        owner = "aquynh";
        repo = "capstone";
        # version from $sourceRoot/shlr/Makefile
        rev = cs_ver;
        sha256 = cs_sha256;
      };
    in
    ''
      mkdir -p build/shlr
      cp -r ${capstone} capstone-${cs_ver}
      chmod -R +w capstone-${cs_ver}
      tar -czvf shlr/capstone-${cs_ver}.tar.gz capstone-${cs_ver}
    '';

  postInstall = ''
    install -D -m755 $src/binr/r2pm/r2pm $out/bin/r2pm
  '';

  WITHOUT_PULL = "1";
  makeFlags = [
    "GITTAP=${gittap}"
    "GITTIP=${gittip}"
    "RANLIB=${stdenv.cc.bintools.bintools}/bin/${stdenv.cc.bintools.targetPrefix}ranlib"
  ];
  configureFlags = [
    "--with-sysmagic"
    "--with-syszip"
    "--with-sysxxhash"
    "--with-openssl"
  ];

  enableParallelBuilding = true;
  depsBuildBuild = [ buildPackages.stdenv.cc ];

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ file readline libusb-compat-0_1 libewf perl zlib openssl libuv ]
    ++ optional useX11 [ gtkdialog vte gtk2 ]
    ++ optional rubyBindings [ ruby ]
    ++ optional pythonBindings [ python3 ]
    ++ optional luaBindings [ lua ];

  propagatedBuildInputs = [
    # radare2 exposes r_lib which depends on these libraries
    file # for its list of magic numbers (`libmagic`)
    libzip
    xxHash
  ];

  meta = {
    description = "unix-like reverse engineering framework and commandline tools";
    homepage = "http://radare.org/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ raskin makefu mic92 ];
    platforms = with lib.platforms; linux;
    inherit version;
  };
}
