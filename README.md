<h1>shellcoder</h1>

shellcoder is a perl application which creates c source shellcodes starting from assembly sources
or executables, it can create both windows and gnu/linux shellcodes and is compatible with
both 32 and 64 bit.

<h3>Installation of shellcoder</h3>

In order to install shellcoder, few dependencies are required, once we have access to a cpan (or cpanm) we do:

```$>cd path/to/shellcoder```

Now we first install cpanminus, I report the command to do it on Debian based GNU/Linux distros:

```$>sudo apt install cpanminus```

```$>cpanm --installdeps . ```

<h3>Usage Examples</h3>

Let's see some usage examples:

<h5>Extracting Shellcode from Linux 64 bit Assembly</h5>

```$>perl shellcoder.pl --os linux-64 --asm-source example.asm```

This will generate a C source file containing the assembly file relative shellcode.


<h5>Show Help</h5>

```$>perl shellcoder.pl --help``` 

This will show a help message, where possible options are shown.

