https://www.winsms.co.za/api/creditsTransfer.asp?User=cedrica@inobits.com&Password=Dr0wss@p1234&

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
    }


    class mySMSProvider
    {
        static string RequestURL = "https://www.winsms.co.za/api/batchmessage.asp?User=cedrica@inobits.com&Password=P@ss.4321";
        static string adminAccount;
        static string adminEmail;
        static string adminPassword;

        mySMSProvider()
        {
        }

        public static int SendSms(string userMobileNumber, string message)
        {
            WebClient wc = new WebClient();
            string requestData;

            requestData = Microsoft.IdentityManagement.Samples.mySMSProvider.GetRequestData(userMobileNumber, message);
            //&Numbers=0823337773+&Message=Your+security+code+is+263664
            var newurl = mySMSProvider.RequestURL + requestData;

            byte[] postData = Encoding.ASCII.GetBytes(requestData);

            //byte[] response = wc.UploadData(mySMSProvider.RequestURL, postData);
            byte[] response = wc.UploadData(newurl, postData);

            string result = Encoding.ASCII.GetString(response);  // result contains the error text

            int returnValue = System.Convert.ToInt32(result.Substring(0, 4), NumberFormatInfo.InvariantInfo);
            return returnValue;
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
