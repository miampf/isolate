{
  description = "Isolate your local environment to run untrusted binaries.";

  inputs.microvm.url = "github:astro/microvm.nix";
  inputs.microvm.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, microvm }:
    let
      system = "x86_64-linux";
    in {
      packages.${system} = {
        default = self.packages.${system}.isolate;
        isolate = self.nixosConfigurations.isolate.config.microvm.declaredRunner;
      };

      nixosConfigurations = {
        isolate = nixpkgs.lib.nixosSystem {
          modules = [
            microvm.nixosModules.microvm
            {
              nixpkgs.system = system;
              system.stateVersion = "24.05";
              networking.hostName = "isolate-microvm";
              users.users.root.password = "";
              users.users.isolate = {
                isNormalUser = true;
                extraGroups = [ "wheel" ];
                initialPassword = "isolate";
              };
              microvm = {
                volumes = [ {
                  mountPoint = "/var";
                  image = "var.img";
                  size = 256;
                } ];
                shares = [ {
                  # use "virtiofs" for MicroVMs that are started by systemd
                  proto = "9p";
                  tag = "ro-store";
                  # a host's /nix/store will be picked up so that no
                  # squashfs/erofs will be built for it.
                  source = "/nix/store";
                  mountPoint = "/nix/.ro-store";
                } 
                {
                  proto = "9p";
                  tag = "local-dir";
                  source = "./";
                  mountPoint = "/home/isolate/local-dir";
                } ];

                hypervisor = "qemu";
                socket = "control.socket";
              };
            }
          ];
        };
      };
    };
}
