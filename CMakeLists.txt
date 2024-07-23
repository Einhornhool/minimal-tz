cmake_minimum_required(VERSION 3.10)

project(minimal_tz VERSION 0.1 LANGUAGES C ASM)

set(TOOLCHAINPATH /home/lena/apps/gcc-arm-11.2-2022.02-x86_64-arm-none-eabi/bin)

set(CMAKE_BUILD_TYPE    Debug)
set(CMAKE_C_COMPILER    ${TOOLCHAINPATH}/arm-none-eabi-gcc)
set(CMAKE_ASM_COMPILER  ${TOOLCHAINPATH}/arm-none-eabi-gcc)

set(SECURE_ELF_NAME         "secure.elf")
set(NON_SECURE_ELF_NAME     "non-secure.elf")
set(NRFXPATH    "${PROJECT_SOURCE_DIR}/3rd_party/nrfx")
set(CMSISPATH   "${PROJECT_SOURCE_DIR}/3rd_party/CMSIS_5/CMSIS")

set(NSC_LIB         "${CMAKE_BINARY_DIR}/nsc_lib.o")
set(MAP_FILE        "${CMAKE_BINARY_DIR}/${PROJECT_NAME}.map")

set(FLAGS
    "-mcpu=cortex-m33"
    "-mthumb"
    "-mfloat-abi=hard"
    "-mabi=aapcs"
    "-mfpu=fpv5-sp-d16"
)

set(CFLAGS
    "-std=c99"
    "-Wall"
    "-Werror"
)

set(SOURCES_ASM
    ${NRFXPATH}/mdk/gcc_startup_nrf9160.S
)

set_source_files_properties(${SOURCES_ASM}
    PROPERTIES
    COMPILE_FLAGS
    ${FLAGS}
    "-x"
    "assembler-with-cpp"
)

add_compile_definitions(
    NRF9160_XXAA
    FLOAT_ABI_HARD
)

include_directories(
    ${CMSISPATH}/Core/Include
    ${NRFXPATH}
    ${NRFXPATH}/templates
    ${NRFXPATH}/mdk
    ${NRFXPATH}/hal
    ${NRFXPATH}/drivers/include
)

add_subdirectory(secure)
add_subdirectory(non-secure)
