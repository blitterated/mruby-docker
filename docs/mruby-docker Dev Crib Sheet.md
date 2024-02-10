# mruby-docker Dev Crib Sheet

## Manual steps

#### Clone mruby repository

```sh
git clone https://github.com/mruby/mruby.git
```

#### Build/Run a basic dde

```sh
docker build --progress=plain -t dde .

docker run -it --rm \
  --mount type=bind,source="$(pwd)",target="/src" \
  --name mruby_dde \
  dde
```

#### Update and install a build chain for mruby

```sh 
apt update && apt --yes upgrade
apt --yes install build-essential gcc bison gperf ruby3.0
```

#### Build mruby

```sh
./minirake
```


--------------------------------------------------------------------------------

## Try it in Docker

Build an image

```sh
docker build --progress=plain -t mruby .

{ time docker build --progress=plain -t mruby . ; } 2>&1 \
| tee "mruby_docker_build.log"

```

Files to copy to `/opt/mruby`

```text
/mruby/build/host/
|-- LEGAL
|-- bin
|   |-- mirb
|   |-- mrbc
|   |-- mrdb
|   |-- mruby
|   |-- mruby-config
|   `-- mruby-strip
|-- lib
|   |-- libmruby.a
|   |-- libmruby.flags.make     <-- NOT THIS
|   `-- libmruby_core.a
|-- mrbc
|   |-- bin
|   |   `-- mrbc
|   `-- lib
|       `-- libmruby_core.a
`-- presym
```

Run the image

```bash
docker run -it --rm mruby
```

#### Strip the executables

```sh
cd /mruby/build/host/bin/
strip mirb
strip mrbc
strip mruby-config
strip mruby-strip
```

Before:

/src/build/host/bin# file *
mirb:         ELF 64-bit LSB pie executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, BuildID[sha1]=fd8c732e19a82e79cca730558c56c3b31a5a0726, for GNU/Linux 3.7.0, with debug_info, not stripped
mrbc:         ELF 64-bit LSB pie executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, BuildID[sha1]=a4f9f79e89f855d712fcd781bd86bdc4a8b291a6, for GNU/Linux 3.7.0, with debug_info, not stripped
mrdb:         ELF 64-bit LSB pie executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, BuildID[sha1]=d77cbab5f1d27f3ccd7724dfd9204f455865dc7c, for GNU/Linux 3.7.0, with debug_info, not stripped
mruby:        ELF 64-bit LSB pie executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, BuildID[sha1]=83846c28e468787ffa85b546a6fb1b863f0c6dda, for GNU/Linux 3.7.0, with debug_info, not stripped
mruby-config: POSIX shell script, ASCII text executable, with very long lines (341)
mruby-strip:  ELF 64-bit LSB pie executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, BuildID[sha1]=52baf796543212f524159f053456c47b3ac75a46, for GNU/Linux 3.7.0, with debug_info, not stripped

After:

/mruby/build/host/bin# file *
apt.file.log: ASCII text, with CRLF, LF line terminators
mirb:         ELF 64-bit LSB pie executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, BuildID[sha1]=8850e8d9c1412f029acb0308d774d715880f437d, for GNU/Linux 3.7.0, stripped
mrbc:         ELF 64-bit LSB pie executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, BuildID[sha1]=e1179803b6b3b0bfd7b93c5747bd3986cced4c27, for GNU/Linux 3.7.0, stripped
mrdb:         ELF 64-bit LSB pie executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, BuildID[sha1]=9bd1fe2c45406574f49a791f99e075e5a93839f8, for GNU/Linux 3.7.0, stripped
mruby:        ELF 64-bit LSB pie executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, BuildID[sha1]=540aece0bbcd5cd9edcecff92c8047dc5567851a, for GNU/Linux 3.7.0, stripped
mruby-config: POSIX shell script, ASCII text executable, with very long lines (341)
mruby-strip:  ELF 64-bit LSB pie executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, BuildID[sha1]=7cada3c0fc5e4a4dd65c0ab997a69a9f4bfd19b9, for GNU/Linux 3.7.0, stripped


--------------------------------------------------------------------------------

View the last build log

```bash
view $(ls -td1 logs/* | head -n1)
```

TODO:

* Build mruby with mruby-dir-glob gem
* Use mruby in Dockerfile heredoc





--------------------------------------------------------------------------------

Build mruby with mruby-dir-glob gem

From old `build_config.rb`:

```text
Recommended way to customize the build configuration is:
 * copy `default.rb` (or any config file) to a new file (e.g. `myconfig.rb`)
 * edit `myconfig.rb`.
 * `rake MRUBY_CONFIG=/path/to/myconfig.rb` to compile and test.
 * or `rake MRUBY_CONFIG=myconfig` if your configuration file is in the `build_config` directory.
 * (optional) submit your configuration as a pull-request if it's useful for others
```

```ruby
MRuby::Build.new do |conf|
  # load specific toolchain settings
  conf.toolchain

  # include the GEM box
  conf.gembox 'default'

  conf.gem :mgem => 'mruby-dir-glob'

  # Turn on `enable_debug` for better debugging
  # conf.enable_debug

  conf.enable_bintest
  conf.enable_test
end
```



--------------------------------------------------------------------------------


# Docker in Docker the Hard Way

[How to install Docker on Ubuntu 22.04?](https://lucidar.me/en/docker/how-to-install-docker-on-ubuntu-22-04/)

### Install the Docker repository

```sh
apt-get --yes remove docker docker.io containerd runc
apt-get --yes install ca-certificates curl gnupg lsb-release
mkdir -p /etc/apt/keyrings

# Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up the repository

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
```

### Install Docker

```sh
apt-get --yes install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

### Hello World test

```sh
docker run hello-world
```

FAIL


apt --yes install ip6tables iptables