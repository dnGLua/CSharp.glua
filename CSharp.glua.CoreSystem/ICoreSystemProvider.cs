using System.Collections.Generic;

namespace CSharp.glua.CoreSystem {
  public interface ICoreSystemProvider {
    public (string name, string code) this[params string[] path] => Read(path);

    public bool Initialize() => true;

    public (string name, string code) Read(params string[] path);

    public IEnumerable<(string name, string code)> GetCoreSystemFiles() {
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
    }
  }
}
