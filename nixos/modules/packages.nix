{pkgs, ...}: {
  environment = {
    systemPackages = with pkgs; [
      yq-go
    ];
  };
}
