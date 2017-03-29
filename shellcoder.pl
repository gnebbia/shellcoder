#!/usr/bin/env perl
#===============================================================================
#
#         FILE: shellcoder.pl
#
#        USAGE: ./shellcoder.pl
#
#  DESCRIPTION:
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: nebg
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 08/05/2016 11:09:05 AM
#     REVISION: ---
#===============================================================================

use Modern::Perl;
use Getopt::Long;
use Config;

use autodie;

main();

sub main {
    my $executable;
    my $asm_source;
    my $is_help_requested;
    my $shellcode_objdump;
    my $file_basename;
    my $os = $Config{archname};

    GetOptions(
        "executable|e=s" => \$executable,
        "asm-source|s=s" => \$asm_source,
        "os|o=s"         => \$os,
        "help|h"         => \$is_help_requested,
      )
      or die usage(
        "Error in command-line arguments, please provide correct parameters");

    usage() and exit if ($is_help_requested);

    ( $executable or $asm_source )
      or die usage("Usage: $0 --executable filename --os linux\n");

    die(
"Cannot specify both asm source and executable, choose only one format..."
    ) if ( $executable and $asm_source );

    if ($executable) {
        $shellcode_objdump = exe_to_objdump($executable);
        $file_basename     = $executable;
    }
    else {
        $shellcode_objdump = asm_to_objdump( $asm_source, $os );
        $file_basename = $asm_source;
    }

    my $c_shellcode = objdump_to_shellcode($shellcode_objdump);

    generate_c_source( $file_basename, $c_shellcode );

    say "shellcode written in file $file_basename.shellcode.c";

    say "shellcode:";
    say $c_shellcode;
}

sub usage {
    my ($error_message) = @_;
    say $error_message if $error_message;
    print <<"EOUSAGE";
This is pershoders (Perl Shell Coder Script), a perl script to create shellcodes.

Usage Example: $0 --asm-source <source_file>

Command Line Arguments:

[--executable] <executable> provide the executable which will be 
			converted into shellcode 

[--asm-source] <asm_source>    specifies the asm source which will
			be transformed into shellcode

[--os]    <operating_system>    specifies for which operating system
			the shellcode will be compiled to (default is current os)

[--help]    show this help

EOUSAGE
}

sub asm_to_objdump {
    my ( $asm_source, $os ) = @_;
    my $objdump;
    for ($os) {
        if ( /i386-linux/ || /linux-32/ ) {
            `nasm -f elf $asm_source -o $asm_source.o`;
            `ld -m elf_i386 $asm_source.o -o $asm_source.out`;
            $objdump =
              `objdump --disassembler-options=intel -d $asm_source.out`;
        }
        elsif ( /x86_64-linux/ || /linux-64/ ) {
            `nasm -f elf64 $asm_source -o $asm_source.o`;
            `ld -m elf_x86_64 $asm_source.o -o $asm_source.out`;
            $objdump =
              `objdump --disassembler-options=intel -d $asm_source.out`;
        }
        elsif ( /win/ || /win-64/ ) {
            `nasm -f win64 $asm_source -o $asm_source.obj`;
            `x86_64-w64-mingw32-ld $asm_source.obj -o $asm_source.exe `;
            $objdump =
              `objdump --disassembler-options=intel -d $asm_source.exe`;
        }
        elsif ( /win32/ || /win-32/ ) {
            `nasm -f win32 $asm_source -o $asm_source.obj`;
            `i686-w64-mingw32-gcc $asm_source.obj -o $asm_source.exe`;
            $objdump =
              `objdump --disassembler-options=intel -d $asm_source.exe`;
        }
    }
    return $objdump;
}

sub exe_to_objdump {
    my ($executable) = @_;
    my $objdump = `objdump --disassembler-options=intel -d $executable`;
    return $objdump;
}

sub objdump_to_shellcode {
    my ($shellcode_objdump) = @_;
    my @hex_lines;
    my @dump_lines =
      grep { /[0-9a-fA-F]+\:\s+([0-9a-fA-F]{2}){1,}\s/ }
      split( '\n', $shellcode_objdump );

    $_ = substr $_, 1 for @dump_lines;

    for (@dump_lines) {
        my @splitted_dump_lines = split( /(\s{2,}|\t)/, $_ );
        $splitted_dump_lines[2] =~ tr/ //ds;
        push @hex_lines, $splitted_dump_lines[2];
    }

    my $shellcode = join( '', @hex_lines );
    my $c_shellcode = join '\x', '', $shellcode =~ /../sg;
    return $c_shellcode;

}

sub generate_c_source {
    my ( $asm_source, $c_shellcode ) = @_;
    my $c_source = <<"END";
/*$asm_source.shellcode.c*/

char *code = "$c_shellcode";
int main(int argc, char **argv)
{
  int (*func)();
  func = (int (*)()) code;
  (int)(*func)();
}
END

    open my $c_shellcode_source, '>', "$asm_source.shellcode.c";
    say $c_shellcode_source $c_source;
    close $c_shellcode_source;
}
