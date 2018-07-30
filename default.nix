with import <nixpkgs> { };

let
  rootName = name: builtins.elemAt (lib.splitString "/" name) 0;
  isValidFile = name: files: builtins.elem (rootName name) files;
  relative = path: name: lib.removePrefix (toString path + "/") name;
  onlyFiles = files: path: builtins.filterSource (name: type: isValidFile (relative path name) files) path;

  eta-nix = fetchTarball "https://github.com/eta-lang/eta-nix/archive/1638c3f133a3931ec70bd0d4f579b67fd62897e2.tar.gz";

  rewriteRelative = top: path:
    let path' = lib.removePrefix top (builtins.toString path);
    in if lib.isStorePath path' then path' else ./. + path';

  overrides = self: super: {
    mkDerivation = args: super.mkDerivation (lib.overrideExisting args {
      src = rewriteRelative eta-nix args.src;
    });

    eta = haskell.lib.overrideCabal super.eta (drv: {
      # Makes the build a bit faster
      src = onlyFiles ["compiler" "include" "eta" "eta.cabal" "LICENSE" "tests"] drv.src;
    });
  };
  hpkgs = (import eta-nix { }).override { inherit overrides; };
in
hpkgs // {
  eta-build-shell = runCommand "eta-build-shell" {
    # Libraries don't pass -encoding to javac.
    LC_ALL = "en_US.utf8";
    buildInputs = [
      hpkgs.eta
      hpkgs.eta-build
      hpkgs.eta-pkg
      hpkgs.etlas
      gitMinimal
      jdk
      glibcLocales
    ];
  } "";

  shells = {
    ghc = hpkgs.shellFor {
      packages = p: [
        p.eta
        p.codec-jvm
        p.eta-boot
        p.eta-boot-meta
        p.eta-meta
        p.eta-repl
        p.eta-pkg
        p.etlas
        p.etlas-cabal
        p.hackage-security
        p.shake
        ];
    };
  };
}
