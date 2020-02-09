# This is just an example to get you started. A typical binary package
# uses this file as the main entry point of the application.

import os
import osproc
import tables
import strutils
import colors
import terminal 
import argparse
import nimx/window
import nimx/text_field

let cmake_project_path = "unittests/sample_project"
let temp_build_path = ".cmake_nimui_buildtest"
# ------ arguments ------

var p = newParser("cmake_nimui"):
    help("""A program that is mean to assist with cmake project parsing
""")
    option("-v", "--verbosity", help="Sets the verbosity, values are: debug, info, warn")
    option("-l", "--logfile", help="Specify the output logfile")

# ------ Logger Printing ------
type logger_states = enum
    debug, info, warn

var logger_state: logger_states = info

proc logger_debug(s: string) =
    if logger_state == debug:
        echo("[debug ]: " & s)

proc logger_info(s: string) =
    if logger_state >= info:
        echo("[info  ]: " & s)

proc logger_warn(s: string) =
    if logger_state >= warn:
        echo("[warn  ]: " & s)

proc logger_set_verbosity(v: logger_states) =
    logger_state = v

# ------ CMake Parser Statemachine ------
type CM_CacheContext = object 
    vars :Table[string, string]
    name :string

type CMLH_ParserStates = enum
    reset="reset", docstring_found="docstring found"

type CMLH_ParserSM = object
    state :CMLH_ParserStates
    statement :string
    v_docstring :string
    v_name :string
    v_value :string

proc initParserSM(): CMLH_ParserSM = 
    result.state = reset
    result.statement = ""
    result.v_docstring = ""
    result.v_name = ""
    result.v_value = ""

proc showParserSM(p: CMLH_ParserSM) =
    logger_debug("==================================")
    logger_debug("  Parser : state     = " & $p.state)
    logger_debug("         : statement = " & p.statement)
    logger_debug("         : docstring = " & p.v_docstring)
    logger_debug("         : name      = " & p.v_name)
    logger_debug("         : value     = " & p.v_value)
    logger_debug("==================================\n")

proc create_CacheContext(cmake_lh : string, context_name: string): CM_CacheContext =
    var cache_variables = to_table({"cmake_nimui_version": "0.1"})
    let cmake_lh_split = cmake_lh.splitLines()
    var parser_sm = initParserSM()

    for s in cmake_lh_split:
        if parser_sm.state == reset:
            if "//" in s:
                parser_sm.v_docstring = s.replace("// ", "")
                parser_sm.state = docstring_found
                continue

        if parser_sm.state == docstring_found:
            if "=" in s: # condition for completing a commmit
                let s_split = s.split("=")
                parser_sm.v_name = s_split[0]
                parser_sm.v_value = s_split[1]
                parser_sm.state = reset
                parser_sm.showParserSM()
                cache_variables[parser_sm.v_name] = parser_sm.v_value
                continue 

    result.vars = cache_variables
    result.name = context_name

proc cmake_reset() =
    os.removeDir(".cmake_nimui_buildtest")

proc show(context: CM_CacheContext) =
    logger_debug("=================================================")
    logger_debug("CMake Cache context Content: ")
    for key, value in context.vars.pairs:
        logger_debug("") 
        logger_debug("      key   : " & key) 
        logger_debug("      value : " & value)
    logger_debug("=================================================\n")

proc cmake_parse(project_path: string): CM_CacheContext =
    
    #let cmake_contents = os.joinPath(project_path, "CMakeLists.txt").readfile();
    os.createDir(temp_build_path)
    let abs_project_path = project_path.absolutePath().normalizedPath()
    let cmake_lh = osproc.execProcess("cmake -LH " & abs_project_path, working_dir=temp_build_path)

    var context = create_CacheContext(cmake_lh, "main_context")
    result = context

runApplication:
    # ------ main ------
    #when isMainModule:
    echo(commandLineParams())
    let prog_opts = p.parse(commandLineParams())
    try:
        logger_set_verbosity(parseEnum[logger_states](prog_opts.verbosity))
    except:
        logger_set_verbosity(info)

    
    # 1. Parse the cmakeLists and LH and extract into a data structure
    var cache_context = cmake_parse(cmake_project_path)
    cache_context.show()
    var win = newWindow(newRect(40, 40, 800, 600))
    let label = newLabel(newrect(20, 20, 150, 20))
    label.text = "Hello World!"
    win.addSubview(label)

    
