/*
 * Copyright (C) 2024 Lena Boeckmann
 *
 * This file is subject to the terms and conditions of the GNU GENERAL PUBLIC LICENSE.
 * See the file LICENSE in the top level directory for more details.
 *
 * The content extends the code posted here:
 * https://devzone.nordicsemi.com/f/nordic-q-a/96093/nrf9160-porting-the-modem-library-to-work-with-bare-metal-application
 */

/**
 * @file        main_s.c
 * @brief
 *
 * @author      Lena Boeckmann <lena.boeckmann@haw-hamburg.de>
 *
 */

#include <stdint.h>
#include <stddef.h>                     // Defines NULL
#include <stdbool.h>                    // Defines true
#include <stdlib.h>                     // Defines EXIT_FAILURE

#include <arm_cmse.h>

#include "nrf_spu.h"
#include "nrfx.h"

const unsigned long TZ_START_NS = 0x10000ul;

typedef int __attribute__((cmse_nonsecure_call)) nsfunc(void);

int main(void)
{
    /* Flash is separated into 32 * 32KB regions.
       The first two (64KB) are secure, all others are NS */
    for (uint32_t i = 2; i < 32; i++) {
        /* Initial value is 0x0001 0101
           NS value is 0x0000 0101 */
        NRF_SPU_S->FLASHREGION[i].PERM &=
            ~(SPU_FLASHREGION_PERM_SECATTR_Msk);
    }

    /* RAM is separated into 32 * 8 KB regions.
       The first 8 are secure, all others are NS */
    for (uint32_t i = 8; i < 32; ++i) {
        /* Initial value is 0x0001 0101
           NS value is 0x0000 0101 */
        NRF_SPU_S->RAMREGION[i].PERM &=
            ~(SPU_RAMREGION_PERM_SECATTR_Msk);
    }

    /* NSC flash region need to be configured at the
       end of the last flash region.
       There are two possible NSC regions, so
       flash_nsc_id can be 0 or 1. We only have one
       region, so it needs to be 0 */
    int flash_nsc_id = 0;
    int flash_region = 1;

    /* We cofigure the end of flash region 1 as NSC
       NSC region is 32B, which is the smalles possible size */
    NRF_SPU_S->FLASHNSC[flash_nsc_id].REGION = flash_region;
    NRF_SPU_S->FLASHNSC[flash_nsc_id].SIZE = NRF_SPU_NSC_SIZE_32B;

    /* Write NS vector table to SCB_NS->VTOR to be able to jump to NS image*/
    SCB_NS->VTOR = TZ_START_NS;
    uint32_t* vtor = (uint32_t*)TZ_START_NS;
    __TZ_set_MSP_NS(vtor[0]);
    nsfunc *ns_reset_handler = (nsfunc*)(vtor[1]); // Pointer to non-secure Reset_Handler
    ns_reset_handler();

    while ( true )
    {
    }

    /* Execution should not come here during normal operation */
    return ( EXIT_FAILURE );
}
