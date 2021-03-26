use v6;

use WebService::GitHub::Role;
use WebService::GitHub::OAuth;
use WebService::GitHub::Gist;
use WebService::GitHub::Users;
use WebService::GitHub::Search;
use WebService::GitHub::Issues;

class WebService::GitHub does WebService::GitHub::Role {
    # does WebService::GitHub::Role::Debug if %*ENV<DEBUG_GITHUB>;
    method gists() {
        state $obj = WebService::GitHub::Gist.new: |self.attrs;
        $obj;
    }
    method users() {
        state $obj = WebService::GitHub::Users.new: |self.attrs;
        $obj;
    }
    method search() {
        state $obj = WebService::GitHub::Search.new: |self.attrs;
        $obj;
    }
    method issues() {
        state $obj = WebService::GitHub::Issues.new: |self.attrs;
        $obj;
    }
    method attrs() {
        self.^attributes(:local).map( -> $attr { $attr.name.split('!')[*-1] => $attr.get_value(self) } ).Hash
    }
}


