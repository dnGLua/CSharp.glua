using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.Text.RegularExpressions;
using CSharp.glua.CoreSystem;

namespace CSharp.glua {
  internal sealed class EmbeddedCoreSystemProvider : CoreSystemProvider {
    private static readonly Regex CoreSystemFileNameRegex = new(@"^CSharp\.glua\.CoreSystem\.(?<name>[\w._-]+)\.lua$",
      RegexOptions.ExplicitCapture | RegexOptions.Compiled | RegexOptions.Singleline | RegexOptions.RightToLeft);
    private readonly Dictionary<string, string> coreSystemContent;

    public EmbeddedCoreSystemProvider() {
      coreSystemContent = new();
    }

    public override string this[string name] => coreSystemContent[name];

    public override bool Initialize() {
      var executingAssembly = Assembly.GetExecutingAssembly();
      foreach (var resourceName in executingAssembly.GetManifestResourceNames()) {
        var match = CoreSystemFileNameRegex.Match(resourceName);
        if (match.Success) {
          using var stream = executingAssembly.GetManifestResourceStream(resourceName);
          if (stream is not null) {
            using var streamReader = new StreamReader(stream);
            var readToEnd = streamReader.ReadToEnd();
            coreSystemContent[match.Groups["name"].Value] = readToEnd;
          }
        }
      }
      return true;
    }

    public override string PathToName(params string[] path) => String.Join('.', path);
  }
}
