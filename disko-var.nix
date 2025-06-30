# /tmp/disko.nix
{
  disko.devices = {
    disk = {
      mydisk = {
        device = builtins.getEnv "CHOSEN_DISK"; # Replace with selected disk
        type = "disk";
        content = {
          type = "gpt";
          partitions = [
            # Existing installer partition (do not touch)
            { name = "installer"; start = "1MiB"; end = "4096MiB"; type = "0700"; }
            # ESP for new NixOS
            { name = "ESP"; start = "4096MiB"; end = "5120MiB"; type = "EF00";
              content = { type = "filesystem"; format = "vfat"; mountpoint = "/boot"; mountOptions = [ "umask=0077" ]; };
            }
            # Root for new NixOS
            { name = "root"; start = "5120MiB"; end = "-8GiB"; type = "8300";
              content = { type = "filesystem"; format = "ext4"; mountpoint = "/"; };
            }
            # Swap for new NixOS
            { name = "swap"; start = "-8GiB"; end = "100%"; type = "8200";
              content = { type = "swap"; };
            }
          ];
        };
      };
    };
  };
}
