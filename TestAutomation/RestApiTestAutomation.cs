


    public static class JsonHelper 
    {
        public static List<MyApplicationService> LoadServiceData(string filename = "MyApplicationServices.json")
        {
            string jsonData = File.ReadAllText(filename);
            return JsonConvert.DeserializeObject<List<MyApplicationService>>(jsonData);
        }
        public static List<MyApplicationEnvironment> LoadEnvironmentsData(string filename = "MyApplicationEnvironments.json")
        {
            string jsonData = File.ReadAllText(filename);
            return JsonConvert.DeserializeObject<List<MyApplicationEnvironment>>(jsonData);
        }
    }
	
	
	public static class RestHelper
    {
        static HttpClient client = new HttpClient();

        public static string RunRestApi(string uri, string authorization = null)
        {
            client.DefaultRequestHeaders.Clear();
            if (authorization != null)
            {
                var byteArray = Encoding.ASCII.GetBytes(authorization);
                client.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Basic", Convert.ToBase64String(byteArray));
                //client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            }

            string json = null;
            HttpResponseMessage response = client.GetAsync(uri).Result;
            if (response.IsSuccessStatusCode)
            {
                json = response.Content.ReadAsStringAsync().Result;
                return json;
            }
            else
            {
                string result = String.Format("******* {0} =>  {1}", uri, response.ReasonPhrase.ToString());
                Console.WriteLine(result);
                throw new Exception(result);
            }
        }
		
    }
