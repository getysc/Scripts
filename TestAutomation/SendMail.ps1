

Param(
    [string]
    [Parameter(Mandatory = $true)]
    $BinaryPath
)

$smtpServer = "Your.corp.email.server"
$recipients = @(
	"Some EMail GRoup <SomeEMailGRoup@test.com>",
	"Test User<TestUser@test.com>"
)

$subject ="HealthChecks:: PRODUCTION Service(s) health check failed"
$msg ="Please investigate production services health check failures"
Send-MailMessage -to $recipients -from "someuser@myorg.com" -SmtpServer $smtpServer -Subject $subject -Body $msg -Attachments "$BinaryPath\HealthChecks.trx"
