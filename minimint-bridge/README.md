## Building with Nix

Included `flake.nix` provides convenient reproducible building environment,
including cross-compilation for Android.


#### Set up Nix (one time)

Fedimint uses [Nix](https://nixos.org/explore.html) for building, CI, and managing dev environment.
Note: only `Nix` (the language & package manager) and not the NixOS (the Linux distribution) is needed.
Nix can be installed on any Linux distribution and macOS.


#### Install Nix

If you don't have it set up already,
follow the instructions at: https://nixos.org/download.html

The end result is having a working `nix` command in your shell.

Example:

```
> nix --version
nix (Nix) 2.9.1
```

The exact version might be different.

#### Enable nix flakes

Edit either `~/.config/nix/nix.conf` or `/etc/nix/nix.conf` and add:

```
experimental-features = nix-command flakes
```

If the Nix installation is in multi-user mode, don’t forget to restart the nix-daemon.

#### Use Nix Shell

If your Nix is set up properly `nix develop` started inside the project dir should just work
(though it might take a while to download all the necessary files and build all the internal
tooling). In the meantime you can read other documentation.

**Using `nix develop` is strongly recommended**. It takes care of setting up
all the required developer automation, checks and ensures that all the developers and CI are 
in sync: working with same set of tools (exact versions).

You can still use your favorite IDE, Unix shell, and other personal utilities, but they MUST NOT
be expected to be a requirements for other developers. In other words: if it's not automated
and set up in `nix develop` shell, it doesn't exist from team's perspective.

To use a different shell for `nix develop`, try `nix develop -c zsh`. You can alias it if
don't want to remember about it. That's the recommended way to use a different shell
for `nix develop`.

### Building

For local work in `nix develop` shell, run:

```
cargo build --target <target>
```

where supported targets are:

* `aarch64-linux-android`
* `armv7-linux-androideabi`
* `i686-linux-android`
* `x86_64-linux-android`

For CI and automated work use one of:

```
nix build .#packages.x86_64-linux.aarch64.workspaceBuild
nix build .#packages.x86_64-linux.armv7.workspaceBuild
nix build .#packages.x86_64-linux.i686.workspaceBuild
nix build .#packages.x86_64-linux.x86_64.workspaceBuild
```

and see the result in `./result/` directory (symlink to a directory).

The `x86_64-linux` is Nix host system, and migh be different on MacOS or ARM based systems, etc.

**Note**:

* Building on Mac might be currently broken (but fixable).
* Building on ARM MacOS will be broken until Android NDK for that platform is available.
* Building targeting 32-bit archs with rocksdb enabled is broken due to https://github.com/rust-rocksdb/rust-rocksdb/pull/682
