using System;
using System.IO;
using System.Text;
using System.Net.Mail;
using System.Xml.Serialization;

//
// vstst.cs is produced via below command
//  "C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.8 Tools\x64\xsd.exe"  "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Xml\Schemas\vstst.xsd" /c
//

/*
 *          TRX2HTML tool converts MSTest results(TRX) to HTML and sends an e-mail.
 *  
 *          Usgae::
 *              TRX2HTML.exe <TRXFileName>  [<Test run title>] [<Email-Alias-ToSend-Results>] [ForceSendMail]
 *                
 *          Example ::
 *              TRX2HTML.exe "c:\temp\jems2.trx" "Sample test run" "Sreekanth_Yarlagadda@jabil.com" "ForceSendMail"
 *  
*/

namespace Utility
{
    class Program
    {
        static void Main(string[] args)
        {
            string testTunTitle = string.Empty;
            string mailTo = string.Empty;
            bool ForceSendMail = false;

            if (args.Length == 0)
            {
                System.Console.WriteLine("Please input arguments.");
                System.Console.WriteLine("TRX2HTML <TRXFilePath> [<Test Run Title>] [<ResultMailAlias>] [ForceSendMail]");
                return;
            }

            string trxFilePath = args[0];
            if (args.Length >= 2)
            {
                testTunTitle = args[1];
            }

            if (args.Length >= 3)
            {
                mailTo = args[2];
            }

            if (args.Length >= 4)
            {
                ForceSendMail = true;
            }

            System.Console.WriteLine("Trx File Path    :: {0}", trxFilePath);
            System.Console.WriteLine("Test Run Title   :: {0}", testTunTitle);
            System.Console.WriteLine("mailTo           :: {0}", mailTo);
            System.Console.WriteLine("ForceSendMail    :: {0}", ForceSendMail);

            string baseDirectory = AppDomain.CurrentDomain.BaseDirectory;
            string resultFilePath = baseDirectory + "SYSTEM.TestResult.html";
            StringBuilder htmlString = new StringBuilder(File.ReadAllText("ReportTemplate.html"));
            int aborted = 0,
            passed = 0,
            failed = 0,
            notexecuted = 0;
            var fileInfo = new FileInfo(trxFilePath);
            var fileStreamReader = new StreamReader(fileInfo.FullName);
            var xmlSer = new XmlSerializer(typeof(TestRunType));
            var testRunType = (TestRunType)xmlSer.Deserialize(fileStreamReader);
            StringBuilder testResult = new StringBuilder();
            foreach (var itob1 in testRunType.Items)
            {
                var resultsType = itob1 as ResultsType;
                if (resultsType == null) continue;
                foreach (var itob2 in resultsType.Items)
                {
                    var unitTestResultType = itob2 as UnitTestResultType;
                    if (unitTestResultType == null) continue;

                    // these are not used, but they could be to identify the output:
                    var id = unitTestResultType.testId;
                    var testName = unitTestResultType.testName;
                    var outcome = unitTestResultType.outcome;

                    string stdout = string.Empty;
                    try
                    {
                        stdout = ((System.Xml.XmlNode[])((OutputType)unitTestResultType.Items[0]).StdOut)[0].InnerText;
                        stdout = stdout.Replace("\n", "<br/>");
                    }
                    catch(Exception)
                    {
                        Console.WriteLine("stdout variable is null");
                    }

                    OutputTypeErrorInfo ErrorInfo = null;
                    try
                    {
                        ErrorInfo = (((OutputType)(((TestResultType)(unitTestResultType)).Items[0])).ErrorInfo);
                    }
                    catch (Exception)
                    {
                        ErrorInfo = null;
                    }

                    string errorMessage = stdout;
                    if (ErrorInfo != null)
                    {
                        errorMessage = errorMessage + "<BR/>" + ((System.Xml.XmlNode[])ErrorInfo.Message)[0].Value;
                    }

                    //string errorMessage = ((System.Xml.XmlNode[])(((OutputType)(((TestResultType)(unitTestResultType)).Items[0])).ErrorInfo.Message))[0].Value;
                    testResult.AppendLine("<tr>");
                    testResult.AppendLine(String.Format("<td>{0}</td>", testName));
                    if (0 == outcome.CompareTo("Aborted"))
                    {
                        testResult.AppendLine(String.Format("<td BGCOLOR='grey'>{0}</td>", outcome));
                        testResult.AppendLine(String.Format("<td>{0}</td>", errorMessage));
                        aborted++;
                    }
                    else if (0 == outcome.CompareTo("Failed"))
                    {
                        testResult.AppendLine(String.Format("<td BGCOLOR='red'>{0}</td>", outcome));
                        testResult.AppendLine(String.Format("<td>{0}</td>", errorMessage));
                        failed++;
                    }
                    else if (0 == outcome.CompareTo("NotExecuted"))
                    {
                        testResult.AppendLine(String.Format("<td BGCOLOR='grey'>{0}</td>", outcome));
                        testResult.AppendLine(String.Format("<td>{0}</td>", errorMessage));
                        notexecuted++;
                    }
                    else if (0 == outcome.CompareTo("Passed"))
                    {
                        testResult.AppendLine(String.Format("<td bgcolor='green'>{0}</td>", outcome));
                        testResult.AppendLine(String.Format("<td>{0}</td>", stdout));
                        passed++;
                    }
                    else 
                    {
                        Console.WriteLine("Unsuuported outcome {0}", outcome);
                    }

                    testResult.AppendLine("</tr>");
                }

                htmlString.Replace("Test_Result_Title", testTunTitle.ToString());
                htmlString.Replace("TEST_RESULT_STRING", testResult.ToString());
                htmlString.Replace("Passed_Count", passed.ToString());
                htmlString.Replace("Failed_Count", failed.ToString());
                htmlString.Replace("Aborted_Count", aborted.ToString());
                htmlString.Replace("Not_Executed_Count", notexecuted.ToString());
                File.WriteAllText(resultFilePath, htmlString.ToString());
                //System.Diagnostics.Process.Start(resultFilePath);

                if ( (failed > 0) || (ForceSendMail == true) )
                {
                    if (mailTo != string.Empty)
                    {
                        SmtpClient smtpClient = new SmtpClient("Corimc04.corp.jabil.org");
                        MailMessage message = new MailMessage("ems_devops@jabil.com", mailTo, testTunTitle, htmlString.ToString())
                        {
                            IsBodyHtml = true,
                            DeliveryNotificationOptions = DeliveryNotificationOptions.Never
                        };
                        smtpClient.Send(message);
                        Console.WriteLine("Sent mail........");
                    }
                    else
                    {
                        Console.WriteLine("mailTo string is empty........");
                    }
                }
                else
                {
                    Console.WriteLine("No e-mail as either of the below conditions are true");
                    Console.WriteLine("\t\t No test failures OR");
                    Console.WriteLine("\t\t ForceSendMail is false");
                    Console.WriteLine("failed Tests :: " + failed.ToString());
                    Console.WriteLine("ForceSendMail:: " + ForceSendMail.ToString());
                }
            }
        }
    }
}

