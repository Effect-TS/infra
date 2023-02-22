{lib, ...}: {
  time = {
    timeZone = lib.mkDefault "UTC";
  };

  i18n = {
    defaultLocale = lib.mkDefault "en_US.UTF-8";
    extraLocaleSettings = {
      LC_TIME = lib.mkDefault "en_US.UTF-8";
    };
    supportedLocales = lib.mkDefault [
      "en_US.UTF-8/UTF-8"
    ];
  };
}
