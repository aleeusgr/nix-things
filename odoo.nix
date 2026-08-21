{ config, pkgs, lib, ... }:

{
  # Odoo Community 18
  #
  # The NixOS Odoo module also enables PostgreSQL and creates:
  #   database: odoo
  #   database user: odoo
  #
  # Odoo will be available at:
  #   http://localhost:8069

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;
  };
  services.odoo = {
    enable = true;
    package = pkgs.odoo18;

    # Initialize the "odoo" database on first start.
    autoInit = true;
    autoInitExtraFlags = [
      "--without-demo=all"
    ];

    settings.options = {
      # Single-machine/local installation.
      # PostgreSQL authentication is handled locally by NixOS.
      db_host = false;
      db_port = false;
      db_user = "odoo";
      db_password = false;

      # Odoo's built-in HTTP server.
      http_interface = "127.0.0.1";
      http_port = 8069;

      # Keep the database manager hidden. Since autoInit creates
      # the database, it is not needed for this setup.
      list_db = false;

      # Appropriate for a local/test installation.
      # For a production deployment, use workers > 0 and nginx.
      workers = 0;
    };
  };

  # No firewall port is required while Odoo listens only on localhost.
  #
  # To make Odoo reachable from other machines on your LAN:
  #
  # services.odoo.settings.options.http_interface = "0.0.0.0";
  # networking.firewall.allowedTCPPorts = [ 8069 ];
}
