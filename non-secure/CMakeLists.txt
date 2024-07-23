set(LDSCRIPT_NS  "${CMAKE_CURRENT_SOURCE_DIR}/non-secure.ld")

set(SOURCES_NS
    ${CMAKE_CURRENT_SOURCE_DIR}/main_ns.c
	${NRFXPATH}/mdk/system_nrf9160.c
)

add_executable(${NON_SECURE_ELF_NAME}
    ${SOURCES_NS}
    ${SOURCES_ASM}
)

target_include_directories(${NON_SECURE_ELF_NAME}
    PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_compile_definitions(${NON_SECURE_ELF_NAME}
    PUBLIC
    NRF_TRUSTZONE_NONSECURE
)

target_compile_options(${NON_SECURE_ELF_NAME}
    PUBLIC
    ${FLAGS}
    ${CFLAGS}
)

target_link_options(${NON_SECURE_ELF_NAME}
    PUBLIC
    ${FLAGS}
    "-T${LDSCRIPT_NS}"
    "-Wl,--gc-sections"
    "-Wl,-Map=${MAP_FILE}"
    "--specs=nosys.specs"
    "-L${NRFXPATH}/mdk/"
)

target_link_libraries(${NON_SECURE_ELF_NAME}
    PUBLIC
    ${NSC_LIB}
    "-Wl,--start-group -lgcc -lc -lnosys"
    "-Wl,--end-group"
)
