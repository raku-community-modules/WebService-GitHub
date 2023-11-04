use v6;

role WebService::GitHub::Role::CustomUserAgent {
    method prepare_request($method is rw, $uri is rw, %headers, $body is rw) {
        %headers<User-Agent> = %.role_data<custom_useragent> if %.role_data<custom_useragent>:exists;
        nextsame;
    }

    method set-custom-useragent($ua) {
        %.role_data<custom_useragent> = $ua;
    }
}
