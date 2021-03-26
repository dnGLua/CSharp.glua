using System;
using System.IO;
using CSharp.glua.CoreSystem;

namespace CSharp.glua {
  internal sealed class FileCoreSystemProvider : CoreSystemProvider {
    public FileCoreSystemProvider(string includeFolder) {
      IncludeFolder = includeFolder.Length == 0
        ? AppContext.BaseDirectory
        : Environment.ExpandEnvironmentVariables(includeFolder);
    }

    public string IncludeFolder { get; }

    public override string this[string name] => File.ReadAllText(name);

    public override bool Initialize() => Directory.Exists(IncludeFolder);

    public override string PathToName(params string[] path) {
      var name = Path.Combine(path) + ".lua";
      return Path.Combine(IncludeFolder, name);
    }
  }
}
