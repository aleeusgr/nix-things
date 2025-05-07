[nixos-rebuild switch](https://nixos.org/manual/nixos/stable/index.html#sec-switching-systems)

common task, ~deploy this configuration on local machine.

`switch`, `test`, `boot`  `dry-activate`

If the action is `switch` or `test`, the currently running system is inspected and the actions to switch to the new system are calculated. This process takes two data sources into account: `/etc/fstab` and the current *systemd* status. Mounts and swaps are read from `/etc/fstab` and the corresponding actions are generated. If a new mount is added, for example, the proper `.mount` unit is marked to be started. The current systemd state is inspected, the difference between the current system and the desired configuration is calculated and actions are generated to get to this state. There are a lot of nuances that can be controlled by the units which are explained here.

