{
  description = "Nix build for the native Commodore 128 NS-Shaft prototype";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages.${system}.default = pkgs.stdenvNoCC.mkDerivation {
        pname = "nsshaft-c128";
        version = "1.0.0";
        src = self;

        nativeBuildInputs = [ pkgs.cc65 ];

        dontConfigure = true;

        buildPhase = ''
          runHook preBuild

          mkdir -p build
          ca65 src/main.s -g \
            -l build/nsshaft-c128.lst \
            -o build/nsshaft-c128.o

          ld65 -C c128-prg.cfg \
            -Ln build/nsshaft-c128.lbl \
            -m build/nsshaft-c128.map \
            -o build/nsshaft-c128.prg \
            build/nsshaft-c128.o

          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall

          install -Dm644 build/nsshaft-c128.prg $out/nsshaft-c128.prg
          install -Dm644 build/nsshaft-c128.lst $out/nsshaft-c128.lst
          install -Dm644 build/nsshaft-c128.lbl $out/nsshaft-c128.lbl
          install -Dm644 build/nsshaft-c128.map $out/nsshaft-c128.map

          runHook postInstall
        '';
      };

      devShells.${system}.default = pkgs.mkShell {
        packages = [ pkgs.cc65 ];
      };

      checks.${system}.default = self.packages.${system}.default;
    };
}
