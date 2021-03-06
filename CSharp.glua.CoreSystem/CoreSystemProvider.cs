using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;

namespace CSharp.glua.CoreSystem {
  public abstract class CoreSystemProvider {
    public abstract string this[string name] { get; }

    private HashSet<string>? excludeCoreSystem;
    public HashSet<string>? ExcludeCoreSystem {
      get => excludeCoreSystem;
      set {
        ExcludeCoreSystemRegexes.Clear();
        if (value is not null) {
          foreach (var str in value.ToArray()) {
            if (str.StartsWith("!", StringComparison.Ordinal)) { // Regex pattern matching mode
              value.Remove(str);
              ExcludeCoreSystemRegexes.Add(new Regex(str[1..]));
            }
          }
        }
        excludeCoreSystem = value;
      }
    }

    private HashSet<Regex> ExcludeCoreSystemRegexes { get; } = new();

    public virtual bool Initialize() => true;

    public virtual bool ShouldRead(params string[] path) {
      if (ExcludeCoreSystem is not null) {
        var id = String.Join('.', path);
        if (ExcludeCoreSystem.Contains(id) || ExcludeCoreSystemRegexes.Any(regex => regex.IsMatch(id))) return false;
      }
      return true;
    }

    public abstract string PathToName(params string[] path);

    public virtual (string name, string code)? Read(params string[] path) {
      if (!ShouldRead(path)) return null;
      var name = PathToName(path);
      //if (String.IsNullOrEmpty(name)) return null;
      return (name, this[name]);
    }

    public IEnumerable<(string name, string code)?> GetCoreSystemFiles() {
      yield return Read("Natives");
      yield return Read("StarfallCompat");
      yield return Read("IsType");
      yield return Read("CSharpCompat");
      yield return Read("HookEx");
      yield return Read("StarfallNet");
      yield return Read("GLuaCompat");
      yield return Read("WireEx");
      yield return Read("Core");
      yield return Read("CoreExLib");
      yield return Read("Interfaces");
      yield return Read("Exception");
      yield return Read("Number");
      yield return Read("Char");
      yield return Read("String");
      yield return Read("Boolean");
      yield return Read("Delegate");
      yield return Read("Enum");
      yield return Read("TimeSpan");
      yield return Read("DateTime");
      yield return Read("Collections", "EqualityComparer");
      yield return Read("Array");
      yield return Read("Type");
      yield return Read("Collections", "List");
      yield return Read("Collections", "Dictionary");
      yield return Read("Collections", "Queue");
      yield return Read("Collections", "Stack");
      yield return Read("Collections", "HashSet");
      yield return Read("Collections", "LinkedList");
      yield return Read("Collections", "Linq");
      yield return Read("Collections", "SortedSet");
      yield return Read("Convert");
      yield return Read("Math");
      yield return Read("Random");
      yield return Read("Text", "StringBuilder");
      yield return Read("Console");
      yield return Read("Reflection", "Assembly");
      yield return Read("Threading", "Timer");
      yield return Read("Threading", "Thread");
      yield return Read("Threading", "Task");
      yield return Read("Utilities");
      yield return Read("Globalization", "Globalization");
      yield return Read("Numerics", "HashCodeHelper");
      yield return Read("Numerics", "Complex");
      yield return Read("Numerics", "Vector2");
      yield return Read("Numerics", "Vector3");
      yield return Read("Numerics", "Vector4");
      yield return Read("Numerics", "Matrix3x2");
      yield return Read("Numerics", "Matrix4x4");
      yield return Read("Numerics", "Plane");
      yield return Read("Numerics", "Quaternion");
      yield return Read("StringExLib");
      yield return Read("OverloadTempFix");
    }
  }
}
