set(LDSCRIPT_S  "${CMAKE_CURRENT_SOURCE_DIR}/secure.ld")

set(SOURCES_S
    ${CMAKE_CURRENT_SOURCE_DIR}/main_s.c
    ${CMAKE_CURRENT_SOURCE_DIR}/non_secure_entry.c
	${NRFXPATH}/mdk/system_nrf9160.c
)

add_executable(${SECURE_ELF_NAME}
    ${SOURCES_S}
    ${SOURCES_ASM}
)

target_compile_options(${SECURE_ELF_NAME}
    PUBLIC
    ${FLAGS}
    ${CFLAGS}
    "-mcmse"
)

target_link_options(${SECURE_ELF_NAME}
    PUBLIC
    ${FLAGS}
    "-T${LDSCRIPT_S}"
    "-Wl,--cmse-implib"
    "-Wl,--out-implib=${NSC_LIB}"
    "-Wl,--gc-sections"
    "-Wl,-Map=${MAP_FILE}"
    "--specs=nosys.specs"
    "-L${NRFXPATH}/mdk/"
)

target_link_libraries(${SECURE_ELF_NAME}
    PUBLIC
    "-Wl,--start-group -lgcc -lc -lnosys"
    "-Wl,--end-group"
)
