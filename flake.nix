{
  description = "Flake to set ohMyZsh theme to a custom one";

  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem(system:  {

    packages.default = nixpkgs.legacyPackages.${system}.stdenv.mkDerivation {
      name = "half-life-2";

      src = ./ohMyZshCustom;

      installPhase = ''
        mkdir -p $out/share
        cp -r * $out/share
      '';
    };
    
    homeManagerModules.default = { config, pkgs, ... }: { 
      programs.zsh.oh-my-zsh.custom = "${self.packages.${system}.default}/share";
      programs.zsh.oh-my-zsh.theme = "half-life-2";

      home.packages = [ 
        self.packages.${system}.default
      ];
    };
  });
}
