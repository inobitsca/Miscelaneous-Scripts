//------------------------------------------------------------
// Copyright (c) Microsoft Corporation.  All rights reserved.
//------------------------------------------------------------
namespace Microsoft.IdentityManagement.Samples
{
    using System;
    using System.Collections.Generic;
    using System.Globalization;
    using System.Net;
    using System.Text;
    using Microsoft.IdentityManagement.SmsServiceProvider;
    using System.Web;
    using System.Security.Cryptography;
    using System.IO;



    public class SmsServiceProvider : ISmsServiceProvider
    {

        public void SendSms(string mobileNumber,
                            string message,
                            Guid requestId,
                            Dictionary<string, object> deliveryAttributes)
        {
            mySMSProvider.SendSms(mobileNumber, message);
        }




        class mySMSProvider
        {
            static string adminAccount;
            static string adminEmail;
            static string adminPassword;
            static string mobile = System.Web.HttpUtility.UrlEncode(mobile);
            static string message = System.Web.HttpUtility.UrlEncode(message);

            mySMSProvider()
            {
            }

            public static string SendSms(string userMobileNumber, string message)
            {
                string result = string.Empty;
                var wc = new System.Net.WebClient();
                wc.Proxy.Credentials = CredentialCache.DefaultCredentials;

                HttpWebRequest httpWebRequest = (HttpWebRequest)WebRequest.Create("http://bms29.vine.co.za/httpInputhandler/ApplinkUpload");


                httpWebRequest.ContentType = "application/json; charset=utf-8";
                httpWebRequest.Method = "POST";
                httpWebRequest.Credentials = System.Net.CredentialCache.DefaultCredentials;

                using (var streamWriter = new System.IO.StreamWriter(httpWebRequest.GetRequestStream()))
                {
                    string json = @"<?xml version='1.0' encoding='UTF - 8'?><gviSmsMessage><affiliateCode>TEL004-046-003</affiliateCode><authenticationCode>BCXIITPASSWORDRESET</authenticationCode><messageType>text</messageType><recipientList><message>" + message + "</message><recipient><msisdn>" + userMobileNumber + "</msisdn></recipient></recipientList></gviSmsMessage>";


                    streamWriter.Write(json);
                    streamWriter.Flush();
                    streamWriter.Close();
                }
                using (var response = httpWebRequest.GetResponse() as HttpWebResponse)
                {
                    if (httpWebRequest.HaveResponse && response != null)
                    {
                        using (var reader = new StreamReader(response.GetResponseStream()))
                        {
                            result = reader.ReadToEnd();
                        }
                    }
                }
                return result;
            }

            public static string GetRequestData(string mobile, string message)
            {

                string myrequestData;

                myrequestData =
                     //"AccountId=" + adminAccount
                     // + "&Email=" + System.Web.HttpUtility.UrlEncode(adminEmail)
                     // + "&Password=" + System.Web.HttpUtility.UrlEncode(adminPassword)
                     "&Numbers=" + System.Web.HttpUtility.UrlEncode(mobile)
                     + "&Message=" + System.Web.HttpUtility.UrlEncode(message);

                return myrequestData;


            }

            public void GetCredentials()
            {

                string mypwordFile = (@"C:\Program Files\Microsoft Forefront Identity Manager\2010\Service\SmsEncryptedCredentials.txt");


                FileInfo info;
                int len;
                byte[] buffin;
                byte[] buffout;

                byte[] Entropy = { 9, 8, 7, 6, 5 };

                info = new FileInfo(mypwordFile);
                len = (int)info.Length;

                buffin = File.ReadAllBytes(mypwordFile);
                buffout = ProtectedData.Unprotect(buffin, Entropy, DataProtectionScope.CurrentUser);

                File.WriteAllBytes(mypwordFile, buffout);

                StreamReader sr = new StreamReader(mypwordFile);
                adminAccount = sr.ReadLine();
                adminEmail = sr.ReadLine();
                adminPassword = sr.ReadLine();


                sr.Close();

                buffin = File.ReadAllBytes(mypwordFile);
                buffout = ProtectedData.Protect(buffin, Entropy, DataProtectionScope.CurrentUser);

                File.WriteAllBytes(mypwordFile, buffout);


            }


        };
    }
}