using System;
using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;
using System.IO;

namespace CSharp.glua {
  internal static class CLI {
    /// <summary>
    /// <para>Transpiles C# into Garry's Mod Lua or Starfall.</para>
    /// https://github.com/dnGLua/CSharp.glua
    /// </summary>
    /// <param name="input">Input csproj file (or directory with C# source code files)</param>
    /// <param name="output">Output directory (where to save the generated Lua code)</param>
    /// <param name="include">Root directory of the CoreSystem library. If specified, the transpiler will output a single file</param>
    /// <param name="libs">Optional library file(s). If the library is a module (which is compiled using `--module` argument), the last character must be `!` in order to mark</param>
    /// <param name="metas">Optional meta file(s). For example, use this to specify custom `System.xml`</param>
    /// <param name="csc">Additional C# compiler command-line arguments</param>
    /// <param name="atts">Attributes to be exported, leave blank to export all</param>
    /// <param name="enums">Enumerations to be exported, leave blank to export all</param>
    /// <param name="enumAsReference">Specify `<c>true</c>` to use variable-referenced enumerations instead of constant values</param>
    /// <param name="metadata">Specify `<c>true</c>` to export all metadata, use `<c>@CSharpLua.Metadata</c>` annotations for precise control</param>
    /// <param name="module">Specify `<c>true</c>` to compile as a module (the compiled assembly would need to be referenced)</param>
    /// <param name="inlineProperty">Specify `<c>true</c>` to inline single-line properties (if possible)</param>
    /// <param name="starfallMode">Specify `<c>true</c>` to target Starfall environment. By default, GLua environment is used</param>
    /// <returns>Process exit code (zero if successful; otherwise non-zero).</returns>
    private static int Main(
      FileSystemInfo input,
      DirectoryInfo? output = null,
      DirectoryInfo? include = null,
      HashSet<FileInfo>? libs = null,
      HashSet<FileInfo>? metas = null,
      string[]? csc = null,
      HashSet<string>? atts = null,
      HashSet<string>? enums = null,
      bool enumAsReference = false,
      bool metadata = false,
      bool module = false,
      bool inlineProperty = false,
      bool starfallMode = false
    ) {
      [DoesNotReturn]
      static void ExitWithError(int exitCode, string errorMessage) {
        Console.Error.WriteLine(errorMessage);
        Environment.Exit(Environment.ExitCode = exitCode);
      }

      string? GetLibsArgument() {
        if (libs is null) return null;
        if (libs.IsEmpty()) ExitWithError(4, "No library files given");

        var libFiles = new HashSet<string>(libs.Count);
        foreach (var fileInfo in libs) {
          FileInfo tmpFileInfo =
            fileInfo.Name[^1] == '!'
              ? new(fileInfo.FullName[..^2])
              : fileInfo;
          if (!tmpFileInfo.Exists) {
            ExitWithError(5, $"Library file not found: {tmpFileInfo.FullName}");
          }
          libFiles.Add(tmpFileInfo.FullName);
        }

        return String.Join(';', libFiles);
      }

      string? GetMetaArgument() {
        if (metas is null) return null;
        if (metas.IsEmpty()) ExitWithError(4, "No meta files given");

        var metaFiles = new HashSet<string>(metas.Count);
        foreach (var fileInfo in metas) {
          if (!fileInfo.Exists) {
            ExitWithError(5, $"Meta file not found: {fileInfo.FullName}");
          }
          metaFiles.Add(fileInfo.FullName);
        }

        return String.Join(';', metaFiles);
      }

      if (input.IsNullOrDoesNotExist()) ExitWithError(1, "Invalid --input argument");
      if (output.IsNotNullAndDoesNotExist()) ExitWithError(2, "Invalid --output argument");
      if (include.IsNotNullAndDoesNotExist()) ExitWithError(3, "Invalid --include argument");

      try {
        var compiler = new CSharpLua.Compiler(
          input: input.FullName,
          output: output?.FullName ?? Directory.GetCurrentDirectory(),
          lib: GetLibsArgument(),
          meta: GetMetaArgument(),
          csc: csc is null ? null : String.Join(' ', csc),
          isClassic: true,
          atts: atts is null ? String.Empty : String.Join(';', atts),
          enums: enums is null ? String.Empty : String.Join(';', enums)
        ) {
          Include = include?.FullName,
          IsCommentsDisabled = true,
          IsDecompilePackageLibs = true,
          IsExportMetadata = metadata,
          IsInlineSimpleProperty = inlineProperty,
          IsModule = module,
          IsNotConstantForEnum = enumAsReference,
          IsPreventDebugObject = starfallMode
        };
        const string LuaVersion = "Lua 5.1";
        compiler.Compile(module, LuaVersion);
        /*if (include is null) {
          compiler.Compile(false, LuaVersion);
        } else {
          compiler.CompileSingleFile(Path.Combine(outputDir.FullName, "out.lua"), Array.Empty<string>(), false, LuaVersion);
        }*/
      } catch (Exception ex) {
        ExitWithError(-1, String.Join(Environment.NewLine, ex.Message, ex.StackTrace));
      }

      return 0;
    }
  }

  internal static class Extensions {
    internal static bool IsNullOrDoesNotExist(this FileSystemInfo? @this) => @this is null || !@this.Exists;

    internal static bool IsNotNullAndDoesNotExist(this FileSystemInfo? @this) => @this is not null && !@this.Exists;

    internal static bool IsEmpty<T>(this ISet<T> @this) => @this.Count == 0;
  }
}
