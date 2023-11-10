use v6;

role WebService::GitHub::Role::Debug {
    method prepare_request($method is rw, $uri is rw, %headers, $body is rw) {
        note ">>> $method $uri";
        note ">>> Headers:";
        for %headers.kv -> $k, $v {
            $v = 'X' if $k ~~ /^Authorization/;
            if $v ~~ List {
                note ">>>   $k: " ~ $v.join(", ");
            }
            else {
                note ">>>   $k: $v";
            }
        }
        note ">>> Has body" with $body;
        nextsame;
    }
    method handle_response(%response) {
        note "<<< Status: %response<status>";
        note "<<< Reason: %response<reason>";
        note ">>> Headers:";
        for %response<headers>.kv -> $k, $v {
            if $v ~~ List {
                note "<<<   $k: " ~ $v.join(", ");
            }
            else {
                note "<<<   $k: $v";
            }
        }
        note "<<< Content bytes: " ~ %response<content>.bytes;
        nextsame;
    }
}
