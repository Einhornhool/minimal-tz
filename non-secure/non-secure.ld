/* Linker script to configure memory regions. */

SEARCH_DIR(.)
GROUP(-lgcc -lc -lnosys)

_ns_flash_start = 0x00010000;
_ns_flash_len = 0xF0000;

_ns_ram_start = 0x20016000;
_ns_ram_len = 0x2a000;

MEMORY
{
  FLASH (rx) : ORIGIN = _ns_flash_start, LENGTH = _ns_flash_len
  RAM (rwx) : ORIGIN = _ns_ram_start, LENGTH = _ns_ram_len
}

INCLUDE "nrf_common.ld"
