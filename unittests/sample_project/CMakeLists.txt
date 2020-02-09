cmake_minimum_required(VERSION 3.2)
project(sample_cmake)

include(config.cmake)
set(SAMPLE_CONFIG "Sample_settings" CACHE STRING "lmao 2 nova")
set_property(CACHE SAMPLE_CONFIG PROPERTY STRINGS Sample_settings sample1 sample2)
add_executable(sample_executable sample.cpp)

