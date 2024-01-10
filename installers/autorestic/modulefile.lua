help(myModuleName())
local base = pathJoin(
  "/sw/contrib",
  string.gsub(myModuleName(), "/.*$", "-src"),
  string.gsub(myModuleName(), "^.*/", ""),
  myModuleVersion()
)
whatis("Name: " .. myModuleName())
whatis("Version: " .. myModuleVersion())
prepend_path("PATH", pathJoin(base, "bin"))
depends_on("escience/restic")
