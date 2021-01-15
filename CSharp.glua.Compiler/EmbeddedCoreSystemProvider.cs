using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.Text.RegularExpressions;
using CSharp.glua.CoreSystem;

namespace CSharp.glua {
  public sealed class EmbeddedCoreSystemProvider : ICoreSystemProvider {
    private static readonly Regex CoreSystemFileNameRegex = new(@"^CSharp\.glua\.CoreSystem\.(?<name>[\w._-]+)\.lua$",
      RegexOptions.ExplicitCapture | RegexOptions.Compiled | RegexOptions.Singleline | RegexOptions.RightToLeft);
    private readonly Dictionary<string, string> CoreSystemFiles;

    public EmbeddedCoreSystemProvider() {
      CoreSystemFiles = new();
    }

    bool ICoreSystemProvider.Initialize() {
      var executingAssembly = Assembly.GetExecutingAssembly();
      foreach (var resourceName in executingAssembly.GetManifestResourceNames()) {
        var match = CoreSystemFileNameRegex.Match(resourceName);
        if (match.Success) {
          using var stream = executingAssembly.GetManifestResourceStream(resourceName);
          if (stream is not null) {
            using var streamReader = new StreamReader(stream);
            var readToEnd = streamReader.ReadToEnd();
            CoreSystemFiles[match.Groups["name"].Value] = readToEnd;
          }
        }
      }

      return true;
    }

    (string, string) ICoreSystemProvider.Read(params string[] path) {
      var name = String.Join('.', path);
      //return CoreSystemFiles.TryGetValue(name, out var value) ? value : null;
      return (name, CoreSystemFiles[name]);
    }
  }
}
