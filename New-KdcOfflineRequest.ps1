# Constants

$XCN_AT_KEYEXCHANGE = 1
$ContextMachine = 2
$XCN_CERT_ALT_NAME_DNS_NAME = 3
$ekuClientAuth = '1.3.6.1.5.5.7.3.2'
$ekuServerAuth = '1.3.6.1.5.5.7.3.1'
$ekuKdc = '1.3.6.1.5.2.3.5'
$ekuSmartcardLogon = '1.3.6.1.4.1.311.20.2.2'
$XCN_CRYPT_STRING_BASE64REQUESTHEADER = 3

# Initialize

$computerDnsName = [System.Net.Dns]::GetHostEntry([System.Net.Dns]::GetHostName()).HostName
$domainDnsName = (Get-ADDomain -Current LocalComputer).Forest
$domainName = (Get-ADDomain -Current LocalComputer).NetBIOSName
$keyLength = 2048
$validityPeriodYears = 3

# Create private key

$privateKey = New-Object -ComObject X509Enrollment.CX509PrivateKey
$privateKey.Length = $keyLength
$privateKey.KeySpec = $XCN_AT_KEYEXCHANGE
$privateKey.MachineContext = $true
$privateKey.ProviderName = 'Microsoft RSA SChannel Cryptographic Provider'
$privateKey.Silent = $true
$privateKey.Create()

# Create PKCS10

$pkcs10 = New-Object -ComObject X509Enrollment.CX509CertificateRequestPkcs10
$pkcs10.InitializeFromPrivateKey($ContextMachine, $privateKey, '')

$dn = New-Object -ComObject X509Enrollment.CX500DistinguishedName
$dn.Encode("CN=$($computerDnsName)")
$pkcs10.Subject = $dn

# Add SAN DNS names

$altNames = New-Object -ComObject X509Enrollment.CAlternativeNames

$altName1 = New-Object -ComObject X509Enrollment.CAlternativeName
$altName1.InitializeFromString($XCN_CERT_ALT_NAME_DNS_NAME, $computerDnsName)
$altNames.Add($altName1)

$altName2 = New-Object -ComObject X509Enrollment.CAlternativeName
$altName2.InitializeFromString($XCN_CERT_ALT_NAME_DNS_NAME, $domainNameDns)
$altNames.Add($altName2)

$altName3 = New-Object -ComObject X509Enrollment.CAlternativeName
$altName3.InitializeFromString($XCN_CERT_ALT_NAME_DNS_NAME, $domainName)
$altNames.Add($altName3)

$altNamesExtension = New-Object -ComObject X509Enrollment.CX509ExtensionAlternativeNames
$altNamesExtension.InitializeEncode($altNames)
$pkcs10.X509Extensions.Add($altNamesExtension)

# Add EKUs

$oidApplicationPolicies = New-Object -ComObject X509Enrollment.CObjectIds

$oidApplicationPolicy1 = New-Object -ComObject X509Enrollment.CObjectId
$oidApplicationPolicy1.InitializeFromValue($ekuClientAuth)
$oidApplicationPolicies.Add($oidApplicationPolicy1)

$oidApplicationPolicy2 = New-Object -ComObject X509Enrollment.CObjectId
$oidApplicationPolicy2.InitializeFromValue($ekuServerAuth)
$oidApplicationPolicies.Add($oidApplicationPolicy2)

$oidApplicationPolicy3 = New-Object -ComObject X509Enrollment.CObjectId
$oidApplicationPolicy3.InitializeFromValue($ekuSmartcardLogon)
$oidApplicationPolicies.Add($oidApplicationPolicy3)

$oidApplicationPolicy4 = New-Object -ComObject X509Enrollment.CObjectId
$oidApplicationPolicy4.InitializeFromValue($ekuKdc)
$oidApplicationPolicies.Add($oidApplicationPolicy4)

$extensionEku = New-Object -ComObject X509Enrollment.CX509ExtensionEnhancedKeyUsage
$extensionEku.InitializeEncode($oidApplicationPolicies);
$pkcs10.X509Extensions.Add($extensionEku)

# Add key usage

$keyUsage = New-Object -ComObject X509Enrollment.CX509ExtensionKeyUsage
$keyUsage.InitializeEncode([int][Security.Cryptography.X509Certificates.X509KeyUsageFlags]"DigitalSignature,KeyEncipherment")
$keyUsage.Critical = $true
$pkcs10.X509Extensions.Add($keyUsage)

# Add validity period

$nameValuePair = New-Object -ComObject X509Enrollment.CX509NameValuePair
$nameValuePair.Initialize('ValidityPeriod', 'Years');
$pkcs10.NameValuePairs.Add($nameValuePair)

$nameValuePair = New-Object -ComObject X509Enrollment.CX509NameValuePair
$nameValuePair.Initialize('ValidityPeriodUnits', $validityPeriodYears);
$pkcs10.NameValuePairs.Add($nameValuePair)

# Finalize PKCS10

$pkcs10.Encode()

# Create CSR

$certificateRequest = New-Object -ComObject X509Enrollment.CX509Enrollment
$certificateRequest.InitializeFromRequest($pkcs10)
$csr = $certificateRequest.CreateRequest($XCN_CRYPT_STRING_BASE64REQUESTHEADER)

Write-Output $csr
