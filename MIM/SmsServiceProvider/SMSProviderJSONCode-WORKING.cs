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
            static string ServiceUserName = "SMSServiceUser";
            static string ServicePassword = "Test";
            static string ClientReferenceID = "Silica";
            static string ConsumerContext = "MIM";
            static string ServiceContext = "SSPR";
            static string UserContext = "OTP";
            static string ConsumerProcess = "5";
            static string Name = "NONE";
            static string Value = "NONE";
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

                HttpWebRequest httpWebRequest = (HttpWebRequest)WebRequest.Create("http://silgry-sms1/SMS/Silica.SMSService.WebAPI/SMSService/SendSingleSMS");


                httpWebRequest.ContentType = "application/json; charset=utf-8";
                httpWebRequest.Method = "POST";
                httpWebRequest.Credentials = System.Net.CredentialCache.DefaultCredentials;

                using (var streamWriter = new System.IO.StreamWriter(httpWebRequest.GetRequestStream()))
                {
                    //"{ 'secAttributes': { 'ServiceUserName':" + ServiceUserName + ",'ServicePassword':" + ServicePassword + ",'ClientReferenceID':" + ClientReferenceID + " },'msgAttributes': { 'ToCellNumber': '" + mobile + "','TextMessage': '" + message + "','ConsumerContext':" + ConsumerContext + ",'ServiceContext':" + ServiceContext + ",'UserContext':" + UserContext + ",'ConsumerProcess':" + ConsumerProcess + ",'CustomData': [{'Name':" + Name + ",'Value':" + Value + "'}]}";
                    string json = @"{ 'secAttributes': { 'ServiceUserName':'SMSServiceUser','ServicePassword':'Test','ClientReferenceID':'Silica' },'msgAttributes': { 'ToCellNumber': '"+ userMobileNumber + "','TextMessage': '"+ message+ "','ConsumerContext':'MIM','ServiceContext':'SSPR','UserContext':'OTP','ConsumerProcess':5,'CustomData': [{'Name':'NONE','Value':'NONE'}]}";


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
    } }