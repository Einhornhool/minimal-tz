/*
 * Copyright (C) Lena Boeckmann
 *
 * This file is subject to the terms and conditions of the GNU GENERAL PUBLIC LICENSE.
 * See the file LICENSE in the top level directory for more details.
 */

/**
 * @file        non_secure_entry.c
 * @brief       These are non-secure entry functions to
 *              configure and toggle LEDs on the secure side
 *
 * @author      Lena Boeckmann <lena.boeckmann@haw-hamburg.de>
 */
#include <arm_cmse.h>
#include "nrfx.h"

void __attribute__((cmse_nonsecure_entry)) config_leds(void)
{
    NRF_P0_S->DIRSET |= (1<<5) | (1<<4) | (1<<3) | (1<<2);
}

void __attribute__((cmse_nonsecure_entry)) led_on(int offset)
{
    NRF_P0_S->OUTSET |= 1<<(offset+2);
}

void __attribute__((cmse_nonsecure_entry)) led_off(int offset)
{
    NRF_P0_S->OUTCLR |= 1<<(offset+2);
}
