# WebService-GitHub

A wrapper for the GitHub REST API.

## SYNOPSIS

    use WebService::GitHub;

    my $gh = WebService::GitHub.new(
        access-token => 'my-access-token'
    );

    my $res = $gh.request('/user');
    say $res.data.name;

## TODO

Patches welcome

 * Handle Errors
 * Auto Pagination
 * API Throttle

## Setup

### Authentication

One can order the library to authenticate using one of three different ways.
Depending on which way you choose you need to pass a different set of arguments
to the constructor:

 * `auth_login` & `auth_token`
   OAuth token authenticaation.

 * `pat`
   Personal Access Token authentication.

 * `app-auth` and `install-id`
   Application authentication. First construct a `WebService::GitHub::AppAuth`
   passing a `pem-file` or a `pem` string to its constructor. then pass it
   as `app-auth` to the `WebService::GitHub` constructor.

### Other constructor arguments

 * `endpoint`
   Useful for GitHub Enterprise. Default to https://api.github.com

 * `per_page`
   from [Doc](https://developer.github.com/v3/#pagination), default to 30, max to 100.

 * `jsonp_callback`
   [JSONP Callback](https://developer.github.com/v3/#json-p-callbacks)

 * `time-zone`
   UTC by default, [Doc](https://developer.github.com/v3/#timezones)

 * `with`
   Builds the object with a particular role

   ```raku
   my $gh = WebService::GitHub.new(
       with => ('Debug')
   );
   ```

### Response

 * `is-success`
   Did it succeed?

 * `raw`
   HTTP::Response instance

 * `data`
   JSON decoded data

 * `header(Str $field)`
   Get header of HTTP Response

 * `first-page-url`, `prev-page-url`, `next-page-url`, `last-page-url`
   Parsed from the Link header, [Doc](https://developer.github.com/v3/#pagination)

 * `x-ratelimit-limit`, `x-ratelimit-remaining`, `x-ratelimit-reset`
   [Rate Limit](https://developer.github.com/v3/#rate-limiting)

