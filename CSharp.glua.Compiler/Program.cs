using System;
using System.IO;

namespace CSharp.glua.Compiler {
  internal static class Program {
    private static int Main(FileInfo projectFile, DirectoryInfo outputDir) {
      if (projectFile.IsNullOrDoesNotExist()) {
        Console.Error.WriteLine("Invalid argument value for --project-file");
        return 1;
      }
      if (outputDir.IsNullOrDoesNotExist()) {
        Console.Error.WriteLine("Invalid argument value for --output-dir");
        return 2;
      }

      Console.Out.WriteLine($"The value for --output-dir is: {outputDir.FullName}");
      // TODO
      //Path.Combine(outputDir.FullName, "out.lua");

      return 0;
    }
  }

  internal static class Extensions {
    internal static bool IsNullOrDoesNotExist(this FileSystemInfo @this) {
      return @this is null || !@this.Exists;
    }
  }
}
