
public with sharing class CTPersonController {
    public static String getToken(String mobileNumber) {
        Blob hashToken = Crypto.generateDigest('MD5', Blob.valueOf(mobileNumber));
        return EncodingUtil.base64Encode(hashToken);
    }
}