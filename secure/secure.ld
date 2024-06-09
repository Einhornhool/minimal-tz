/* Linker script to configure memory regions. */

SEARCH_DIR(.)
GROUP(-lgcc -lc -lnosys)

_flash_start = 0x0;
_flash_len = 64K;

_flash_nsc_len = 32;
_flash_nsc_start = _flash_len - _flash_nsc_len;

_ram_start = 0x20000000;
_ram_len = 0x10000;

MEMORY
{
  FLASH (rx) : ORIGIN = _flash_start, LENGTH = _flash_len
  FLASH_NSC (rx) : ORIGIN = _flash_nsc_start, LENGTH = _flash_nsc_len
  RAM (rwx) : ORIGIN = _ram_start, LENGTH = _ram_len
}

INCLUDE "nrf_common.ld"

SECTIONS
{
  .gnu.sgstubs : ALIGN (32)
  {
      . = ALIGN(32);
      *(.gnu.sgstubs*)
      . = ALIGN(32);
  } > FLASH_NSC
}
