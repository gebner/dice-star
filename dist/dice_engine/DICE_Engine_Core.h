/* Automatically generated by the Kremlin tool */



#ifndef __DICE_Engine_Core_H
#define __DICE_Engine_Core_H

#if defined(__cplusplus)
extern "C" {
#endif

#include "HWState.h"
#include "HWAbstraction.h"
#include "krml/internal/types.h"
#include "krml/lowstar_endianness.h"
#include "LowStar_Printf.h"
#include <string.h>

typedef void *l0_image_is_valid;

bool authenticate_l0_image(HWState_l0_image_t img);

typedef void *cdi_functional_correctness;

#define DICE_SUCCESS 0
#define DICE_ERROR 1

typedef uint8_t dice_return_code;

bool uu___is_DICE_SUCCESS(dice_return_code projectee);

bool uu___is_DICE_ERROR(dice_return_code projectee);

typedef void *all_heap_buffers_except_cdi_and_ghost_state_remain_same;

dice_return_code dice_main(void);

#if defined(__cplusplus)
}
#endif

#define __DICE_Engine_Core_H_DEFINED
#endif
