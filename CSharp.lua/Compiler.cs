/*
Copyright 2017 YANG Huan (sy.yanghuan@gmail.com).

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

using System;
using System.Collections.Generic;
using System.Diagnostics.Contracts;
using System.IO;
using System.Linq;
using System.Reflection;

using Cake.Incubator.Project;
using CSharp.glua.CoreSystem;
using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;

namespace CSharpLua {
  public sealed class Compiler {
    private const string kDllSuffix = ".dll";
    private const char kLuaModuleSuffix = '!';

    private readonly bool isProject_;
    private readonly string input_;
    private readonly string output_;
    private readonly string[] libs_;
    private readonly string[] metas_;
    private readonly string[] cscArguments_;
    private readonly bool isClassic_;
    private readonly string[] attributes_;
    private readonly string[] enums_;

    public bool IsExportMetadata { get; set; }
    public bool IsModule { get; set; }
    public bool IsInlineSimpleProperty { get; set; }
    public bool IsPreventDebugObject { get; set; }
    public bool IsCommentsDisabled { get; set; }
    public bool IsDecompilePackageLibs { get; set; }
    public bool IsNotConstantForEnum { get; set; }
    public bool IsNoConcurrent { get; set; }
    public ICoreSystemProvider Include { get; set; }
    public List<string> PostProcess { get; set; }

    public Compiler(string input, string output, string lib, string meta, string[] csc, bool isClassic, string atts, string enums) {
      isProject_ = new FileInfo(input).Extension.ToLower() == ".csproj";
      input_ = input;
      output_ = output;
      libs_ = Utility.Split(lib);
      metas_ = Utility.Split(meta);
      cscArguments_ = csc;
      isClassic_ = isClassic;
      if (atts != null) {
        attributes_ = Utility.Split(atts, false);
      }
      if (enums != null) {
        enums_ = Utility.Split(enums, false);
      }
    }

    private static IEnumerable<string> GetMetas(IEnumerable<string> additionalMetas) {
      return additionalMetas.ToList();
    }

    private static bool IsCorrectSystemDll(string path) {
      try {
        Assembly.LoadFile(path);
        return true;
      } catch (Exception) {
        return false;
      }
    }

    private static List<string> GetSystemLibs() {
      string privateCorePath = typeof(object).Assembly.Location;
      List<string> libs = new List<string>() { privateCorePath };

      string systemDir = Path.GetDirectoryName(privateCorePath);
      foreach (string path in Directory.EnumerateFiles(systemDir, "*.dll")) {
        if (IsCorrectSystemDll(path)) {
          libs.Add(path);
        }
      }

      return libs;
    }

    private static List<string> GetLibs(IEnumerable<string> additionalLibs, out List<string> luaModuleLibs) {
      luaModuleLibs = new List<string>();
      var libs = GetSystemLibs();
      var dlls = new HashSet<string>(libs.Select(lib => new FileInfo(lib).Name));
      if (additionalLibs != null) {
        foreach (string additionalLib in additionalLibs) {
          string lib = additionalLib;
          bool isLuaModule = false;
          if (lib.Last() == kLuaModuleSuffix) {
            lib = lib.TrimEnd(kLuaModuleSuffix);
            isLuaModule = true;
          } else {
            var dllName = new FileInfo(lib).Name;
            if (dlls.Contains(dllName)) {
              // Avoid duplicate dlls.
              continue;
            } else {
              dlls.Add(dllName);
            }
          }

          string path = lib.EndsWith(kDllSuffix) ? lib : lib + kDllSuffix;
          if (File.Exists(path)) {
            if (isLuaModule) {
              luaModuleLibs.Add(Path.GetFileNameWithoutExtension(path));
            }

            libs.Add(path);
          } else {
            throw new CmdArgumentException($"-l {path} is not found");
          }
        }
      }
      return libs;
    }

    public void Compile(bool manifestAsFunction = true, string luaVersion = null) {
      if (Include == null) {
        GetGenerator().Generate(output_);
      } else {
        CompileSingleFile("out.lua", manifestAsFunction, luaVersion);
      }
    }

    public void CompileSingleFile(string fileName, bool manifestAsFunction = true, string luaVersion = null) {
      GetGenerator().GenerateSingleFile(fileName, output_, Include, manifestAsFunction, luaVersion);
    }

    public void CompileSingleFile(Stream target, bool manifestAsFunction = true, string luaVersion = null) {
      GetGenerator().GenerateSingleFile(target, Include, manifestAsFunction, luaVersion);
    }

    private LuaSyntaxGenerator GetGenerator() {
      const string configurationDebug = "Debug";
      const string configurationRelease = "Release";
      var mainProject = isProject_ ? ProjectHelper.ParseProject(input_, IsCompileDebug() ? configurationDebug : configurationRelease) : null;
      var projects = mainProject?.EnumerateProjects().ToArray();
      var packages = isProject_ ? PackageHelper.EnumeratePackages(mainProject.TargetFrameworkVersions.First(), projects.Select(project => project.project)).ToArray() : null;
      var files = isProject_ ? GetSourceFiles(projects) : GetSourceFiles();
      var packageBaseFolders = new List<string>();
      if (packages != null) {
        foreach (var package in packages) {
          var packageFiles = PackageHelper.EnumerateSourceFiles(package, out var baseFolder).ToArray();
          if (packageFiles.Length > 0) {
            files = files.Concat(packageFiles);
            packageBaseFolders.Add(baseFolder);
          }
          if (IsDecompilePackageLibs) {
            var packageLibs = PackageHelper.EnumerateLibs(package, out baseFolder).ToArray();
            if (packageLibs.Length > 0) {
              var decompiledLibFiles = packageLibs.Select(lib =>
              {
                var decompiler = new ICSharpCode.Decompiler.CSharp.CSharpDecompiler(lib, new ICSharpCode.Decompiler.DecompilerSettings());
                var libFileInfo = new FileInfo(lib);
                var fileName = libFileInfo.FullName.Substring(0, libFileInfo.FullName.Length - libFileInfo.Extension.Length) + ".cs";
                File.WriteAllText(fileName, decompiler.DecompileWholeModuleAsString());
                return fileName;
              });
              files = files.Concat(decompiledLibFiles);
              packageBaseFolders.Add(baseFolder);
            }
          }
        }
      }
      var codes = files.Select(i => (File.ReadAllText(i), i));
      var libs = GetLibs(isProject_ && !IsDecompilePackageLibs ? libs_.Concat(packages.SelectMany(PackageHelper.EnumerateLibs)) : libs_, out var luaModuleLibs);
      var metas = GetMetas(isProject_ ? metas_.Concat(packages.SelectMany(PackageHelper.EnumerateMetas)) : metas_);
      var setting = new LuaSyntaxGenerator.SettingInfo {
        IsClassic = isClassic_,
        IsExportMetadata = IsExportMetadata,
        Attributes = attributes_,
        Enums = enums_,
        LuaModuleLibs = new HashSet<string>(luaModuleLibs),
        IsModule = IsModule,
        IsInlineSimpleProperty = IsInlineSimpleProperty,
        IsPreventDebugObject = IsPreventDebugObject,
        IsCommentsDisabled = IsCommentsDisabled,
        IsNotConstantForEnum = IsNotConstantForEnum,
        IsNoConcurrent = IsNoConcurrent,
        PostProcess = PostProcess
      };
      if (isProject_) {
        foreach (var folder in projects.Select(p => p.folder)) {
          setting.AddBaseFolder(folder, false);
        }
        foreach (var folder in packageBaseFolders) {
          setting.AddBaseFolder(folder, false);
        }
      } else if (Directory.Exists(input_)) {
        setting.AddBaseFolder(input_, false);
      } else if (files.Count() == 1) {
        setting.AddBaseFolder(new FileInfo(files.Single()).DirectoryName, true);
      } else {
        // throw new NotImplementedException("Unable to determine basefolder(s) when the input is a list of source files.");
      }
      var fileBannerLines = new List<string>();
      if (packages != null && packages.Length > 0) {
        fileBannerLines.Add("Compiled with the following packages:");
        fileBannerLines.AddRange(packages.Select(package => $"  {package.PackageName}: v{package.VersionNormalizedString}").OrderBy(s => s, StringComparer.Ordinal));
      }
      return new LuaSyntaxGenerator(codes, libs, cscArguments_, metas, setting);
    }

    private IEnumerable<string> GetSourceFiles() {
      if (Directory.Exists(input_)) {
        return Directory.EnumerateFiles(input_, "*.cs", SearchOption.AllDirectories);
      }
      return Utility.Split(input_, true);
    }

    private IEnumerable<string> GetSourceFiles(IEnumerable<(string folder, CustomProjectParserResult project)> projects) {
      return projects.SelectMany(project => project.project.EnumerateSourceFiles(project.folder));
    }

    private bool IsCompileDebug() {
      foreach (var arg in cscArguments_) {
        if (arg.StartsWith("-debug")) {
          return true;
        }
      }
      return false;
    }

    public static string CompileSingleCode(string code) {
      var codes = new (string, string)[] { (code, "") };
      var generator = new LuaSyntaxGenerator(codes, GetSystemLibs(), null, GetMetas(null), new LuaSyntaxGenerator.SettingInfo());
      return generator.GenerateSingle();
    }

    /// <summary>
    /// for Blazor to use
    /// </summary>
    public static string CompileSingleCode(string code, IEnumerable<Stream> libs, IEnumerable<Stream> metas) {
      var codes = new (string, string)[] { (code, "") };
      var generator = new LuaSyntaxGenerator(codes, libs, null, metas, new LuaSyntaxGenerator.SettingInfo() { 
        IsNoConcurrent = true
      });
      return generator.GenerateSingle();
    }
  }
}
