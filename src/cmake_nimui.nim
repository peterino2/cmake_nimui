# This is just an example to get you started. A typical binary package
# uses this file as the main entry point of the application.

import os
import osproc
import tables
import parseopt

let cmake_project_path = "unittests/sample_project"
let temp_build_path = ".cmake_nimui_buildtest"

proc cmake_reset() =
    os.removeDir(".cmake_nimui_buildtest")

proc cmake_parse(project_path: string): void =
    
    let cmake_contents = os.joinPath(project_path, "CMakeLists.txt").readfile();
    echo(cmake_contents)
    os.createDir(temp_build_path)
    let abs_project_path = project_path.absolutePath().normalizedPath()
    let cmake_lh = osproc.execProcess("cmake -LH " & abs_project_path, working_dir=temp_build_path)
    let what_is_this = {
            "what the fuck" : 1,
            "lmao" : "lmao"
        }
    echo(what_is_this.type)
    
    echo(cmake_lh)
    
when isMainModule:
    echo("Hello, World!")
    
    # 1. Parse the cmakeLists and extract into a data structure
    cmake_parse(cmake_project_path)
    
