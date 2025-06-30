# disko.nix
{
  disko.devices = {
    disk.usb = {
      device = "/dev/disk/by-id/ata-CT1000P3PSSD8_2317E6D01985"; # 1TB Sandisk Cruzer in Sabrent enclosure
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
