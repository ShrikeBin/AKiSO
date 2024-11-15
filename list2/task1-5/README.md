## Exercise 1 - /dev /proc /sys dd and hexdump

Task: (5pt) Wytłumacz jakie pliki zawierają katalogi /dev, /proc oraz /sys. Wykorzystując polecenie dd odczytaj pierwszy sektor z dysku głównego (uwaga na prawa dostępu) lub podpiętego pendrive'a i wyświetl przez hexdump -C. Z katalogu proc wyświetl informacje o pamięci, procesorze i partycjach.

### /dev

List all files in `/dev` directory:

```bash
ls /dev
```

Inside the `/dev` (device) directory there are file descriptors of devices. They can be accessed by the system and are used to communicate with the hardware:

- `stdin, stdout, stderr` - standard input, output, error
- `sda, nvme` - hard drives
- `tty` - terminal devices
- `vcs, vcsa, vcsu` - virtual console memory
- `random, urandom` - random number generators
- `/dev/net/tun` - TUN/TAP virtual network device
- `null` - a device that discards all data written to it
- `zero` - a device that provides null bytes when read

### /proc

Inside the `/proc` (process) directory there are files containing process (incl. system process) information:

- `<number>` - process information by PID
- `cpuinfo` - CPU information
- `meminfo` - memory information
- `uptime` - system uptime

### /sys

Inside the `/sys` (system) directory there are files containing system information:

- `block` - block devices
- `bus` - buses
- `class` - device classes
- `devices` - devices
- `firmware` - firmware
- `fs` - filesystems
- `kernel` - kernel
- `module` - kernel modules
- `power` - power management

### Read first sector of a disk using dd

Log to stdout the first sector of a disk:

```bash
# mntd as /
dd if=/dev/nvme0n1p4 of=/dev/stdout 2> /dev/null bs=512 count=1 status=progress
```

Output (LUKS partition):

```bash
LUKS [...] @sha256 [...]
1+0 records in
1+0 records out
512 bytes copied, 4.4091e-05 s, 11.6 MB/s
```

### Hexdump -C of the first sector of a disk

Log to stdout the first sector of a disk in hexadecimal format:

```bash
# mntd as /
dd if=/dev/nvme0n1p4 bs=512 count=1 | hexdump -C

# OUTPUT (EFI partition mntd as /efi)
# 1+0 records in
# 1+0 records out
# 512 bytes copied, 5.4618e-05 s, 9.4 MB/s
# 00000000  eb 58 90 6d 6b 66 73 2e  66 61 74 00 02 08 20 00  |.X.mkfs.fat... .|
# 00000010  02 00 00 00 00 f8 00 00  20 00 40 00 00 08 00 00  |........ .@.....|
# 00000020  00 00 10 00 00 04 00 00  00 00 00 00 02 00 00 00  |................|
# 00000030  01 00 06 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
# 00000040  80 01 29 7d 56 47 99 4e  4f 20 4e 41 4d 45 20 20  |..)}VG.NO NAME  |
# 00000050  20 20 46 41 54 33 32 20  20 20 0e 1f be 77 7c ac  |  FAT32   ...w|.|
# 00000060  22 c0 74 0b 56 b4 0e bb  07 00 cd 10 5e eb f0 32  |".t.V.......^..2|
# 00000070  e4 cd 16 cd 19 eb fe 54  68 69 73 20 69 73 20 6e  |.......This is n|
# 00000080  6f 74 20 61 20 62 6f 6f  74 61 62 6c 65 20 64 69  |ot a bootable di|
# 00000090  73 6b 2e 20 20 50 6c 65  61 73 65 20 69 6e 73 65  |sk.  Please inse|
# 000000a0  72 74 20 61 20 62 6f 6f  74 61 62 6c 65 20 66 6c  |rt a bootable fl|
# 000000b0  6f 70 70 79 20 61 6e 64  0d 0a 70 72 65 73 73 20  |oppy and..press |
# 000000c0  61 6e 79 20 6b 65 79 20  74 6f 20 74 72 79 20 61  |any key to try a|
# 000000d0  67 61 69 6e 20 2e 2e 2e  20 0d 0a 00 00 00 00 00  |gain ... .......|
# 000000e0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
```

### List memory, cpu and disk partitions with /proc

```bash
cat /proc/meminfo
cat /proc/cpuinfo
cat /proc/partitions
```

## Exercise 2 - ps

Task: (5pt) Zapoznaj się z programem ps (man ps). Naucz się posługiwać tym programem, aby umieć sprawdzać co najmniej istnienie i parametry wybranych procesów (PID procesu i rodzica, stan procesu, priorytet, nice, ilość pamięci, zużycie czasu procesora). Uruchom też kilka terminali pokaż jakie urządzenie tty wykorzystują. Wykonując komendę ps axjf pokaż wszystkie procesy które podpięte są do tych terminali (kolumna TTY).

Read `ps` man page:

```bash
man ps
```

## `ps` filters

- Show all processes

```bash
ps -ef # show all processes
```

- Show process information

```bash

ps -q 3496
# PID TTY          TIME CMD
# 3496 ?        00:00:11 Discord
```

- Show parent PID

```bash
ps -q 3496 -o pid,ppid
# PID    PPID COMMAND
# 3496    1458 Discord
```

- Show process state

```bash
ps -q 3496 -o comm,state
# PID    PPID COMMAND
# 3496    1458 Discord
```

- Show process priority

```bash
ps -q 3496 -o comm,pri
# COMMAND         PRI
# Discord          19
```

- Show process nice

```bash
ps -q 3496 -o comm,nice
# COMMAND          NI
# Discord           0
```

- Show memory usage

```bash
ps -q 3496 -o comm,vsz,rss
# COMMAND            VSZ   RSS
# Discord         1212462624 210596
```

- Show CPU time usage

```bash
ps -q 3496 -o comm,time
# COMMAND             TIMEs
# Discord         00:00:12
```

## Show tty devices

```bash
ps axjf
```

I have created four gnome terminals each of them is attached to a different tty device:

```bash
[uni] ps
PID TTY          TIME CMD
7001 pts/0    00:00:02 zsh
25902 pts/0    00:00:00 ps

[uni] ps axjf
6196    7001    7001    7001 pts/0      26143 Ss    1000   0:02  |   |   \_ /usr/bin/zsh -i
7001   26143   26143    7001 pts/0      26143 R+    1000   0:00  |   |       \_ ps axjf
```

As we can see, the gnome terminal is attached to the `pts/0` device which is a pseudo-terminal and runs the `zsh` shell and my command.


## Exercise 4 - `jobs`, `fg`, `bg`, `kill`

Task: (5pt) Pokaż na przykładzie (np. sleep 1000, sleep 1001, ...) zarządzanie zadaniami wykorzystując \<polecenie\> & - uruchamianie w tle (background) oraz jobs, fg, bg, kill oraz ^Z. Uruchom kilka zadań w tle i pokaż jak można nimi zarządzać, czyli zatrzymywać, wznawiać oraz kończyć ich działanie. Pokaż jak uruchomione zadanie (nie w tle), można w czasie działania uruchomić w tle np. wykonując komendę sleep 100 (bez &) w czasie działanie przełącz je do działania w tle.

Run a few `sleep` commands in the background:

```bash
sleep 1000 &
sleep 1001 &
sleep 1002 &
```

List all background jobs:

```bash
jobs
[1]    running    sleep 1000
[2]  - running    sleep 1001
[3]  + running    sleep 1002
```

The + sign indicates the current job, the - sign indicates the previous job.

Stop the job with `^Z`:

```bash
^Z
[1]+  Suspended                 sleep 1002
```

List all jobs:

```bash
jobs
[1]  + suspended    sleep 1000
[2]  - suspended    sleep 1001
[3]  + suspended    sleep 1002
```

Resume the job with `fg`:

```bash
fg %1 # zsh uses %i for the i-th job
```

Resume the job in the background with `bg`:

```bash
bg %1
```

Run a job then suspend it and run it in the background:

```bash
sleep 100 # ^Z to suspend
jobs
bg %1
```

## Exercise 5 - `mkfifo`

Task: (5pt) Poleceniem mkfifo (man mkfifo) utwórz potok nazwany (ang. named FIFO). Wywołując polecenie cat w różnych terminalach spowoduj wpisywanie danych do potoku przez jeden(ne) proces(y), i odczytywanie i wyświetlanie ich przez inne. Zaobserwuj, kiedy polecenie cat czytające z potoku czeka na więcej danych, a kiedy kończy pracę. Analogicznie, kiedy czeka na więcej danych (z klawiatury) polecenie cat piszące do potoku?

```bash
mkfifo newfifo
cat newfifo
cat > newfifo
```

`cat newfifo` czeka gdy potok jest pusty i nie ma danych do odczytu.
`cat > newfifo` czeka, gdy nie wprowadziłem danych.
