using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using RestSharp;
using RestSharp.Authenticators;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace VSTSHelper
{
    public class VSTSApi
    {
        String _baseUrl = "https://somecorp.vsrm.visualstudio.com";
        String _projectName;
        String _userName = "";
        String _personalAccessToken = "mgjcju37ohv7shmoq6v6hbgwpgw2e37xznsajamdfc5yumt25poa";

        RestClient _client;

        public VSTSApi(string projectName = "TRM")
        {
            _projectName = projectName;
            _personalAccessToken = System.IO.File.ReadAllText(@"c:\windows\VSTSToken.txt");
            _client = new RestClient(_baseUrl);
            _client.Authenticator = new HttpBasicAuthenticator(_userName, _personalAccessToken);
        }

        public VSTSApi(string projectName, string personalAccessToken)
        {
            _projectName = projectName;
            _personalAccessToken = personalAccessToken;
            _client = new RestClient(_baseUrl);
            _client.Authenticator = new HttpBasicAuthenticator(_userName, _personalAccessToken);
        }


        public List<string> GetReleaseTemplates()
        {
            //// 
            //// "https://kforce.vsrm.visualstudio.com/IT%20Application%20Services/_apis/Release/definitions");
            //// 
            var request = new RestRequest(_projectName + @"/_apis/Release/definitions", Method.GET);
            request.AddHeader("cache-control", "no-cache");
            request.AddHeader("Content-Type", "application/json");

            IRestResponse response = _client.Execute(request);
            var content = JsonConvert.DeserializeObject<VSTSReleaseDefintions.RootObject>(response.Content);
            List<string> results = new List<string>();
            foreach(var releaseTemplate in content.value)
            {
                results.Add(releaseTemplate.id + "." + releaseTemplate.name);
            }
            return results;
        }

        //public List<string> GetReleases()
        public List<VSTSReleases.Value> GetReleases()
        {
            ////
            //// https://kforce.vsrm.visualstudio.com/IT%20Application%20Services/_apis/Release/releases?api-version=3.0-preview.2
            ////
            var request = new RestRequest(_projectName + @"/_apis/Release/releases?api-version=3.0-preview.2", Method.GET);
            request.AddHeader("cache-control", "no-cache");
            IRestResponse response = _client.Execute(request);
            var content = JsonConvert.DeserializeObject<VSTSReleases.RootObject>(response.Content);
            var result = content.value.GroupBy(x => x.releaseDefinition.name).Select(x => x.First()).ToList();
            return result;
        }

        public List<string> GetReleaseData(string releaseId)
        {
            ////
            //// https://kforce.vsrm.visualstudio.com/IT%20Application%20Services/_apis/Release/releases/81?api-version=3.0-preview.2
            ////
            string query = String.Format(@"{0}/_apis/Release/releases/{1}?api-version=3.0-preview.2", _projectName, releaseId);
            var request = new RestRequest(query, Method.GET);
            request.AddHeader("cache-control", "no-cache");
            IRestResponse response = _client.Execute(request);
            var content = JsonConvert.DeserializeObject<VSTSReleaseDetails.RootObject>(response.Content);
            var environments = content.environments.Select(x => new { x.id, x.name }).ToList();
            List<string> results = new List<string>();
            foreach (var environment in environments)
            {
                results.Add(environment.id + "." + environment.name);
            }
            return results;
        }

        public static string Base64Encode(string username, string password)
        {
            string plainText = String.Format("{0}:{1}", username, password);
            var plainTextBytes = System.Text.Encoding.UTF8.GetBytes(plainText);
            return System.Convert.ToBase64String(plainTextBytes);
        }
    }

}
