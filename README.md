# Isolate

Isolate your local directory with a microvm to safely run untrusted binaries.

## How to use

First, `cd` to a directory with a binary you don't trust. In there, you can simply run `nix run github:miampf/isolate#isolate`.
This will create a new qemu microvm with a default user `isolate` using the password `isolate`.
Your local directory will be copied to `/home/isolate`. To exit the VM run `sudo systemctl poweroff`.
