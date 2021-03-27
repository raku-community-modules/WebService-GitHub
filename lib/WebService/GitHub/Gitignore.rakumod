use WebService::GitHub::Role;

class WebService::GitHub::Gitignore does WebService::GitHub::Role {

    method templates() {
        self.request("/gitignore/templates","GET");
    }

    method template($name) {
        self.request("/gitignore/templates/$name","GET");
    }
}
