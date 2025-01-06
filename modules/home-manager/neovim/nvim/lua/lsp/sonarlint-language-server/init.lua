local M = {}
local jdtls_java_home = os.getenv("JDTLS_JAVA_HOME")
local java_home = os.getenv("JAVA_21_HOME")
M.settings = {
  sonarlint = {
    ls = {
      javaHome = jdtls_java_home or java_home or "/usr/lib/jvm/java-17-openjdk/",
    },
  },
}
return M
