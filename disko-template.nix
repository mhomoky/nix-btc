{
  disko.devices = {
    disk = {
      mydisk = {
        device = "/dev/disk/by-id/REPLACE_ME"; # Script replaces REPLACE_ME with the full disk symlink
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            installer = {
              start = "1MiB";
              end = "4096MiB";
              type = "0700";
            };
            ESP = {
              start = "4096MiB";
              end = "5120MiB";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              start = "5120MiB";
              end = "-8GiB";
              type = "8300";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
            swap = {
              start = "-8GiB";
              end = "100%";
              type = "8200";
              content = {
                type = "swap";
              };
            };
          };
        };
      };
    };
  };
}
