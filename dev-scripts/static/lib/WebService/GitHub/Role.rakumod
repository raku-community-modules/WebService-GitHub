use v6;

use URI;
use URI::Escape;
use MIME::Base64;
use JSON::Fast;
# from-json
use Cache::LRU;
use HTTP::Request;
use HTTP::UserAgent;
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

    has $.useragent = 'perl6-WebService-GitHub/0.1.0';
    has $.ua = HTTP::UserAgent.new;

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
    
    method request(Str $path, $method= 'GET', :%data is copy) {
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

        my $uri = URI.new($url);
        my $request = HTTP::Request.new(|($method => $uri));
        $request.header.field(User-Agent => $.useragent);
        with $.media-type {
            $request.header.field(Accept => $.media-type);
        } else {
            $request.header.field(Accept => 'application/vnd.github.v3+json');
        }

        with $.time-zone {
            $request.header.field(
                    Time-Zone => $.time-zone
                    );
        }

        if $!auth-login.defined && $!auth-token.defined {
            $request.header.field(
                Authorization => "Basic " ~ MIME::Base64.encode-str("{ $!auth-login }:{ $!auth-token }")
            );
        } elsif $!pat {
            $request.header.field(
                Authorization => "token " ~ $!pat
            );
        } elsif $!install-id {
            $request.header.field(
                Authorization => $!app-auth.get-installation-auth($!install-id)
            );
        }

        if ($method ne 'GET' and %data) {
            $request.content = to-json(%data).encode;
            $request.header.field(Content-Length => $request.content.bytes.Str);
        }

        $request = $.prepare_request($request);
        my $res = self._make_request($request);
        $res = $.handle_response($res);

        my $ghres = WebService::GitHub::Response.new(
                raw => $res,
                auto_pagination => $.auto_pagination,
                );

        if (!$ghres.is-success && $ghres.data<message>) {
            my $message = $ghres.data<message>;
            my $errors = $ghres.data<errors>;
            if ($errors[0]{"message"}) {
                $message = $message ~ ' - ' ~ $errors[0]{"message"};
            }
            X::WebService::GitHub.new(reason => $message).throw;
        }

        return $ghres;
    }

    method _make_request($request) {
        ## only support GET
        if $request.method ne 'GET' {
            return $.ua.request($request);
        }

        my $cached_res = $.cache.get($request.file);
        if $cached_res {
            # $request.header.field(
            #     If-None-Match => $cached_res.field('ETag').Str
            # );
            $request.header.field(
                    If-Modified-Since => $cached_res.field('Last-Modified').Str
                    );

            my $res = $.ua.request($request);
            if $res.code == 304 {
                return $cached_res;
            }

            $.cache.set($request.file, $res);
            return $res;
        } else {
            my $res = $.ua.request($request);
            $.cache.set($request.file, $res);
            return $res;
        }
    }

    # for role override
    method prepare_request($request) {
        return $request
    }
    method handle_response($response) {
        return $response
    }

    method rate-limit-remaining(--> Str)  {
        # make a "free" rate-limit request:
        #   GET /rate_limit
        my $resp = self.request('/rate_limit');
        return $resp.x-ratelimit-remaining;
    }
}
