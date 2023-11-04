use v6;

use URI::Escape;
use MIME::Base64;
use JSON::Fast;
# from-json
use Cache::LRU;
use HTTP::Tiny;
use WebService::GitHub::Response;
use WebService::GitHub::AppAuth;

class X::WebService::GitHub is Exception {
    has $.reason;
    method message()
    {
        "Error : $.reason";
    }
}

role WebService::GitHub::Role {
    has $.endpoint = 'https://api.github.com';

    has $!pat is built = %*ENV<GH_TOKEN>;
    # or
    has $!auth-login is built;
    has $!auth-token is built;
    # or
    has WebService::GitHub::AppAuth $!app-auth is built;
    has $!install-id is built;

    has $.useragent = 'Raku-WebService-GitHub';
    has $.ht = HTTP::Tiny.new;

    has $.cache = Cache::LRU.new(size => 200);

    # request args
    has $.per_page;
    has $.jsonp_callback;
    has $.time-zone;
    has $.media-type is rw;

    # response args
    has $.auto_pagination = 0;

    has @.with = ();
    has %.role_data;

    submethod TWEAK(*%args) {
        if %args<with>:exists {
            for |%args<with> -> $n {
                my $class = "WebService::GitHub::Role::$n";
                require ::($class);
                self does ::($class);
            }
        }
    }
    
    method request(Str $path, $method is copy = 'GET', :%data is copy) {
        my $url = $.endpoint ~ $path;
        if ($method eq 'GET') {
            %data<per_page> = $.per_page if $.per_page.defined;
            %data<callback> = $.jsonp_callback if $.jsonp_callback.defined;
            # dummy, not supported
            # $uri.query_form(|%data);
            $url ~= '?' ~ (for %data.kv -> $k, $v {
                $k ~ '=' ~ uri-escape($v)
            }).join('&') if %data.elems;
        }

        my %headers;
        my $body;
        %headers<User-Agent> = $!useragent;
        with $!media-type {
            %headers<Accept> = $!media-type;
        } else {
            %headers<Accept> = 'application/vnd.github.v3+json';
        }

        with $!time-zone {
            %headers<Time-Zone> = $!time-zone;
        }

        if $!auth-login.defined && $!auth-token.defined {
            %headers<Authorization> = "Basic " ~ MIME::Base64.encode-str("{ $!auth-login }:{ $!auth-token }");
        } elsif $!pat {
            %headers<Authorization> = "token " ~ $!pat;
        } elsif $!install-id {
            %headers<Authorization> = $!app-auth.get-installation-auth($!install-id);
        }

        if ($method ne 'GET' and %data) {
            $body = to-json(%data).encode;
            %headers<Content-Length> = $body.bytes.Str;
        }

        $.prepare_request($method, $url, %headers, $body);
        my %res = self!make_request($method, $url, %headers, $body);
        $.handle_response(%res);

        my $ghres = WebService::GitHub::Response.new(
                raw => %res,
                auto_pagination => $!auto_pagination,
                );

        if !$ghres.is-success {
            my $message = "";
            if $ghres.data<message> {
                $message ~= $ghres.data<message>;
            }
            my $errors = $ghres.data<errors>;
            if $errors[0]{"message"} {
                $message = $message ~ ' - ' ~ $errors[0]{"message"};
            }
            X::WebService::GitHub.new(reason => $message).throw;
        }

        return $ghres;
    }

    method !make_request($method, $url, %headers, $body) {
        ## only support GET
        if $method ne 'GET' {
            return $!ht.request($method, $url, :%headers, |(:content($body) with $body));
        }

        my $cached_res = $!cache.get($url);
        if $cached_res {
            # %headers<If-None-Match> = %$cached_res<etag>;
            with $cached_res<headers><last-modified> {
                %headers<If-Modified-Since> = $_.Str;
            }

            my %res = $!ht.request($method, $url, :%headers, |(:content($body) with $body));
            if %res<status> == 304 {
                return %$cached_res;
            }

            $!cache.set($url, %res);
            return %res;
        } else {
            my %res = $!ht.request($method, $url, :%headers, |(:content($body) with $body));
            $!cache.set($url, %res);
            return %res;
        }
    }

    # for role override
    method prepare_request($method is rw, $url is rw, %headers, $body is rw) {
    }
    method handle_response(%response) {
    }

    method rate-limit-remaining(--> Str)  {
        # make a "free" rate-limit request:
        #   GET /rate_limit
        my $resp = self.request('/rate_limit');
        return $resp.x-ratelimit-remaining;
    }
}
