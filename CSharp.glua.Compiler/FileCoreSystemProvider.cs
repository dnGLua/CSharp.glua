using System;
using System.IO;
using CSharp.glua.CoreSystem;

namespace CSharp.glua {
  internal sealed class FileCoreSystemProvider : ICoreSystemProvider {
    public FileCoreSystemProvider(string includeFolder) {
      IncludeFolder = includeFolder.Length == 0
        ? AppContext.BaseDirectory
        : Environment.ExpandEnvironmentVariables(includeFolder);
    }

    public string IncludeFolder { get; }

    bool ICoreSystemProvider.Initialize()
      => Directory.Exists(IncludeFolder);

    (string, string) ICoreSystemProvider.Read(params string[] path) {
      var name = Path.Combine(path) + ".lua";
      return (name, File.ReadAllText(Path.Combine(IncludeFolder, name)));
    }
  }
}
