use WebService::GitHub::Role;

class WebService::GitHub::Licenses does WebService::GitHub::Role {

    method list() {
        self.request("/licenses","GET");
    }

    multi method show($license) {
        self.request("/licenses/$license","GET");
    }

    multi method show(Str :$repo! , Str :$user!) {
        self.request("/repos/$user/$repo/license");
    }

}
