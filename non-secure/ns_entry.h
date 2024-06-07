/*
 * Copyright (C) 2024 Lena Boeckmann
 *
 * This file is subject to the terms and conditions of the GNU GENERAL PUBLIC LICENSE.
 * See the file LICENSE in the top level directory for more details.
 */

/**
 * @file        ns_entry.h
 * @brief
 *
 * @author      Lena Boeckmann <lena.boeckmann@haw-hamburg.de>
 *
 */

#ifndef NS_ENTRY_H
#define NS_ENTRY_H

#ifdef __cplusplus
extern "C" {
#endif

#include <arm_cmse.h>

/**
 * @brief   Configures LEDs 1-4 as outputs
 */
void config_leds(void);

/**
 * @brief   Turn LED on
 *
 * @param   offset  Index of LED to turn on
 */
void led_on(int offset);

/**
 * @brief   Turn LED off
 *
 * @param   offset  Index of LED to turn off
 */
void led_off(int offset);

#ifdef __cplusplus
}
#endif

#endif /* NS_ENTRY_H */
/** @} */
