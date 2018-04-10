using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace VSTSHelper
{
    public static class Helper
    {
        const String accountUri = "https://somecorp.visualstudio.com";
        const String c_projectName = "IT Application Services";
        const String personalAccessToken = "pejptkcenlddbxv3ft5g3tmwvpcve3yef6yjwhl6g5qvoy6s7rka";
        public static void Init()
        {
            //connection = new VssConnection(new Uri(accountUri), new VssBasicCredential(string.Empty, personalAccessToken));
        }



        // Create a release 
        //{
        //    var client = new RestClient("https://somecorp.vsrm.visualstudio.com/DefaultCollection/IT%20Application%20Services/_apis/release/releases?api-version=3.0-preview.2");
    //        var request = new RestRequest(Method.POST);
            //request.AddHeader("cache-control", "no-cache");
            //request.AddHeader("authorization", "Basic OnBlanB0a2NlbmxkZGJ4djNmdDVnM3Rtd3ZwY3ZlM3llZjZ5andobDZnNXF2b3k2czdya2E=");
            //request.AddHeader("content-type", "application/json");
            //request.AddParameter("application/json", "{\r\n  \"definitionId\": 5,\r\n  \"description\": \"Creating Sample release for - Test\",\r\n  \"artifacts\": [\r\n    {\r\n      \"alias\": \"Fabrikam.CI\",\r\n      \"instanceReference\": {\r\n        \"id\": \"2\",\r\n        \"name\": null\r\n      }\r\n    }\r\n  ],\r\n  \"isDraft\": false,\r\n  \"reason\": \"none\",\r\n  \"manualEnvironments\": null\r\n}", ParameterType.RequestBody);
            //IRestResponse response = client.Execute(request);
        //}
    }
}


//https://www.nwcadence.com/blog/vststfs-rest-api-the-basics-and-working-with-builds-and-releases
