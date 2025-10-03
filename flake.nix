{
  description = "Neomutt for Gmail - Pre-configured setup for Gmail with lieer, notmuch, and neomutt";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }: {
    homeManagerModules.default = { config, lib, pkgs, ... }: {
      programs.lieer.enable = true;
      
      programs.notmuch = {
        enable = true;
        new.ignore = [ "/.*[.](json|lock|bak)$/" ];
      };

      programs.msmtp.enable = true;

      programs.neomutt = {
        enable = true;
        vimKeys = true;
        sidebar = {
          enable = true;
          shortPath = true;
          width = 20;
        };
        settings = {
          virtual_spoolfile = true;
          nm_default_url = "notmuch://$HOME/Mail";
          nm_query_type = "threads";
          sort = "threads";
          sort_aux = "reverse-last-date-received";
          index_format = "%4C %Z %{%b %d} %-15.15L (%?l?%4l&%4c?) %s";
          pager_index_lines = 10;
          pager_context = 3;
          pager_stop = true;
          menu_scroll = true;
          markers = false;
          auto_tag = true;
        };
        binds = [
          { map = [ "index" "pager" ]; key = "g"; action = "noop"; }
          { map = [ "index" "pager" ]; key = "gi"; action = "<change-vfolder>?"; }
          { map = [ "index" "pager" ]; key = "ga"; action = "<entire-thread>"; }
          { map = [ "index" ]; key = "\\\\"; action = "<vfolder-from-query>"; }
          { map = [ "index" ]; key = "L"; action = "<limit>"; }
        ];
        macros = [
          { map = [ "index" "pager" ]; key = "S"; action = "<modify-labels>+spam -inbox<enter>"; }
          { map = [ "index" "pager" ]; key = "A"; action = "<modify-labels>+archive -inbox<enter>"; }
          { map = [ "index" "pager" ]; key = "I"; action = "<modify-labels>+inbox<enter>"; }
        ];
        extraConfig = ''
          virtual-mailboxes "Inbox" "notmuch://?query=tag:inbox"
          virtual-mailboxes "Unread" "notmuch://?query=tag:unread"
          virtual-mailboxes "Starred" "notmuch://?query=tag:starred"
          virtual-mailboxes "Sent" "notmuch://?query=tag:sent"
          virtual-mailboxes "Drafts" "notmuch://?query=tag:draft"
          virtual-mailboxes "All Mail" "notmuch://?query=*"
        '';
      };
    };
  };
}