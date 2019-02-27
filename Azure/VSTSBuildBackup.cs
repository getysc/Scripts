using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace VSTSHelper
{
    
//public static class BuildBackup
//{
//    private const string Personalaccesstoken = "PAT";
 
//    [FunctionName("BackupBuild")]
//    public static async Task Run([TimerTrigger("0 */1 * * * *")]TimerInfo myTimer, [Blob("devops/build.json", FileAccess.Write)] Stream output, TraceWriter log)
//    {
//        try
//        {
//            using (var client = new HttpClient())
//            {
//                client.DefaultRequestHeaders.Accept.Add(
//                    new MediaTypeWithQualityHeaderValue("application/json"));
 
//                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Basic",
//                    Convert.ToBase64String(
//                        System.Text.Encoding.ASCII.GetBytes(
//                            string.Format("{0}:{1}", "", Personalaccesstoken))));
 
//                using (var response = await client.GetAsync(
//                    $"https://{instance}.visualstudio.com/DefaultCollection/{project}/_apis/build/definitions?api-version=2.0")
//                )
//                {
//                    var data = await response.Content.ReadAsAsync<JObject>();
//                    foreach (var pr in data.SelectToken("$.value"))
//                    {
//                        var id = pr.First.SelectToken("$.id");
//                        using (var release = await client.GetAsync(
//                            $"https://{instance}.visualstudio.com/DefaultCollection/{project}/_apis/build/definitions/{id}?api-version=2.0")
//                        )
//                        {
//                            release.EnsureSuccessStatusCode();
//                            var releaseData = await release.Content.ReadAsStringAsync();
//                            var bytes = Encoding.UTF8.GetBytes(releaseData);
//                            await output.WriteAsync(bytes, 0, bytes.Length);
//                        }
//                    }
//                }
//            }
//        }
//        catch (Exception ex)
//        {
//            log.Info(ex.ToString());
//        }
//    }
//}
}


//https://www.nwcadence.com/blog/vststfs-rest-api-the-basics-and-working-with-builds-and-releases
