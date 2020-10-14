Add-PSSnapin FIMAutomation
$AccountName = $fimwf.WorkflowDictionary.AccountName
$Email = $fimwf.WorkflowDictionary.OTPEmail
$Domain = "AD"
if($Email)
{
$template = Get-AuthenticationWorkflowRegistrationTemplate -AuthenticationWorkflowName 'Password Reset Email OTP AuthN Workflow'
$template.GateRegistrationTemplates[0].Data[0].Value = $Email
Register-AuthenticationWorkflow -UserName "$Domain\$AccountName" -AuthenticationWorkflowRegistrationTemplate $template
}
else
{
Unregister-AuthenticationWorkflow -UserName "$Domain\$AccountName" -AuthenticationWorkflowName 'Password Reset Email OTP AuthN Workflow'
}