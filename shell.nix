with import <nixpkgs> {};
let
  aarch64 = pkgsCross.aarch64-multiplatform;
  clangPath = toString ../llvm-project/build;
  myclang = aarch64.buildPackages.wrapCCWith {
    gccForLibs = null;
    inherit (aarch64.buildPackages.targetPackages.llvmPackages_13.libraries) libcxx;
    cc = (stdenv.mkDerivation {
      name = "impure-clang";                                                                          
      dontUnpack = true;                                                                              
      installPhase = ''                                                                               
        mkdir -p $out/bin                                                                             
        for bin in ${toString (builtins.attrNames (builtins.readDir /scratch/paul/src/llvm-project/build/bin))}; do
          cat > $out/bin/$bin <<EOF
        #!${runtimeShell}
        exec "${clangPath}/bin/$bin" "\$@"
        EOF
          chmod +x $out/bin/$bin
        done
      '';
      passthru.isClang = true;
    });
  };
in (aarch64.buildPackages.overrideCC aarch64.stdenv myclang).mkDerivation {
  name = "env";
  nativeBuildInputs = aarch64.linux.nativeBuildInputs;
  depsBuildBuild = [
    aarch64.buildPackages.stdenv.cc
    aarch64.buildPackages.ncurses
  ];
  #NIX_CFLAGS_COMPILE = "-isystem ${clangPath}/build/tools/clang/lib/Headers";
  NIX_LDFLAGS = "-L${aarch64.buildPackages.targetPackages.llvmPackages_13.libraries.libcxxabi}/lib";
  hardeningDisable = [ "all" ];
}
