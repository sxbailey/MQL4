using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using IronPython.Hosting;
using Microsoft.Scripting.Hosting;
using NQuotes;
using Microsoft.Scripting;

namespace PyMovingAverage
{
    public class PyMovingAverage : IExpertAdvisor
    {
        private IMqlApi _api;
        private IExpertAdvisor _expert;
        private ScriptEngine _engine;
        private ScriptScope _scope;

        private static string GetBasePath()
        {
            var codeBaseUri = new Uri(typeof(PyMovingAverage).Assembly.CodeBase);
            return Path.GetDirectoryName(codeBaseUri.LocalPath);
        }

        private static IEnumerable<Assembly> GetReferences()
        {
            return new Assembly[]
            {
                typeof(System.Drawing.Color).Assembly,
                typeof(IMqlApi).Assembly,
                typeof(MqlApi).Assembly,
            };
        }

        private int HandlePythonExceptions(Func<int> action)
        {
            try
            {
                return action();
            }
            catch (Exception ex)
            {
                string originalMessage = ex.ToString();
                string message = (_engine != null)
                    ? _engine.GetService<ExceptionOperations>().FormatException(ex) + "\n" + originalMessage
                    : originalMessage;
                throw new Exception(message);
            }
        }

        public PyMovingAverage()
        {
            HandlePythonExceptions(() =>
            {
                _engine = Python.CreateEngine();

                var runtime = _engine.Runtime;
                foreach (var reference in GetReferences())
                    runtime.LoadAssembly(reference);

                string code = @"
import sys
sys.path.append(r'{0}')
from MovingAverage import MovingAverage
expert = MovingAverage()
";
                code = string.Format(code, GetBasePath());

                _scope = _engine.CreateScope();
                var source = _engine.CreateScriptSourceFromString(code, SourceCodeKind.Statements);
                source.Execute(_scope);
                _expert = _scope.GetVariable("expert");
                return 0;
            });
        }

        public IMqlApi Api
        {
            get { return _api; }
            set
            {
                _api = value;
                HandlePythonExceptions(() =>
                {
                    _expert.Api = value;
                    return 0;
                });
            }
        }

        public int init()
        {
            return HandlePythonExceptions(() => _expert.init());
        }

        public int start()
        {
            return HandlePythonExceptions(() => _expert.start());
        }

        public int deinit()
        {
            return HandlePythonExceptions(() => _expert.deinit());
        }
    }
}
