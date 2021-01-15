using System;
using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;
using System.IO;
using System.Linq;
using System.Text.Json;
using System.Text.Json.Serialization;
using CSharp.glua.CoreSystem;
using CSharpLua;

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
    /// <param name="postProcess">List of executable programs to be launched during post-processing stage for each generated file</param>
    /// <param name="atts">Attributes to be exported, leave blank to export all</param>
    /// <param name="enums">Enumerations to be exported, leave blank to export all</param>
    /// <param name="enumAsReference">Specify `<c>true</c>` to use variable-referenced enumerations instead of constant values</param>
    /// <param name="metadata">Specify `<c>true</c>` to export all metadata, use `<c>@CSharpLua.Metadata</c>` annotations for precise control</param>
    /// <param name="module">Specify `<c>true</c>` to compile as a module (the compiled assembly would need to be referenced)</param>
    /// <param name="inlineProperty">Specify `<c>true</c>` to inline single-line properties (if possible)</param>
    /// <param name="mode">Specify the default target environment</param>
    /// <returns>Process exit code (zero if successful; otherwise non-zero).</returns>
    private static int Main(
      FileSystemInfo? input,
      DirectoryInfo? output = null,
      DirectoryInfo? include = null,
      HashSet<FileInfo>? libs = null,
      HashSet<FileInfo>? metas = null,
      List<string>? csc = null,
      List<string>? postProcess = null,
      HashSet<string>? atts = null,
      HashSet<string>? enums = null,
      bool enumAsReference = false,
      bool metadata = false,
      bool module = false,
      bool inlineProperty = false,
      EnvironmentMode mode = EnvironmentMode.GLua
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
        foreach (var fileInfo in libs.Select(
          fileInfo => fileInfo.Name[^1] == '!'
            ? new(fileInfo.FullName[..^2])
            : fileInfo)
        ) {
          if (!fileInfo.Exists) ExitWithError(5, $"Library file not found: {fileInfo.FullName}");
          libFiles.Add(fileInfo.FullName);
        }

        return String.Join(';', libFiles);
      }

      string? GetMetaArgument() {
        if (metas is null) return null;
        if (metas.IsEmpty()) ExitWithError(4, "No meta files given");

        var metaFiles = new HashSet<string>(metas.Count);
        foreach (var fileInfo in metas) {
          if (!fileInfo.Exists) ExitWithError(5, $"Meta file not found: {fileInfo.FullName}");
          metaFiles.Add(fileInfo.FullName);
        }

        return String.Join(';', metaFiles);
      }

      void AppendStarfallCompilerOption() {
        csc ??= new List<string>(3);
        csc.Add("-define:STARFALL");
        csc.Add("-define:CLIENT");
        csc.Add("-define:SERVER");
      }

      FileInfo GetConfigFileName() {
        const string ConfigFileName = ".dnglua-config";
        return new(Path.Combine(
          input!.Attributes.HasFlag(FileAttributes.Directory)
            ? input.FullName
            : Path.GetDirectoryName(input.FullName)!,
          ConfigFileName));
      }

      var starfallMode = mode == EnvironmentMode.Starfall;
      if (input.IsNullOrDoesNotExist()) ExitWithError(1, "Invalid --input argument");
      if (starfallMode) AppendStarfallCompilerOption();

      try {
        // Note: Command-line arguments have higher precedence than project-specific configuration.
        ICoreSystemProvider? coreSystemProvider = include is null ? null : new FileCoreSystemProvider(include.FullName);
        {
          var config = Json.Config.FromFile(GetConfigFileName());
          if (config is not null) {
            if (!String.IsNullOrEmpty(config.Output)) { // Let output in config to bypass the precedence rule.
              output = new DirectoryInfo(Environment.ExpandEnvironmentVariables(config.Output));
            }

            var singleFile = config.SingleFile;
            if (singleFile is not null) {
              if (singleFile.Enabled && coreSystemProvider is null) {
                coreSystemProvider = String.IsNullOrEmpty(singleFile.Include)
                  ? new EmbeddedCoreSystemProvider()
                  : new FileCoreSystemProvider(singleFile.Include);
              }
            }

            postProcess ??= config.PostProcess;
          }
        }
        if (output.IsNotNullAndDoesNotExist()) ExitWithError(2, "Invalid --output argument");
        if (coreSystemProvider?.Initialize() == false) ExitWithError(3, "Invalid --include argument");

        {
          var compiler = new Compiler(
            input: input!.FullName,
            output: output?.FullName ?? Directory.GetCurrentDirectory(),
            lib: GetLibsArgument(),
            meta: GetMetaArgument(),
            csc: csc is null ? null : String.Join(' ', csc),
            isClassic: true,
            atts: atts is null ? String.Empty : String.Join(';', atts),
            enums: enums is null ? String.Empty : String.Join(';', enums)
          ) {
            Include = coreSystemProvider,
            IsCommentsDisabled = true,
            IsDecompilePackageLibs = true,
            IsExportMetadata = metadata,
            IsInlineSimpleProperty = inlineProperty,
            IsModule = module,
            IsNotConstantForEnum = enumAsReference,
            IsPreventDebugObject = starfallMode,
            PostProcess = postProcess
          };
          const string LuaVersion = "Lua 5.1";
          compiler.Compile(module, LuaVersion);
        }
      } catch (Exception ex) {
        ExitWithError(-1, String.Join(Environment.NewLine, ex.Message, ex.StackTrace));
      }

      return 0;
    }
  }

  internal enum EnvironmentMode { GLua, Starfall }

  namespace Json {
    internal sealed record Config(
      string? Output,
      SingleFile? SingleFile,
      List<string>? PostProcess
    ) {
      public static Config? FromJson(string json)
        => JsonSerializer.Deserialize<Config>(json, Converter.Settings);

      public static Config? FromFile(FileInfo fileInfo)
        => fileInfo.Exists ? FromJson(File.ReadAllText(fileInfo.FullName)) : null;

      public string ToJson()
        => JsonSerializer.Serialize(this, Converter.Settings);
    }

    internal sealed record SingleFile(bool Enabled, string? Include);

    internal static class Converter {
      internal static JsonSerializerOptions Settings { get; } = new() {
        AllowTrailingCommas = true,
        WriteIndented = true,
        ReadCommentHandling = JsonCommentHandling.Skip,
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        DefaultIgnoreCondition = JsonIgnoreCondition.Never,
        IgnoreNullValues = true,
        IncludeFields = false,
        IgnoreReadOnlyFields = true,
        //IgnoreReadOnlyProperties = true
      };
    }
  }

  internal static class Extensions {
    internal static bool IsNullOrDoesNotExist(this FileSystemInfo? @this) => @this is null || !@this.Exists;

    internal static bool IsNotNullAndDoesNotExist(this FileSystemInfo? @this) => @this is not null && !@this.Exists;

    internal static bool IsEmpty<T>(this ISet<T> @this) => @this.Count == 0;
  }
}
