<#
  .SYNOPSIS
  Displays the public key hash for the TPM endorsement key.
  .DESCRIPTION
  Can be used to collect TPM endorsement keys for used with key attestation. This script uses the SHA256 algorithm to hash the public key.
  This script can be executed with normal user privileges.
#>

$encodingType = @{ 
    XCN_CRYPT_STRING_BASE64HEADER         = 0
    XCN_CRYPT_STRING_BASE64               = 0x1
    XCN_CRYPT_STRING_BINARY               = 0x2
    XCN_CRYPT_STRING_BASE64REQUESTHEADER  = 0x3
    XCN_CRYPT_STRING_HEX                  = 0x4
    XCN_CRYPT_STRING_HEXASCII             = 0x5
    XCN_CRYPT_STRING_BASE64_ANY           = 0x6
    XCN_CRYPT_STRING_ANY                  = 0x7
    XCN_CRYPT_STRING_HEX_ANY              = 0x8
    XCN_CRYPT_STRING_BASE64X509CRLHEADER  = 0x9
    XCN_CRYPT_STRING_HEXADDR              = 0xa
    XCN_CRYPT_STRING_HEXASCIIADDR         = 0xb
    XCN_CRYPT_STRING_HEXRAW               = 0xc
    XCN_CRYPT_STRING_NOCRLF               = 0x40000000
    XCN_CRYPT_STRING_NOCR                 = 0x80000000
}

$keyIdentifierHashAlgorithm = @{ 
    SKIHashDefault   = 0
    SKIHashSha1      = 1
    SKIHashCapiSha1  = 2
    SKIHashSha256    = 3
}

$ekInfo = New-Object -ComObject X509Enrollment.CX509EndorsementKey
$ekInfo.ProviderName = 'Microsoft Platform Crypto Provider'
$ekInfo.Open()
$ekPub = $ekInfo.ExportPublicKey()
$ekInfo.Close()
$ekPubSha256Hash = $ekPub.ComputeKeyIdentifier($keyIdentifierHashAlgorithm.SKIHashSha256, $encodingType.XCN_CRYPT_STRING_HEXRAW)
Write-Output $ekPubSha256Hash.Trim()


