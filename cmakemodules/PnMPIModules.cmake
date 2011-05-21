# Copyright (c) 2008, Lawrence Livermore National Security, LLC. 
# Written by Martin Schulz, schulzm@llnl.gov, LLNL-CODE-402774,
# All rights reserved - please read information in "LICENCSE"

# TODO Martin please add the copyright statment of your choice, as well as 
#      a reference to the license or license file!
#
# This files is partially from the MUST project and bears the follwing copyright.
# Copyright (c) 2009, ZIH, Technische Universitaet Dresden, Federal Republic of Germany
# Copyright (c) 2009, LLNL, United States of America
#
# @file PnMPIModules.cmake
#       Contains helpful macros.
#
# @author Tobias Hilbrich
# @date 16.03.2009


# add_pnmpi_module(targetname source1 source2 ... sourceN)
# 
#=============================================================================
# This function adds a PnMPI module to the build and sets flags so that it
# is built and patched properly.
#
function(add_pnmpi_module targetname)
  list(LENGTH ARGN num_sources)
  if (num_sources LESS 1)
    message(FATAL_ERROR "add_pnmpi_module() called with no source files!")
  endif()

  # Add target and its dependency on the patcher
  add_library(${targetname} MODULE ${ARGN})
  
  #For Apple set that undefined symbols should be looked up dynamically
  #(On linux this is already the default)
  if(APPLE)
    set_target_properties(${targetname} PROPERTIES LINK_FLAGS "-undefined dynamic_lookup")
  endif()

  # Patch the library in place once it's built so that it can be installed normally,
  # like any other library.  Also keeps build dir libraries consistent with installed libs.
  get_target_property(lib ${targetname} LOCATION)
  set(tmplib ${targetname}-unpatched.so)

  add_custom_command(TARGET ${targetname} POST_BUILD
    COMMAND mv ${lib} ${tmplib}
    COMMAND pnmpi-patch ${tmplib} ${lib}
    COMMAND rm -f ${tmplib}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Patching ${targetname}"
    VERBATIM)
endfunction()
