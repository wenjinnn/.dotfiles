-- nvim debug
return {
  'mfussenegger/nvim-dap',
  cond = not vim.g.vscode,
  config = function()
    local dap = require('dap')
    -- dap.defaults.fallback.terminal_win_cmd = 'enew'
    dap.defaults.fallback.terminal_win_cmd = function ()
      local Terminal = require('toggleterm.terminal').Terminal
      local new_term = Terminal:new({
        -- start zsh without rc file
        env = { ['IS_NVIM_DAP_TOGGLETERM'] = 1},
        clear_env = true
      })
      new_term:toggle()
      return new_term.bufnr, new_term.window
    end
  end
}
-- all about launch.json options

-- ### Launch

-- - `mainClass` - The fully qualified name of the class containing the main method. If not specified, the debugger automatically resolves the possible main class from current project.
--   - `${file}` - Current Java file.
--   - `com.mypackage.Main` - The fully qualified class name.
--   - `com.java9.mymodule/com.mypackage.Main` - The fully qualified module name and class name.
--   - `/path/to/Main.java` - The file path of the main class.
-- - `args` - The command line arguments passed to the program.
--   - `"${command:SpecifyProgramArgs}"` - Prompt user for program arguments.
--   - A space-separated string or an array of string.
-- - `sourcePaths` - The extra source directories of the program. The debugger looks for source code from project settings by default. This option allows the debugger to look for source code in extra directories.
-- - `modulePaths` - The modulepaths for launching the JVM. If not specified, the debugger will automatically resolve from current project. If multiple values are specified, the debugger will merge them together.
--   - `$Auto` - Automatically resolve the modulepaths of current project.
--   - `$Runtime` - The modulepaths within 'runtime' scope of current project.
--   - `$Test` - The modulepaths within 'test' scope of current project.
--   - `!/path/to/exclude` - Exclude the specified path from modulepaths.
--   - `/path/to/append` - Append the specified path to the modulepaths.
-- - `classPaths` - The classpaths for launching the JVM. If not specified, the debugger will automatically resolve from current project. If multiple values are specified, the debugger will merge them together.
--   - `$Auto` - Automatically resolve the classpaths of current project.
--   - `$Runtime` - The classpaths within 'runtime' scope of current project.
--   - `$Test` - The classpaths within 'test' scope of current project.
--   - `!/path/to/exclude` - Exclude the specified path from classpaths.
--   - `/path/to/append` - Append the specified path to the classpaths.
-- - `encoding` - The `file.encoding` setting for the JVM. Possible values can be found in https://docs.oracle.com/javase/8/docs/technotes/guides/intl/encoding.doc.html.
-- - `vmArgs` - The extra options and system properties for the JVM (e.g. -Xms\<size\> -Xmx\<size\> -D\<name\>=\<value\>), it accepts a string or an array of string.
-- - `projectName` - The preferred project in which the debugger searches for classes. There could be duplicated class names in different projects. This setting also works when the debugger looks for the specified main class when launching a program. It is required when the workspace has multiple java projects, otherwise the expression evaluation and conditional breakpoint may not work.
-- - `cwd` - The working directory of the program. Defaults to `${workspaceFolder}`.
-- - `env` - The extra environment variables for the program.
-- - `envFile` - Absolute path to a file containing environment variable definitions.
-- - `stopOnEntry` - Automatically pause the program after launching.
-- - `console` - The specified console to launch the program. If not specified, use the console specified by the `java.debug.settings.console` user setting.
--   - `internalConsole` - VS Code debug console (input stream not supported).
--   - `integratedTerminal` - VS Code integrated terminal.
--   - `externalTerminal` - External terminal that can be configured in user settings.
-- - `shortenCommandLine` - When the project has long classpath or big VM arguments, the command line to launch the program may exceed the maximum command line string limitation allowed by the OS. This configuration item provides multiple approaches to shorten the command line. Defaults to `auto`.
--   - `none` - Launch the program with the standard command line 'java [options] classname [args]'.
--   - `jarmanifest` - Generate the classpath parameters to a temporary classpath.jar file, and launch the program with the command line 'java -cp classpath.jar classname [args]'.
--   - `argfile` - Generate the classpath parameters to a temporary argument file, and launch the program with the command line 'java @argfile [args]'. This value only applies to Java 9 and higher.
--   - `auto` - Automatically detect the command line length and determine whether to shorten the command line via an appropriate approach.
-- - `stepFilters` - Skip specified classes or methods when stepping.
--   - `classNameFilters` - [**Deprecated** - replaced by `skipClasses`] Skip the specified classes when stepping. Class names should be fully qualified. Wildcard is supported.
--   - `skipClasses` - Skip the specified classes when stepping.
--     - `$JDK` - Skip the JDK classes from the default system bootstrap classpath, such as rt.jar, jrt-fs.jar.
--     - `$Libraries` - Skip the classes from application libraries, such as Maven, Gradle dependencies.
--     - `java.*` - Skip the specified classes. Wildcard is supported.
--     - `java.lang.ClassLoader` - Skip the classloaders.
--   - `skipSynthetics` - Skip synthetic methods when stepping.
--   - `skipStaticInitializers` - Skip static initializer methods when stepping.
--   - `skipConstructors` - Skip constructor methods when stepping.
--
-- ### Attach
--
-- - `hostName` (required, unless using `processId`) - The host name or IP address of remote debuggee.
-- - `port` (required, unless using `processId`) - The debug port of remote debuggee.
-- - `processId` - Use process picker to select a process to attach, or Process ID as integer.
--   - `${command:PickJavaProcess}` - Use process picker to select a process to attach.
--   - an integer pid - Attach to the specified local process.
-- - `timeout` - Timeout value before reconnecting, in milliseconds (default to 30000ms).
-- - `sourcePaths` - The extra source directories of the program. The debugger looks for source code from project settings by default. This option allows the debugger to look for source code in extra directories.
-- - `projectName` - The preferred project in which the debugger searches for classes. There could be duplicated class names in different projects. It is required when the workspace has multiple java projects, otherwise the expression evaluation and conditional breakpoint may not work.
-- - `stepFilters` - Skip specified classes or methods when stepping.
--   - `classNameFilters` - [**Deprecated** - replaced by `skipClasses`] Skip the specified classes when stepping. Class names should be fully qualified. Wildcard is supported.
--   - `skipClasses` - Skip the specified classes when stepping.
--     - `$JDK` - Skip the JDK classes from the default system bootstrap classpath, such as rt.jar, jrt-fs.jar.
--     - `$Libraries` - Skip the classes from application libraries, such as Maven, Gradle dependencies.
--     - `java.*` - Skip the specified classes. Wildcard is supported.
--     - `java.lang.ClassLoader` - Skip the classloaders.
--   - `skipSynthetics` - Skip synthetic methods when stepping.
--   - `skipStaticInitializers` - Skip static initializer methods when stepping.
--   - `skipConstructors` - Skip constructor methods when stepping.
