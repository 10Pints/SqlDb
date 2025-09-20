using Microsoft.SqlServer.Dac;
using Microsoft.SqlServer.Dac.Model;
//using Microsoft.VisualStudio.TestTools.UnitTesting;
using Xunit;
using System;
using System.IO;
using System.Linq;

namespace SqlDbTests;

//[TestClass]
public class UTIntegrationTests
{
   private const string DacpacPath = @"D:\Dev\SqlDb\Covid\bin\Debug\Covid.dacpac";

   [Fact]
   public void CovidDacpac_Should_Include_UT_Function()
   {
      string expectedFunctionName = "ufn_CalculateBMI"; // Use your actual UT routine name

      Assert.True(File.Exists(DacpacPath), $"DACPAC not found at: {DacpacPath}");

      using FileStream fs = new FileStream(DacpacPath, FileMode.Open, FileAccess.Read);
      var options = new ModelLoadOptions
      {
         ModelStorageType = DacSchemaModelStorageType.Memory,
         LoadAsScriptBackedModel = false,      // or true, if you want full script analysis
         ThrowOnModelErrors = true
      };

      using TSqlModel model = TSqlModel.LoadFromDacpac(fs, options);
      var scalarFunctions = model.GetObjects(DacQueryScopes.UserDefined, ModelSchema.ScalarFunction);
      var tableValuedFunctions = model.GetObjects(DacQueryScopes.UserDefined, ModelSchema.TableValuedFunction);
      var procedures = model.GetObjects(DacQueryScopes.UserDefined, ModelSchema.Procedure);
      var views = model.GetObjects(DacQueryScopes.UserDefined, ModelSchema.View);
      var tableTypes = model.GetObjects(DacQueryScopes.UserDefined, ModelSchema.TableType);
      var assemblies = model.GetObjects(DacQueryScopes.UserDefined, ModelSchema.Assembly);

      var allFunctions = scalarFunctions.Concat(tableValuedFunctions);

      bool found = allFunctions.Any(f =>
          f.Name.Parts.Last().Equals(expectedFunctionName, StringComparison.OrdinalIgnoreCase));

      Assert.True(found, $"Function '{expectedFunctionName}' not found in Covid.dacpac.");
   }
}